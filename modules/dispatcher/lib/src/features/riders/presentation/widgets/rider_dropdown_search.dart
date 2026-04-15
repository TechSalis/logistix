import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderDropdownSearch extends StatelessWidget {
  const RiderDropdownSearch({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Select a Rider',
  }) : isLarge = false;

  const RiderDropdownSearch.large({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Select a Rider',
  }) : isLarge = true;

  final Rider? selectedRider;
  final ValueChanged<Rider?> onChanged;
  final Future<List<Rider>> Function(String filter) searchRiders;
  final bool isCompleted;
  final bool enabled;
  final String label;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return _RiderDropdownSearchBase(
      selectedRider: selectedRider,
      onChanged: onChanged,
      searchRiders: searchRiders,
      isCompleted: isCompleted,
      enabled: enabled,
      label: label,
      isLarge: isLarge,
      canRemove: false,
    );
  }
}

class AssignRiderDropdownSearch extends StatelessWidget {
  const AssignRiderDropdownSearch({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.onUnassign,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Assign a Rider',
  }) : isLarge = false;

  const AssignRiderDropdownSearch.large({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    super.key,
    this.onUnassign,
    this.isCompleted = false,
    this.enabled = true,
    this.label = 'Assign a Rider',
  }) : isLarge = true;

  final Rider? selectedRider;
  final ValueChanged<Rider?> onChanged;
  final Future<List<Rider>> Function(String filter) searchRiders;
  final VoidCallback? onUnassign;
  final bool isCompleted;
  final bool enabled;
  final String label;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return _RiderDropdownSearchBase(
      selectedRider: selectedRider,
      onChanged: onChanged,
      searchRiders: searchRiders,
      onUnassign: onUnassign,
      isCompleted: isCompleted,
      enabled: enabled,
      label: label,
      isLarge: isLarge,
      canRemove: true,
    );
  }
}

class _RiderDropdownSearchBase extends StatefulWidget {
  const _RiderDropdownSearchBase({
    required this.selectedRider,
    required this.onChanged,
    required this.searchRiders,
    required this.isCompleted,
    required this.enabled,
    required this.label,
    required this.isLarge,
    required this.canRemove,
    this.onUnassign,
  });

  final Rider? selectedRider;
  final ValueChanged<Rider?> onChanged;
  final Future<List<Rider>> Function(String filter) searchRiders;
  final VoidCallback? onUnassign;
  final bool isCompleted;
  final bool enabled;
  final String label;
  final bool isLarge;
  final bool canRemove;

  @override
  State<_RiderDropdownSearchBase> createState() =>
      _RiderDropdownSearchBaseState();
}

class _RiderDropdownSearchBaseState extends State<_RiderDropdownSearchBase> {
  Rider? _localRider;

  @override
  void initState() {
    super.initState();
    _localRider = widget.selectedRider;
  }

  @override
  void didUpdateWidget(covariant _RiderDropdownSearchBase oldWidget) {
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
      constraints: BoxConstraints(minHeight: widget.isLarge ? 70 : 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BootstrapRadii.xl),
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
        itemAsString: (rider) => rider.fullName,
        onChanged: (newRider) {
          setState(() => _localRider = newRider);
          widget.onChanged(newRider);
        },
        compareFn: (r1, r2) => r1.id == r2.id,
        dropdownBuilder: _buildSelectedView,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            isDense: true,
            fillColor: context.theme.inputDecorationTheme.fillColor,
            constraints: BoxConstraints(maxHeight: widget.isLarge ? 70 : 44),
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          loadingBuilder: (_, __) => const BootstrapLoadingIndicator(),
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
        vertical: widget.isLarge ? BootstrapSpacing.xs : BootstrapSpacing.xxs,
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
                const SizedBox(width: BootstrapSpacing.sm),
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
              const SizedBox(width: BootstrapSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedRider.fullName,
                      style: widget.isLarge
                          ? context.textTheme.bodyMedium?.bold
                          : context.textTheme.bodySmall?.semiBold,
                    ),
                    if (widget.isLarge)
                      _RiderStatusIndicator(status: selectedRider.status),
                  ],
                ),
              ),
              if (widget.canRemove &&
                  !widget.isCompleted &&
                  (widget.onUnassign != null || _localRider != null))
                Padding(
                  padding: const EdgeInsets.only(left: BootstrapSpacing.sm),
                  child: AnimatedScaleTap(
                    onTap: () {
                      setState(() => _localRider = null);
                      if (widget.onUnassign != null) {
                        widget.onUnassign?.call();
                      } else {
                        widget.onChanged(null);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: widget.isLarge ? 6 : BootstrapSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: LogistixColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BootstrapRadii.lg),
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
                          const SizedBox(width: 2),
                          Text(
                            'Remove',
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
          rider.fullName.initials,
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
      RiderStatus.ONLINE => LogistixColors.success,
      RiderStatus.BUSY => LogistixColors.primary,
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
          status.name,
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
      RiderStatus.ONLINE => LogistixColors.success,
      RiderStatus.BUSY => LogistixColors.primary,
      _ => LogistixColors.textTertiary,
    };

    final avatarSize = isLarge ? 44.0 : 32.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BootstrapSpacing.md,
        vertical: isLarge ? BootstrapSpacing.sm : BootstrapSpacing.xs,
      ),
      color: isSelected ? LogistixColors.primary.withValues(alpha: 0.05) : null,
      child: Row(
        children: [
          _RiderAvatar(rider: rider, size: avatarSize, isLarge: isLarge),
          const SizedBox(width: BootstrapSpacing.md),
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
          rider.fullName,
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
            rider.fullName,
            style: context.textTheme.bodyMedium?.semiBold.copyWith(
              color: isSelected ? LogistixColors.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: BootstrapSpacing.xs),
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
        const SizedBox(width: BootstrapSpacing.xxs),
        Text(
          rider.status.label,
          style: context.textTheme.labelSmall?.copyWith(color: statusColor),
        ),
        const SizedBox(width: BootstrapSpacing.xs),
        const Icon(Icons.star_rounded, size: 14, color: LogistixColors.amber),
        const SizedBox(width: 2),
        Text(
          '4.8', // Placeholder for actual rating
          style: context.textTheme.labelSmall?.bold,
        ),
      ],
    );
  }
}
