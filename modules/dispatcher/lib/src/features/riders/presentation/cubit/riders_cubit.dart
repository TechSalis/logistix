import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
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
    this.acceptingRiderIds = const {},
    this.rejectingRiderIds = const {},
    this.searchQuery = '',
    this.error,
    this.selectedStatus,
    this.selectedRider,
  });

  factory RidersState.initial() => RidersState(
    riders: [],
    mapRiders: [],
    pendingRiders: [],
    isLoading: false,
    acceptingRiderIds: {},
    rejectingRiderIds: {},
  );

  final List<Rider> riders;
  final List<RiderLocationInfo> mapRiders;
  final List<Rider> pendingRiders;
  final bool isLoading;
  final Set<String> acceptingRiderIds;
  final Set<String> rejectingRiderIds;
  final String? error;
  final String searchQuery;
  final RiderStatus? selectedStatus;
  final Rider? selectedRider;

  List<Rider> get filteredRiders {
    var result = riders;

    if (selectedStatus != null) {
      result = result.where((r) => r.status == selectedStatus).toList();
    }

    return result;
  }

  List<Rider> get filteredPendingRiders {
    // Pending riders usually don't have a status until accepted
    if (selectedStatus != null) return [];
    return pendingRiders;
  }

  RidersState copyWith({
    List<Rider>? riders,
    List<RiderLocationInfo>? mapRiders,
    List<Rider>? pendingRiders,
    bool? isLoading,
    Set<String>? acceptingRiderIds,
    Set<String>? rejectingRiderIds,
    String? error,
    String? searchQuery,
    RiderStatus? selectedStatus,
    Rider? selectedRider,
    bool clearStatus = false,
    bool clearSelectedRider = false,
  }) => RidersState(
    riders: riders ?? this.riders,
    mapRiders: mapRiders ?? this.mapRiders,
    pendingRiders: pendingRiders ?? this.pendingRiders,
    isLoading: isLoading ?? this.isLoading,
    acceptingRiderIds: acceptingRiderIds ?? this.acceptingRiderIds,
    rejectingRiderIds: rejectingRiderIds ?? this.rejectingRiderIds,
    error: error,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedStatus: clearStatus
        ? null
        : (selectedStatus ?? this.selectedStatus),
    selectedRider: clearSelectedRider
        ? null
        : (selectedRider ?? this.selectedRider),
  );
}

class RidersCubit extends Cubit<RidersState> {
  RidersCubit(this._repo) : super(RidersState.initial()) {
    _subscribeToRiders();
  }

  final RiderRepository _repo;

  StreamSubscription<List<Rider>>? _ridersSubscription;

  late final callRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchCaller,
  );
  late final whatsappRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchWhatsApp,
  );

  void _subscribeToRiders([String? search]) {
    _ridersSubscription?.cancel();
    _ridersSubscription = _repo
        .watchRiders(searchQuery: search)
        .listen(
          (data) {
            int rank(RiderStatus status) {
              switch (status) {
                case RiderStatus.online:
                  return 0;
                case RiderStatus.busy:
                  return 1;
                case RiderStatus.offline:
                  return 2;
              }
            }

            final activeRiders = data.where((r) => r.isAccepted).toList()
              ..sortBy((e) => rank(e.status));

            final pendingRiders = data.where((r) => !r.isAccepted).toList();
            emit(
              state.copyWith(
                isLoading: false,
                riders: activeRiders,
                pendingRiders: pendingRiders,
                mapRiders: activeRiders.map((r) => r.toLocationInfo()).toList(),
              ),
            );
          },
          onError: (Object error) {
            emit(
              state.copyWith(isLoading: false, error: 'Failed to fetch riders'),
            );
          },
        );
  }

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

  void filterByStatus(RiderStatus? status) {
    emit(state.copyWith(selectedStatus: status, clearStatus: status == null));
  }

  void searchRiders(String query) {
    emit(state.copyWith(searchQuery: query));
    _subscribeToRiders(query);
  }

  // Methods using AsyncRunners for better status tracking
  Future<void> acceptRider(String riderId) async {
    emit(state.copyWith(acceptingRiderIds: {...state.acceptingRiderIds, riderId}));
    try {
      final result = await _repo.acceptRider(riderId);
      result.when(
        error: (e) => emit(state.copyWith(error: e.message)),
      );
    } finally {
      if (!isClosed) {
        emit(state.copyWith(
          acceptingRiderIds:
              state.acceptingRiderIds.where((id) => id != riderId).toSet(),
        ));
      }
    }
  }

  Future<void> rejectRider(String riderId) async {
    emit(state.copyWith(rejectingRiderIds: {...state.rejectingRiderIds, riderId}));
    try {
      final result = await _repo.rejectRider(riderId);
      result.when(
        error: (e) => emit(state.copyWith(error: e.message)),
      );
    } finally {
      if (!isClosed) {
        emit(state.copyWith(
          rejectingRiderIds:
              state.rejectingRiderIds.where((id) => id != riderId).toSet(),
        ));
      }
    }
  }

  Future<void> selectRider(String? riderId) async {
    if (riderId == null) {
      emit(state.copyWith(clearSelectedRider: true));
      return;
    }

    final result = await _repo.getRider(riderId);
    result.when(
      data: (rider) {
        if (rider != null) {
          emit(state.copyWith(selectedRider: rider));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _ridersSubscription?.cancel();
    return super.close();
  }
}

extension on Rider {
  RiderLocationInfo toLocationInfo() {
    return RiderLocationInfo(
      id: id,
      fullName: user?.fullName ?? '',
      lastLat: lastLat,
      lastLng: lastLng,
    );
  }
}
