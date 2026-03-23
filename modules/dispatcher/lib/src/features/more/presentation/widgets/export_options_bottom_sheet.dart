import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class ExportOptionsBottomSheet extends StatefulWidget {
  const ExportOptionsBottomSheet({
    super.key,
    this.title = 'Export Orders',
    this.showRiderFilter = true,
  });

  final String title;
  final bool showRiderFilter;

  @override
  State<ExportOptionsBottomSheet> createState() =>
      _ExportOptionsBottomSheetState();
}

class _ExportOptionsBottomSheetState extends State<ExportOptionsBottomSheet> {
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: context.textTheme.titleLarge?.semiBold),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Date Range', style: context.textTheme.titleSmall?.semiBold),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: LogistixRadii.borderRadiusCard,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: LogistixColors.border),
                borderRadius: LogistixRadii.borderRadiusCard,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: LogistixColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                        : 'Select date range (Optional)',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: _startDate != null
                          ? null
                          : LogistixColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.showRiderFilter) ...[
            const SizedBox(height: 24),
            Text(
              'Filter by Rider',
              style: context.textTheme.titleSmall?.semiBold,
            ),
            const SizedBox(height: 8),
            RiderDropdownSearch(
              selectedRider: _selectedRider,
              searchRiders: (filter) =>
                  context.read<SearchRidersUseCase>().call(filter),
              onChanged: (rider) => setState(() => _selectedRider = rider),
              label: 'Search or select a rider',
            ),
          ],

          const SizedBox(height: 32),

          LogistixButton(
            onPressed: () {
              final params = ExportParams(
                startDate: _startDate,
                endDate: _endDate,
                riderId: _selectedRider?.id,
              );
              Navigator.pop(context, params);
            },
            label: 'Generate CSV',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
