import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

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
  final List<Rider> mapRiders;
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
    List<Rider>? mapRiders,
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
    _initSubscription();
    refresh();
  }

  final RiderRepository _repo;
  StreamSubscription<List<Rider>>? _ridersSubscription;

  int _limit = 50;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  Future<void> _initSubscription() async {
    await _ridersSubscription?.cancel();
    _ridersSubscription = _repo
        .watchRiders(
          searchQuery: state.searchQuery,
          statuses: state.selectedStatus != null
              ? [state.selectedStatus!]
              : null,
          limit: _limit,
        )
        .listen((riders) {
          if (isClosed) return;

          final active = riders.where((r) => r.permitStatus == PermitStatus.APPROVED).toList();
          final pending = riders.where((r) => r.permitStatus == PermitStatus.PENDING).toList();

          active.sort((a, b) => a.fullName.compareTo(b.fullName));

          emit(
            state.copyWith(
              riders: active,
              pendingRiders: pending,
              mapRiders: active,
            ),
          );
        });
  }

  Future<void> refresh() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    
    _limit = 50;
    await _initSubscription();

    final result = await _repo.getRiders(
      searchQuery: state.searchQuery,
      statuses: state.selectedStatus != null ? [state.selectedStatus!] : null,
      limit: _limit,
    );

    result.when(
      data: (riders) {
        _hasMore = riders.length >= _limit;
        emit(state.copyWith(isLoading: false));
      },
      error: (e) => emit(state.copyWith(isLoading: false, error: e.message)),
    );
  }

  void loadMore() {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _limit += 50;
    _initSubscription();

    _isLoadingMore = false;
  }

  late final callRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchCaller,
  );
  late final whatsappRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchWhatsApp,
  );

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await LogistixLauncher.callNumber(phone);
  }

  Future<void> _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = 'https://wa.me/$cleanPhone';
    await LogistixLauncher.launchInBrowser(url);
  }

  void filterByStatus(RiderStatus? status) {
    emit(state.copyWith(selectedStatus: status, clearStatus: status == null));
    refresh();
  }

  void searchRiders(String query) {
    emit(state.copyWith(searchQuery: query));
    refresh();
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
      final newAccepting = Set<String>.from(state.acceptingRiderIds)
        ..remove(riderId);
      emit(state.copyWith(acceptingRiderIds: newAccepting));
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
      final newRejecting = Set<String>.from(state.rejectingRiderIds)
        ..remove(riderId);
      emit(state.copyWith(rejectingRiderIds: newRejecting));
    }
  }

  void selectRider(Rider? rider) {
    emit(
      state.copyWith(selectedRider: rider, clearSelectedRider: rider == null),
    );
  }

  void selectRiderById(String id) {
    final rider = state.riders.firstWhereOrNull((r) => r.id == id) ??
        state.pendingRiders.firstWhereOrNull((r) => r.id == id);
    if (rider != null) {
      selectRider(rider);
    }
  }

  void deselectRider() {
    emit(state.copyWith(clearSelectedRider: true));
  }

  @override
  Future<void> close() async {
    await _ridersSubscription?.cancel();
    return super.close();
  }
}
