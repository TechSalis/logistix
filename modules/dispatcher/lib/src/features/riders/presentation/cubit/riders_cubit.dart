import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class RidersState {
  RidersState({
    required this.riders,
    required this.mapRiders,
    required this.pendingRiders,
    required this.isLoading,
    this.searchQuery = '',
    this.error,
  });

  factory RidersState.initial() => RidersState(
    riders: [],
    mapRiders: [],
    pendingRiders: [],
    isLoading: false,
  );

  final List<Rider> riders;
  final List<RiderLocationInfo> mapRiders;
  final List<Rider> pendingRiders;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  List<Rider> get filteredRiders {
    if (searchQuery.isEmpty) return riders;

    final lowerQuery = searchQuery.toLowerCase();
    return riders.where((r) {
      return r.fullName.toLowerCase().contains(lowerQuery) ||
          r.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Rider> get filteredPendingRiders {
    if (searchQuery.isEmpty) return pendingRiders;
    final lowerQuery = searchQuery.toLowerCase();
    return pendingRiders.where((r) {
      return r.fullName.toLowerCase().contains(lowerQuery) ||
          r.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  RidersState copyWith({
    List<Rider>? riders,
    List<RiderLocationInfo>? mapRiders,
    List<Rider>? pendingRiders,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) => RidersState(
    riders: riders ?? this.riders,
    mapRiders: mapRiders ?? this.mapRiders,
    pendingRiders: pendingRiders ?? this.pendingRiders,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

class RidersCubit extends Cubit<RidersState> {
  RidersCubit(this._repo) : super(RidersState.initial());

  final RiderRepository _repo;

  StreamSubscription<Rider>? _riderSubscription;

  late final callRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchCaller,
  );
  late final whatsappRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchWhatsApp,
  );

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void searchRiders(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _repo.getRiders(),
      _repo.getPendingRiders(),
    ]);

    final activeResult = results[0];
    final pendingResult = results[1];

    if (activeResult.isError || pendingResult.isError) {
      emit(
        state.copyWith(
          isLoading: false,
          error:
              activeResult.when<String?>(error: (error) => error.message) ??
              pendingResult.when<String?>(error: (error) => error.message),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        riders: activeResult.data as List<Rider>?,
        pendingRiders: pendingResult.data as List<Rider>?,
      ),
    );
  }

  Future<List<Rider>> searchMapRiders(String query) async {
    if (query.isEmpty) return state.riders;

    final result = await _repo.getRiders(search: query, limit: 20);

    return result.map((err) => [], (data) => data);
  }

  Future<void> loadMapRiders() async {
    final locResult = await _repo.getRiderLocations();
    if (locResult.isError) return;
    emit(state.copyWith(mapRiders: locResult.data));
  }

  Future<void> acceptRider(String riderId) async {
    final result = await _repo.acceptRider(riderId);
    result.map((e) => emit(state.copyWith(error: e.message)), (_) => loadAll());
  }

  Future<void> rejectRider(String riderId) async {
    final result = await _repo.rejectRider(riderId);
    result.map((e) => emit(state.copyWith(error: e.message)), (_) => loadAll());
  }

  @override
  Future<void> close() {
    _riderSubscription?.cancel();
    return super.close();
  }
}
