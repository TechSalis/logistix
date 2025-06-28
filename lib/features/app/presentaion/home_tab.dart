import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/__debug_tools/debug_buttons.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:logistix/features/delivery/presentation/pages/new_delivery_page.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/quick_actions/presentation/pages/food_dialog.dart';
import 'package:logistix/features/rider/presentation/widgets/find_rider_dialog.dart';
import 'package:logistix/features/map/presentation/widgets/user_map_view.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  GoogleMapController? map;

  @override
  void dispose() {
    map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: UserMapView(onMapCreated: (m) => map = m)),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    onPressed: () async {
                      final provider = ref.read(locationProvider.notifier);
                      await centerUserHelperFunction(map!, provider);
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    icon: const Icon(Icons.my_location),
                  ),
                ),
                const _BottomPanel(),
              ],
            ),
          ),
          // const Positioned(
          //   left: 12,
          //   right: 12,
          //   bottom: 16,
          //   child: _BottomPanel(),
          // ),
          // Positioned(
          //   right: 16,
          //   bottom: 280,
          //   child: IconButton(
          //     onPressed: () async {
          //       final provider = ref.read(locationProvider.notifier);
          //       await centerUserHelperFunction(map!, provider);
          //     },
          //     style: IconButton.styleFrom(
          //       foregroundColor: Theme.of(context).colorScheme.surface,
          //       backgroundColor: Theme.of(context).colorScheme.onSurface,
          //     ),
          //     icon: const Icon(Icons.my_location),
          //   ),
          // ),
          if (kDebugMode)
            const Positioned(bottom: 280, left: 16, child: DebugFloatingIcon()),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.isDarkTheme ? Colors.black87 : Colors.white70,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuickActionsRow(), // horizontal scroll
            SizedBox(height: 20),
            _DeliveryActionCard(), // buttons row
          ],
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key, required this.action, required this.onTap});

  final QuickActionType action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          color: Colors.white,
          shadowColor: Colors.black12,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(action.icon, color: action.color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _DeliveryActionCard extends ConsumerWidget {
  const _DeliveryActionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface.withAlpha(230),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const FindRiderDialog(),
                  );
                },
                icon: const Icon(Icons.motorcycle),
                label: const Text("Find Rider"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewDeliveryPage()),
                  );
                },
                icon: const Icon(Icons.library_add),
                label: const Text("New Delivery"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionCard(
            action: QuickActionType.food,
            onTap: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (_) => const SubmitFoodQADialog(),
              );
            },
          ),
          QuickActionCard(action: QuickActionType.groceries, onTap: () {}),
          QuickActionCard(action: QuickActionType.errands, onTap: () {}),
          QuickActionCard(action: QuickActionType.repeatOrder, onTap: () {}),
        ],
      ),
    );
  }
}
