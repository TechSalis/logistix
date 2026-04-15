import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class ExportOptionsSheet extends StatefulWidget {
  const ExportOptionsSheet({
    super.key,
    this.title = 'Export Orders',
    this.showRiderFilter = true,
  });

  final String title;
  final bool showRiderFilter;

  static Future<ExportParams?> show(
    BuildContext context, {
    String title = 'Export Orders',
    bool showRiderFilter = true,
  }) {
    return showModalBottomSheet<ExportParams>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return ExportOptionsSheet(
          title: title,
          showRiderFilter: showRiderFilter,
        );
      },
    );
  }

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  Rider? _selectedRider;
  List<OrderStatus> _selectedStatuses = [];

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LogistixColors.primary,
              onSurface: LogistixColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _toggleStatus(OrderStatus status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BootstrapSpacing.lg,
        0,
        BootstrapSpacing.lg,
        BootstrapSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(BootstrapSpacing.sm),
                decoration: BoxDecoration(
                  color: LogistixColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BootstrapRadii.lg),
                ),
                child: const Icon(
                  Icons.file_download_outlined,
                  color: LogistixColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: BootstrapSpacing.md),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.textTheme.titleLarge?.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: BootstrapSpacing.md),
          Text(
            'Configure your export settings to generate a detailed report of your logistics data across orders and riders.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.lg),

          // ─── Status Filter ──────────────────────────────────────────────────────────
          Text(
            'Order Status'.toUpperCase(),
            style: context.textTheme.labelSmall?.semiBold.copyWith(
              color: LogistixColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.sm),
          Wrap(
            spacing: BootstrapSpacing.xs,
            runSpacing: BootstrapSpacing.xs,
            children: [
              BootstrapChoiceChip(
                label: 'All',
                isSelected: _selectedStatuses.isEmpty,
                onTap: () => setState(() => _selectedStatuses = []),
              ),
              ...OrderStatus.values.map(
                (status) => BootstrapChoiceChip(
                  label: status.label,
                  isSelected: _selectedStatuses.contains(status),
                  onTap: () => _toggleStatus(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          // ─── Date Range ─────────────────────────────────────────────────────────────
          Text(
            'Date Range'.toUpperCase(),
            style: context.textTheme.labelSmall?.semiBold.copyWith(
              color: LogistixColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.sm),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(BootstrapRadii.input),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BootstrapSpacing.md,
                vertical: BootstrapSpacing.md,
              ),
              decoration: BoxDecoration(
                color: context.theme.inputDecorationTheme.fillColor,
                border: Border.fromBorderSide(
                  context.theme.inputDecorationTheme.border!.borderSide,
                ),
                borderRadius: BorderRadius.circular(BootstrapRadii.input),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: _startDate != null
                        ? LogistixColors.primary
                        : LogistixColors.textTertiary,
                  ),
                  const SizedBox(width: BootstrapSpacing.md),
                  Expanded(
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                          : 'Select date range (Optional)',
                      style: context.textTheme.bodyMedium?.semiBold.copyWith(
                        color: _startDate != null
                            ? null
                            : LogistixColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Rider Filter ──────────────────────────────────────────────────────────
          if (widget.showRiderFilter) ...[
            const SizedBox(height: BootstrapSpacing.lg),
            Text(
              'Filter by Rider'.toUpperCase(),
              style: context.textTheme.labelSmall?.semiBold.copyWith(
                color: LogistixColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: BootstrapSpacing.sm),
            RiderDropdownSearch(
              // Updated from AssignRiderDropdownSearch
              selectedRider: _selectedRider,
              searchRiders: context.read<SearchRidersUseCase>().call,
              onChanged: (rider) => setState(() => _selectedRider = rider),
              label: 'Select a rider (Optional)',
            ),
          ],
          const SizedBox(height: BootstrapSpacing.xl),
          BootstrapButton(
            onPressed: () {
              final params = ExportParams(
                startDate: _startDate,
                endDate: _endDate,
                riderId: _selectedRider?.id,
                statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses,
              );
              Navigator.pop(context, params);
            },
            label: 'Generate CSV',
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }
}
