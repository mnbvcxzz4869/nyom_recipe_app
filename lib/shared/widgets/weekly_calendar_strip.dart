import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class WeeklyCalendarStrip extends StatefulWidget {
  final DateTime baseDate; // User signup/anchor date from Supabase
  final bool
  showDayRow; // true for Planner (both sections), false for Grocery List (only week card)
  final int activeWeekNumber;
  final ValueChanged<int> onWeekChanged;
  final Function(DateTime selectedDate)?
  onDateChanged; // Triggers when a weekday button is tapped

  const WeeklyCalendarStrip({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
    this.showDayRow = true,
    this.onDateChanged,
  });

  @override
  State<WeeklyCalendarStrip> createState() => _WeeklyCalendarStripState();
}

class _WeeklyCalendarStripState extends State<WeeklyCalendarStrip> {
  int _activeDayIndex =
      DateTime.now().weekday -
      1; // Default focuses current system weekday index (0-6)
  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Computes the 7 precise dates belonging to the active week number
  List<DateTime> _getDaysForWeek(int weekNum) {
    final DateTime baseMonday = widget.baseDate.subtract(
      Duration(days: widget.baseDate.weekday - 1),
    );
    final DateTime targetMonday = baseMonday.add(
      Duration(days: (weekNum - 1) * 7),
    );
    return List.generate(7, (i) => targetMonday.add(Duration(days: i)));
  }

  /// Formats the sub-header date range (e.g., "25 May - 31 May 2026")
  String _formatDateRange(List<DateTime> days) {
    if (days.isEmpty) return '';
    final DateTime start = days.first;
    final DateTime end = days.last;

    final String startStr = DateFormat('d MMM').format(start);
    final String endStr = DateFormat('d MMM yyyy').format(end);

    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> calculatedDays = _getDaysForWeek(
      widget.activeWeekNumber,
    );
    final String dateRangeLabel = _formatDateRange(calculatedDays);

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
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.cardWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.activeWeekNumber > 1
                      ? () {
                          widget.onWeekChanged(widget.activeWeekNumber - 1);
                          if (widget.onDateChanged != null) {
                            final prevWeekDays = _getDaysForWeek(
                              widget.activeWeekNumber - 1,
                            );
                            widget.onDateChanged!(
                              prevWeekDays[_activeDayIndex],
                            );
                          }
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
                  onPressed: () {
                    widget.onWeekChanged(widget.activeWeekNumber + 1);
                    if (widget.onDateChanged != null) {
                      final nextWeekDays = _getDaysForWeek(
                        widget.activeWeekNumber + 1,
                      );
                      widget.onDateChanged!(nextWeekDays[_activeDayIndex]);
                    }
                  },
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  color: AppTheme.headingGreen,
                ),
              ],
            ),
          ),
          if (widget.showDayRow) ...[
            const SizedBox(height: 16),
            // LayoutBuilder allows us to calculate pixel widths dynamically at runtime
            LayoutBuilder(
              builder: (context, constraints) {
                const double totalGaps = 6;
                const double gapWidth = 6.0; // Clean layout separation gap

                // Calculate identical card sizes down to exact sub-pixels
                final double availableWidth =
                    constraints.maxWidth - (totalGaps * gapWidth);
                final double itemWidth = availableWidth / 7;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(13, (index) {
                    // 7 items + 6 gaps = 13 total children
                    // Render an explicit gap between day items
                    if (index.isOdd) {
                      return const SizedBox(width: gapWidth);
                    }

                    // Convert row layout pointer back into your 0-6 array space
                    final int dayIndex = index ~/ 2;
                    final DateTime dayDate = calculatedDays[dayIndex];
                    final bool isDaySelected = dayIndex == _activeDayIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeDayIndex = dayIndex;
                        });
                        if (widget.onDateChanged != null) {
                          widget.onDateChanged!(dayDate);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width:
                            itemWidth, // Explicitly forces all 7 cards to be identical
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDaySelected
                              ? AppTheme.warmYellow
                              : AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _dayNames[dayIndex],
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDaySelected
                                        ? AppTheme.headingGreen
                                        : AppTheme.greyAccent,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dayDate.day}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDaySelected
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
            ),
          ],
        ],
      ),
    );
  }
}
