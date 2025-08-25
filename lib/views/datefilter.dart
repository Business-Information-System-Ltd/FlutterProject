import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterDropdown extends StatefulWidget {
  final Function(DateTimeRange range, String selectedValue) onDateRangeChanged;
 
  final String? selectedValue; 
  final DateTimeRange? customRange;

  const DateFilterDropdown({
    super.key,
    required this.onDateRangeChanged,
    this.selectedValue,
    this.customRange,
  });

  @override
  State<DateFilterDropdown> createState() => _DateFilterDropdownState();
}

class _DateFilterDropdownState extends State<DateFilterDropdown> {
  String? selectedDate;
  DateTimeRange? customDateRange;

  String _getThisWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${DateFormat.yMd().format(start)} - ${DateFormat.yMd().format(end)}';
  }

  String _getThisMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return '${DateFormat.yMd().format(start)} - ${DateFormat.yMd().format(end)}';
  }

  String _getThisYearRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    return '${DateFormat.yMd().format(start)} - ${DateFormat.yMd().format(end)}';
  }

  void _filterByPresetDate(String type) {
    final now = DateTime.now();
    DateTimeRange? range;

    switch (type) {
      case 'today':
        range = DateTimeRange(start: now, end: now);
        break;
      case 'this_week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        range = DateTimeRange(start: start, end: end);
        break;
      case 'this_month':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        range = DateTimeRange(start: start, end: end);
        break;
      case 'this_year':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        range = DateTimeRange(start: start, end: end);
        break;
    }

    if (range != null) {
      widget.onDateRangeChanged(range, type);
    }
  }

  void _showCustomDateDialog(BuildContext context) {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Custom Date'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Start Date:"),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000),
                    );
                    if (picked != null) {
                      setState(() => start = picked);
                    }
                  },
                  child: Text(DateFormat.yMd().format(start)),
                ),
                const SizedBox(height: 16),
                const Text("Select End Date:"),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: end,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000),
                    );
                    if (picked != null) {
                      setState(() => end = picked);
                    }
                  },
                  child: Text(DateFormat.yMd().format(end)),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                if (start.isAfter(end)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid Date Range")));
                } else {
                  customDateRange = DateTimeRange(start: start, end: end);
                  widget.onDateRangeChanged(customDateRange!, 'custom_date');
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
      return DropdownButton<String>(
    value: widget.selectedValue, 
    hint: const Text("Filter by Date"),
    onChanged: (value) {
      if (value == 'custom_date') {
        _showCustomDateDialog(context);
      } else if (value != null) {
        _filterByPresetDate(value);
      }
    },
      items: [
        DropdownMenuItem(
          value: 'today',
          child: Tooltip(
            message: DateFormat.yMd().format(DateTime.now()),
            child: const Text('Today'),
          ),
        ),
        DropdownMenuItem(
          value: 'this_week',
          child: Tooltip(
            message: _getThisWeekRange(),
            child: const Text('This Week'),
          ),
        ),
        DropdownMenuItem(
          value: 'this_month',
          child: Tooltip(
            message: _getThisMonthRange(),
            child: const Text('This Month'),
          ),
        ),
        DropdownMenuItem(
          value: 'this_year',
          child: Tooltip(
            message: _getThisYearRange(),
            child: const Text('This Year'),
          ),
        ),
        DropdownMenuItem(
          value: 'custom_date',
          child: Tooltip(
            message: customDateRange != null
                ? '${DateFormat.yMd().format(customDateRange!.start)} - ${DateFormat.yMd().format(customDateRange!.end)}'
                : 'Pick Custom Range',
            child: const Text('Custom Date'),
          ),
        ),
      ],
    );
  }
}
