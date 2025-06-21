import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/async_state_widget.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/features/rider/find_rider/logic/find_rider_rp.dart';
import 'package:logistix/features/rider/find_rider/widgets/rider_card.dart';

class FindRiderDialog extends ConsumerWidget {
  const FindRiderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(findRiderProvider, (previous, next) {
      if (next is RiderContactedState) Navigator.of(context).pop(true);
    });
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
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
      height: 330,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                    final state = ref.watch(findRiderProvider) as RiderFoundState;
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
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            ref.read(findRiderProvider.notifier).contactRider,
                        icon: const Icon(Icons.notifications),
                        label: const Text("Contact Rider"),
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
    return SizedBox(
      height: 330,
      child: LoadingStatusView(message: 'Connecting to rider...'),
    );
  }
}

class _FindingRiderWidget extends StatelessWidget {
  const _FindingRiderWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
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
      height: 260,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confirm Pickup Location",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            LocationTextField(
              controller: locationController,
              showUseYourLocationButton: true,
              decoration: const InputDecoration(hintText: "Enter a location"),
              onChanged: (value) {
                ref
                    .read(findRiderProvider.notifier)
                    .setLocation(
                      Address(
                        formatted: locationController.text,
                        coordinates: null,
                      ),
                    );
              },
              onAddressPicked: (address) {
                ref.read(findRiderProvider.notifier).setLocation(address);
              },
            ),
            const SizedBox(height: 24),
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
