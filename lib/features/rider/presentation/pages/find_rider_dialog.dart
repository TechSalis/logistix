import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logistix/app/widgets/text_fields.dart';
import 'package:logistix/app/widgets/user_avatar.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';
import 'package:logistix/features/rider/presentation/widgets/rating.dart';

Future showFindRiderDialog(BuildContext context) {
  final ref = ProviderScope.containerOf(context);
  return showDialog(
    context: context,
    builder: (context) => const FindRiderDialog(),
  ).then((value) {
    final riderState = ref.read(findRiderProvider);
    
    if (riderState is FindRiderContacted) {
      NotificationService.inApp.showNotification(
        RiderFoundNotification(
          rider: (riderState as FindRiderContacted).rider!,
        ),
      );
      final riderProvider = ref.read(findRiderProvider.notifier);
      Future.delayed(Durations.medium3, riderProvider.ref.invalidateSelf);
    }
  });
}

class FindRiderDialog extends StatelessWidget {
  const FindRiderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: roundRectBorder16,
      insetPadding: padding_24,
      child: Padding(
        padding: padding_24,
        child: SizedBox(
          height: 274,
          width: double.infinity,
          child: Center(
            child: Consumer(
              builder: (context, ref, child) {
                ref.listen(findRiderProvider, (p, n) {
                  if (n.hasError && n.error is AppError) {
                    NotificationService.inApp.showToast(
                      (n.error! as AppError).message,
                    );
                  }
                });
                final state = ref.watch(findRiderProvider).requireValue;
                if (ref.watch(findRiderProvider).isLoading) {
                  switch (state) {
                    case FindRiderInitialState():
                      return const FindingRiderView();
                    case FindRiderReturnedWith():
                      return const FindingRiderView();
                    default:
                  }
                } else {
                  switch (state) {
                    case FindRiderInitialState():
                      return const FindRiderView();
                    case FindRiderReturnedWith():
                      if (state.rider != null) {
                        return RiderFoundView(
                          rider: state.rider!,
                          onContact: () {
                            // ChatPageRoute(state.rider!).push(context);
                          },
                        );
                      }
                      return NoRiderFoundView(
                        onRetry: () {
                          ref.read(findRiderProvider.notifier).findRider();
                        },
                      );
                    default:
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class FindRiderView extends ConsumerStatefulWidget {
  const FindRiderView({super.key});

  @override
  ConsumerState<FindRiderView> createState() => _FindRiderDialogState();
}

class _FindRiderDialogState extends ConsumerState<FindRiderView> {
  bool useCurrent = false;
  Address? address;

  void _toggleUseCurrent(_) async {
    if (!useCurrent) {
      final newAddress =
          await ref.watch(locationProvider.notifier).getUserAddress();
      address = newAddress;
    }
    setState(() => useCurrent = !useCurrent);
  }

  @override
  Widget build(BuildContext context) {
    final currentlocationColor = Color.lerp(
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.surface,
      0.7,
    );
    final labelColor =
        useCurrent ? Theme.of(context).colorScheme.tertiary : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flash_on,
          size: 32,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(height: 8),
        Text(
          "Find a Nearby Rider",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        AddressTextField(
          enabled: !useCurrent,
          address: address,
          onAddressChanged: (value) => address = value,
          decoration: const InputDecoration(
            labelText: "Enter your location",
            // prefixIcon: Icon(Icons.my_location),
            border: OutlineInputBorder(borderRadius: borderRadius_12),
          ),
        ),
        // Location Field
        const SizedBox(height: 8),
        // Use current location chip
        Align(
          alignment: Alignment.centerLeft,
          child: ChoiceChip(
            selected: useCurrent,
            showCheckmark: false,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.my_location, size: 18, color: labelColor),
                const SizedBox(width: 6),
                const Text("Use my location"),
              ],
            ),
            onSelected: _toggleUseCurrent,
            selectedColor: currentlocationColor,
            labelStyle: TextStyle(color: labelColor),
            backgroundColor: Theme.of(context).highlightColor,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Find Rider"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: () {
              if (address?.name.isEmpty ?? true) {
                NotificationService.inApp.showToast(
                  "Please provide a location",
                );
              } else {
                ref.read(findRiderProvider.notifier).setLocation(address!);
                ref.read(findRiderProvider.notifier).findRider();
              }
            },
          ),
        ),
      ],
    );
  }
}

class FindingRiderView extends StatelessWidget {
  const FindingRiderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitRipple(size: 80, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 40),
        Text(
          "Looking for nearby riders...",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          "This usually takes a few minutes.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class RiderFoundView extends StatelessWidget {
  final RiderData rider;
  final VoidCallback onContact;

  const RiderFoundView({
    super.key,
    required this.rider,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(radius: 32, user: rider),
        const SizedBox(height: 12),
        Text(
          rider.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (rider.rating != null) RatingGroupWidget(rating: rider.rating!),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContact,
            child: const Text("Contact Rider"),
          ),
        ),
      ],
    );
  }
}

class NoRiderFoundView extends StatelessWidget {
  final VoidCallback onRetry;

  const NoRiderFoundView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
        const SizedBox(height: 16),
        Text(
          "No rider found nearby",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          "You can try again in a moment.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
        ),
      ],
    );
  }
}
