import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

/// A reusable dropdown search for selecting [Rider]s.
///
/// Features:
/// - Online status indicators in items and selected view
/// - Searchable popup
/// - Customizable suffix actions (like unassign)
/// - Integrated optimistic selection to prevent jitter
class RiderDropdownSearch extends StatefulWidget {
  const RiderDropdownSearch({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.onUnassign,
    this.showUnassign = false,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Assign a Rider',
  }) : isLarge = false;

  const RiderDropdownSearch.large({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.onUnassign,
    this.showUnassign = false,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Assign a Rider',
  }) : isLarge = true;

  final Rider? selectedRider;
  final ValueChanged<Rider?> onChanged;
  final Future<List<Rider>> Function(String filter) searchRiders;
  final VoidCallback? onUnassign;
  final bool showUnassign;
  final bool isCompleted;
  final bool enabled;
  final String label;
  final bool isLarge;

  @override
  State<RiderDropdownSearch> createState() => _RiderDropdownSearchState();
}

class _RiderDropdownSearchState extends State<RiderDropdownSearch> {
  Rider? _localRider;

  @override
  void initState() {
    super.initState();
    _localRider = widget.selectedRider;
  }

  @override
  void didUpdateWidget(covariant RiderDropdownSearch oldWidget) {
    super.didUpdateWidget(oldWidget);

    final externalId = widget.selectedRider?.id;
    final oldExternalId = oldWidget.selectedRider?.id;

    if (externalId != oldExternalId) {
      _localRider = widget.selectedRider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: widget.isLarge ? 70 : 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LogistixRadii.xl),
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownSearch<Rider>(
        enabled: widget.enabled && !widget.isCompleted,
        items: (filter, _) => widget.searchRiders(filter),
        selectedItem: _localRider,
        itemAsString: (rider) => rider.user?.fullName ?? '',
        onChanged: (newRider) {
          setState(() => _localRider = newRider);
          widget.onChanged(newRider);
        },
        compareFn: (r1, r2) => r1.id == r2.id,
        dropdownBuilder: _buildSelectedView,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          containerBuilder: (context, child) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LogistixRadii.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
          loadingBuilder: (_, __) => const LogistixLoadingIndicator(),
          searchFieldProps: const TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type to search...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          itemBuilder: (context, rider, isDisabled, isSelected) {
            return _RiderListItem(
              rider: rider,
              isSelected: isSelected,
              isLarge: widget.isLarge,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedView(BuildContext context, Rider? selectedRider) {
    final avatarSize = widget.isLarge ? 40.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.isLarge ? LogistixSpacing.xs : 6,
      ),
      child: Builder(
        builder: (context) {
          if (selectedRider == null) {
            return Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,

                  decoration: BoxDecoration(
                    color: LogistixColors.background,
                    borderRadius: BorderRadius.circular(avatarSize * 0.35),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: widget.isLarge ? 20 : 16,
                    color: LogistixColors.textTertiary,
                  ),
                ),
                const SizedBox(width: LogistixSpacing.sm),
                Expanded(
                  child: Text(
                    widget.label,
                    style:
                        (widget.isLarge
                                ? context.textTheme.bodyMedium
                                : context.textTheme.bodySmall)
                            ?.copyWith(color: LogistixColors.textTertiary),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              _RiderAvatar(
                rider: selectedRider,
                size: avatarSize,
                isLarge: widget.isLarge,
              ),
              const SizedBox(width: LogistixSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedRider.user?.fullName ?? '',
                      style: widget.isLarge
                          ? context.textTheme.bodyMedium?.bold
                          : context.textTheme.bodySmall?.semiBold,
                    ),
                    if (widget.isLarge)
                      _RiderStatusIndicator(status: selectedRider.status),
                  ],
                ),
              ),
              if (widget.showUnassign &&
                  !widget.isCompleted &&
                  widget.onUnassign != null)
                Padding(
                  padding: const EdgeInsets.only(left: LogistixSpacing.sm),
                  child: AnimatedScaleTap(
                    onTap: () {
                      setState(() => _localRider = null);
                      widget.onUnassign?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LogistixColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(LogistixRadii.lg),
                        border: Border.all(
                          color: LogistixColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_remove_rounded,
                            size: 14,
                            color: LogistixColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Unassign',
                            style: context.textTheme.labelSmall?.bold.copyWith(
                              color: LogistixColors.error,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RiderAvatar extends StatelessWidget {
  const _RiderAvatar({
    required this.rider,
    required this.isLarge,
    this.size = 44,
  });
  final Rider rider;
  final double size;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LogistixColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: LogistixColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Text(
          rider.user?.fullName.initials ?? '?',
          style: context.textTheme.titleMedium?.bold.copyWith(
            color: LogistixColors.primary,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

class _RiderStatusIndicator extends StatelessWidget {
  const _RiderStatusIndicator({required this.status});
  final RiderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RiderStatus.online => LogistixColors.success,
      RiderStatus.busy => LogistixColors.primary,
      _ => LogistixColors.textTertiary,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status.name.toUpperCase(),
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _RiderListItem extends StatelessWidget {
  const _RiderListItem({
    required this.rider,
    required this.isSelected,
    this.isLarge = false,
  });

  final Rider rider;
  final bool isSelected;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (rider.status) {
      RiderStatus.online => LogistixColors.success,
      RiderStatus.busy => LogistixColors.primary,
      _ => LogistixColors.textTertiary,
    };

    final avatarSize = isLarge ? 44.0 : 32.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LogistixSpacing.md,
        vertical: isLarge ? LogistixSpacing.sm : LogistixSpacing.xs,
      ),
      color: isSelected ? LogistixColors.primary.withValues(alpha: 0.05) : null,
      child: Row(
        children: [
          _RiderAvatar(rider: rider, size: avatarSize, isLarge: isLarge),
          const SizedBox(width: LogistixSpacing.md),
          Expanded(
            child: isLarge
                ? _buildLargeContent(context, statusColor)
                : _buildSmallContent(context, statusColor),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: LogistixColors.primary,
              size: isLarge ? 20 : 16,
            ),
        ],
      ),
    );
  }

  Widget _buildLargeContent(BuildContext context, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rider.user?.fullName ?? '',
          style: context.textTheme.bodyLarge?.bold.copyWith(
            color: isSelected ? LogistixColors.primary : null,
          ),
        ),
        const SizedBox(height: 2),
        _StatusRow(rider: rider, statusColor: statusColor),
      ],
    );
  }

  Widget _buildSmallContent(BuildContext context, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            rider.user?.fullName ?? '',
            style: context.textTheme.bodyMedium?.semiBold.copyWith(
              color: isSelected ? LogistixColors.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _StatusIndicator(statusColor: statusColor),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.statusColor});
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.rider, required this.statusColor});
  final Rider rider;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusIndicator(statusColor: statusColor),
        const SizedBox(width: 4),
        Text(
          rider.status.label,
          style: context.textTheme.labelSmall?.copyWith(color: statusColor),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          '4.8', // Placeholder for actual rating
          style: context.textTheme.labelSmall?.bold,
        ),
      ],
    );
  }
}
