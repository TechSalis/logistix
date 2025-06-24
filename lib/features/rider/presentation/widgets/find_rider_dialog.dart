import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/async_state_widget.dart';
import 'package:logistix/features/location_picker/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forncard.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card.dart';

class FindRiderDialog extends ConsumerWidget {
  const FindRiderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(findRiderProvider, (previous, next) {
      if (next is RiderContactedState) Navigator.of(context).pop();
    });
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Builder(
          builder: (context) {
            switch (ref.watch(findRiderProvider)) {
              case FindRiderInitialState():
                return const _FindRiderInitialWidget();
              case FindingRiderState():
                return const _FindingRiderWidget();
              case RiderFoundState():
                return const _RiderFoundWidget();
              case RiderNotFoundState():
                return const _RiderNotFoundWidget();
              case ContactingRiderState():
              case RiderContactedState():
                return const _ContactingRiderWidget();
            }
          },
        ),
      ),
    );
  }
}

class _RiderNotFoundWidget extends StatelessWidget {
  const _RiderNotFoundWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          "Sorry, we couldn't find a rider right now.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _RiderFoundWidget extends StatelessWidget {
  const _RiderFoundWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            Text("Rider Found!", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final state =
                        ref.watch(findRiderProvider) as RiderFoundState;
                    return RiderCard(rider: state.rider, eta: state.eta);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, _) {
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.invalidate(findRiderProvider);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            ref.read(findRiderProvider.notifier).contactRider,
                        child: const Text("Contact Rider"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactingRiderWidget extends StatelessWidget {
  const _ContactingRiderWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: LoadingStatusView(message: 'Connecting to rider...'),
    );
  }
}

class _FindingRiderWidget extends StatelessWidget {
  const _FindingRiderWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: LoadingStatusView(message: 'Looking for a nearby rider...'),
    );
  }
}

class _FindRiderInitialWidget extends ConsumerStatefulWidget {
  const _FindRiderInitialWidget();

  @override
  ConsumerState<_FindRiderInitialWidget> createState() =>
      _FindRiderInitialWidgetState();
}

class _FindRiderInitialWidgetState
    extends ConsumerState<_FindRiderInitialWidget>
    with TextValidatorProviderFornCardBuilder {
  final locationController = TextEditingController();

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Confirm Pickup Location",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            textValidatorProviderFornCardBuilder(
              validatorProvider: requiredValidatorProvider(locationController),
              title: "Where is the rider coming to?",
              child: LocationTextField(
                controller: locationController,
                showUseYourLocationButton: true,
                decoration: const InputDecoration(hintText: 'Enter a location'),
                onChanged: (value) {
                  ref
                      .read(findRiderProvider.notifier)
                      .setLocation(
                        Address(locationController.text, coordinates: null),
                      );
                },
                onAddressPicked: (address) {
                  ref.read(findRiderProvider.notifier).setLocation(address);
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(findRiderProvider.notifier).findRider();
                },
                icon: const Icon(Icons.motorcycle),
                label: const Text("Find Rider"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
