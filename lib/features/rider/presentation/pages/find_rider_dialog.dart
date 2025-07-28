import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/app/widgets/user_avatar.dart';
import 'package:logistix/app/widgets/user_map_view.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/domain/entities/permission_data.dart';
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
        RiderFoundNotification(rider: (riderState as FindRiderContacted).rider),
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
      insetPadding: padding_24,
      child: Padding(
        padding: padding_24,
        child: AnimatedSwitcher(
          duration: Durations.long4,
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
    );
  }
}

class FindRiderView extends ConsumerStatefulWidget {
  const FindRiderView({super.key});

  @override
  ConsumerState<FindRiderView> createState() => _FindRiderViewState();
}

class _FindRiderViewState extends ConsumerState<FindRiderView> {
  bool _checkPermission() {
    return ref.read(permissionProvider(PermissionData.location)).isGranted ??
        false;
  }

  Future useCurrentLocation() async {
    final coordinates =
        await ref.read(locationServiceProvider).getUserCoordinates();
    findRider(coordinates);
  }

  Future findRider(Coordinates coordinates) {
    return ref.read(findRiderProvider.notifier).findRider(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // Title
        Text(
          "Find a Nearby Rider",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        // Map preview card
        const SizedBox(
          height: 140,
          child: Card(
            elevation: 4,
            margin: padding_H16,
            clipBehavior: Clip.hardEdge,
            child: IgnorePointer(child: UserMapView()),
          ),
        ),
        const SizedBox(height: 16),
        // Use current location button
        ElevatedButton.icon(
          onPressed: _checkPermission() ? useCurrentLocation : null,
          icon: const Icon(Icons.my_location),
          label: const Text("Use current location"),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.tertiary,
            padding: padding_H16_V12,
          ),
        ),
        const SizedBox(height: 24),
        // Pick on map card
        ElevatedButton.icon(
          onPressed: () async {
            final Address? address = await const LocationPickerPageRoute().push(
              context,
            );
            if (address?.coordinates != null) findRider(address!.coordinates!);
          },
          style: ElevatedButton.styleFrom(padding: padding_H16_V12),
          icon: const Icon(Icons.add_location_alt_rounded),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pick a location from map"),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 24),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
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
      ),
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
