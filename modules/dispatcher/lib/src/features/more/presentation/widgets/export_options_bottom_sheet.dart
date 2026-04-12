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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LogistixColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.file_download_outlined,
                  color: LogistixColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.textTheme.titleLarge?.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Date Range',
            style: context.textTheme.labelSmall?.bold.copyWith(
              color: LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(BootstrapRadii.input),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LogistixColors.background,
                borderRadius: BorderRadius.circular(BootstrapRadii.input),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: LogistixColors.primary,
                  ),
                  const SizedBox(width: 12),
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
          if (widget.showRiderFilter) ...[
            const SizedBox(height: 20),
            Text(
              'Filter by Rider',
              style: context.textTheme.labelSmall?.bold.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            AssignRiderDropdownSearch(
              selectedRider: _selectedRider,
              searchRiders: (filter) =>
                  context.read<SearchRidersUseCase>().call(filter),
              onChanged: (rider) => setState(() => _selectedRider = rider),
              label: 'Search or select a rider',
            ),
          ],
          const SizedBox(height: 32),
          BootstrapButton(
            onPressed: () {
              final params = ExportParams(
                startDate: _startDate,
                endDate: _endDate,
                riderId: _selectedRider?.id,
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
