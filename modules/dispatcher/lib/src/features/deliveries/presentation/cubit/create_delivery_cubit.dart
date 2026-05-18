import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/delivery_create_input.dart';
import 'package:dispatcher/src/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class CreateDeliveryState {
  const CreateDeliveryState({
    required this.deliveries,
    this.riders = const [],
    this.isLoading = false,
    this.formKeyVersion = 0,
    this.error,
    this.success = false,
  });

  factory CreateDeliveryState.initial() =>
      const CreateDeliveryState(deliveries: [DeliveryCreateInput(dropOffAddress: '')]);

  final List<DeliveryCreateInput> deliveries;
  final List<Rider> riders;
  final bool isLoading;
  final int formKeyVersion;
  final String? error;
  final bool success;

  CreateDeliveryState copyWith({
    List<DeliveryCreateInput>? deliveries,
    List<Rider>? riders,
    bool? isLoading,
    int? formKeyVersion,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return CreateDeliveryState(
      deliveries: deliveries ?? this.deliveries,
      riders: riders ?? this.riders,
      isLoading: isLoading ?? this.isLoading,
      formKeyVersion: formKeyVersion ?? this.formKeyVersion,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }
}

class CreateDeliveryCubit extends Cubit<CreateDeliveryState> {
  CreateDeliveryCubit(this._deliveryRepo, this._searchRidersUseCase)
    : super(CreateDeliveryState.initial());

  final DeliveryRepository _deliveryRepo;
  final SearchRidersUseCase _searchRidersUseCase;

  Future<List<Rider>> searchRiders(
    String query, {
    double? lat,
    double? lng,
  }) async {
    final riders = await _searchRidersUseCase.call(query, lat: lat, lng: lng);
    emit(state.copyWith(riders: riders));
    return riders;
  }

  void addDelivery() {
    emit(
      state.copyWith(
        clearError: true,
        deliveries: [
          ...state.deliveries,
          const DeliveryCreateInput(dropOffAddress: ''),
        ],
      ),
    );
  }

  void duplicateDelivery(int index) {
    if (index < 0 || index >= state.deliveries.length) return;
    final deliveryToDuplicate = state.deliveries[index];
    final newList = List<DeliveryCreateInput>.from(state.deliveries)
      ..insert(index + 1, deliveryToDuplicate.copyWith());
    emit(state.copyWith(deliveries: newList, clearError: true));
  }

  void removeDelivery(int index) {
    if (state.deliveries.isEmpty) return;
    final newList = List<DeliveryCreateInput>.from(state.deliveries)..removeAt(index);
    emit(state.copyWith(deliveries: newList, clearError: true));
  }

  void updateDelivery(int index, DeliveryCreateInput delivery) {
    final newList = List<DeliveryCreateInput>.from(state.deliveries)..[index] = delivery;
    emit(state.copyWith(deliveries: newList, clearError: true));
  }

  late final parseWithAi = AsyncRunner.withArg<String, AppError, void>((
    text,
  ) async {
    if (text.trim().isEmpty) return;
    final result = await _deliveryRepo.parseTextToDeliveries(text);
    if (isClosed) return;

    result.when(
      error: (err) => throw err, 
      data: (parsed) {
        emit(
          state.copyWith(
            deliveries: [
              ...state.deliveries.where((o) => o.dropOffAddress.isNotEmpty),
              ...parsed,
            ],
          ),
        );
      },
    );
  });

  Future<void> submitDeliveries() async {
    final validDeliveries = state.deliveries
        .where((o) => o.dropOffAddress.trim().isNotEmpty)
        .toList();

    if (validDeliveries.isEmpty) {
      emit(
        state.copyWith(error: 'Please add at least one valid delivery address'),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _deliveryRepo.createBulkDeliveries(validDeliveries);

    if (isClosed) return;

    result.when(
      error: (err) {
        emit(
          state.copyWith(
            isLoading: false,
            error: err.message ?? 'Failed to create deliveries',
          ),
        );
      }, 
      data: (list) => emit(state.copyWith(isLoading: false, success: true)),
    );
  }

  void reset() {
    emit(CreateDeliveryState.initial().copyWith(formKeyVersion: state.formKeyVersion + 1));
  }

  static const String _kDeliveryTemplate = '''
Dropoff: 
Dropoff Phone: 
---
Pickup: 
Pickup Phone: 
Amount: 
Description: 
''';

  Future<void> copyTemplateToClipboard() {
    return Clipboard.setData(const ClipboardData(text: _kDeliveryTemplate));
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
}
