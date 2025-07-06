import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/async_state_widget.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_summary.dart';

class FindRiderDialog extends ConsumerWidget {
  const FindRiderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(findRiderProvider, (previous, next) {
      if (next is RiderContactedState) Navigator.pop(context);
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
      height: 330,
      child: Column(
        children: [
          Center(
            child: Text(
              "Sorry, we couldn't find a rider right now.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),
          Consumer(
            builder: (context, ref, _) {
              return Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                      onPressed: () {},
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Retry"),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RiderFoundWidget extends StatelessWidget {
  const _RiderFoundWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
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
                    return RiderSummaryCard(rider: state.rider, eta: state.eta);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Consumer(
              builder: (context, ref, _) {
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.tertiary,
                        ),
                        onPressed: () {
                          ref.invalidate(findRiderProvider);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(findRiderProvider.notifier).contactRider();
                        },
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
      height: 330,
      child: LoadingStatusView(message: 'Connecting to rider...'),
    );
  }
}

class _FindingRiderWidget extends StatelessWidget {
  const _FindingRiderWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 330,
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
    extends ConsumerState<_FindRiderInitialWidget> {
  final locationController = TextEditingController();

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Confirm Location",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextValidatorProviderFornCard(
                validatorProvider: RequiredValidatorProvider(
                  locationController,
                ),
                title: "Where is the rider coming to?",
                child: LocationTextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a location',
                  ),
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
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
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
