import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

enum CalendarStripVariant { planner, grocery, home }

class WeeklyCalendarStrip extends StatefulWidget {
  final DateTime baseDate;
  final bool showDayRow;
  final int activeWeekNumber;
  final ValueChanged<int> onWeekChanged;
  final Function(DateTime selectedDate)? onDateChanged;
  final CalendarStripVariant variant;
  final int minWeekNumber;
  final int? maxWeekNumber;

  const WeeklyCalendarStrip({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
    this.showDayRow = true,
    this.onDateChanged,
    this.variant = CalendarStripVariant.planner,
    this.minWeekNumber = 1,
    this.maxWeekNumber,
  });

  const WeeklyCalendarStrip.grocery({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
    this.minWeekNumber = 1,
    this.maxWeekNumber,
  }) : showDayRow = false,
       onDateChanged = null,
       variant = CalendarStripVariant.grocery;

  const WeeklyCalendarStrip.home({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
    this.showDayRow = true,
    this.onDateChanged,
    this.minWeekNumber = 1,
    this.maxWeekNumber,
  }) : variant = CalendarStripVariant.home;

  @override
  State<WeeklyCalendarStrip> createState() => _WeeklyCalendarStripState();
}

class _WeeklyCalendarStripState extends State<WeeklyCalendarStrip> {
  late int _activeDayIndex;

  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  DateTime _toMonday(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  void initState() {
    super.initState();
    _activeDayIndex = _todayIndexForWeek(widget.activeWeekNumber);

    if (widget.onDateChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onDateChanged!(
            _getDaysForWeek(widget.activeWeekNumber)[_activeDayIndex],
          );
        }
      });
    }
  }

  int _todayIndexForWeek(int weekNum) {
    final today = DateTime.now();
    final days = _getDaysForWeek(weekNum);
    for (int i = 0; i < days.length; i++) {
      if (_isSameDay(days[i], today)) return i;
    }
    return 0;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _getDaysForWeek(int weekNum) {
    final DateTime baseMonday = _toMonday(widget.baseDate);
    final DateTime targetMonday = baseMonday.add(
      Duration(days: (weekNum - 1) * 7),
    );
    return List.generate(7, (i) => targetMonday.add(Duration(days: i)));
  }

  String _formatDateRange(List<DateTime> days) {
    if (days.isEmpty) return '';
    return '${DateFormat('d MMM').format(days.first)} - ${DateFormat('d MMM yyyy').format(days.last)}';
  }

  Widget _buildWeekSelectorRow(List<DateTime> calculatedDays) {
    final String dateRangeLabel = _formatDateRange(calculatedDays);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: widget.activeWeekNumber > widget.minWeekNumber
              ? () {
                  final newWeek = widget.activeWeekNumber - 1;
                  final newDayIndex = _todayIndexForWeek(newWeek);
                  setState(() => _activeDayIndex = newDayIndex);
                  widget.onWeekChanged(newWeek);
                  widget.onDateChanged?.call(
                    _getDaysForWeek(newWeek)[newDayIndex],
                  );
                }
              : null,
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          color: AppTheme.headingGreen,
          disabledColor: AppTheme.greyAccent.withValues(alpha: 0.3),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Week ${widget.activeWeekNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              dateRangeLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.greyAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed:
              widget.maxWeekNumber == null ||
                  widget.activeWeekNumber < widget.maxWeekNumber!
              ? () {
                  final newWeek = widget.activeWeekNumber + 1;
                  final newDayIndex = _todayIndexForWeek(newWeek);
                  setState(() => _activeDayIndex = newDayIndex);
                  widget.onWeekChanged(newWeek);
                  widget.onDateChanged?.call(
                    _getDaysForWeek(newWeek)[newDayIndex],
                  );
                }
              : null,
          icon: const Icon(Icons.chevron_right_rounded, size: 28),
          color: AppTheme.headingGreen,
          disabledColor: AppTheme.greyAccent.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDayRow(List<DateTime> calculatedDays) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double gapWidth = 6.0;
        const int gapCount = 6;
        final double itemWidth =
            (constraints.maxWidth - (gapCount * gapWidth)) / 7;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(13, (index) {
            if (index.isOdd) return const SizedBox(width: gapWidth);

            final int dayIndex = index ~/ 2;
            final DateTime dayDate = calculatedDays[dayIndex];
            final bool isSelected = dayIndex == _activeDayIndex;

            return GestureDetector(
              onTap: () {
                setState(() => _activeDayIndex = dayIndex);
                widget.onDateChanged?.call(dayDate);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: itemWidth,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.warmYellow : AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.crossedOutGreen.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dayNames[dayIndex],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.headingGreen
                            : AppTheme.greyAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dayDate.day}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.headingGreen
                            : AppTheme.bodyTextGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> calculatedDays = _getDaysForWeek(
      widget.activeWeekNumber,
    );

    switch (widget.variant) {
      case CalendarStripVariant.home:
        return _buildDayRow(calculatedDays);

      case CalendarStripVariant.grocery:
        return Material(
          color: AppTheme.cardWhite,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildWeekSelectorRow(calculatedDays),
          ),
        );

      case CalendarStripVariant.planner:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.headingGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildWeekSelectorRow(calculatedDays),
              ),
              if (widget.showDayRow) ...[
                const SizedBox(height: 16),
                _buildDayRow(calculatedDays),
              ],
            ],
          ),
        );
    }
  }
}
