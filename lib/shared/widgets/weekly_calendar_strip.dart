import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class WeeklyCalendarStrip extends StatefulWidget {
  final DateTime baseDate;
  final bool showDayRow;
  final int activeWeekNumber;
  final ValueChanged<int> onWeekChanged;
  final Function(DateTime selectedDate)? onDateChanged;

  // Parameter internal untuk membedakan mode render
  final bool _isGroceryMode;

  // 1. Constructor Standar (Dipakai di Weekly Planner - Tetap gaya Box Hijau Asli)
  const WeeklyCalendarStrip({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
    this.showDayRow = true,
    this.onDateChanged,
  }) : _isGroceryMode = false;

  // 2. Named Constructor Baru (Dipakai khusus di Grocery List Screen)
  // Menghasilkan card putih langsung dengan Material elevation 2 tanpa bungkusan box hijau
  const WeeklyCalendarStrip.grocery({
    super.key,
    required this.baseDate,
    required this.activeWeekNumber,
    required this.onWeekChanged,
  }) : showDayRow = false,
       onDateChanged = null,
       _isGroceryMode = true;

  @override
  State<WeeklyCalendarStrip> createState() => _WeeklyCalendarStripState();
}

class _WeeklyCalendarStripState extends State<WeeklyCalendarStrip> {
  int _activeDayIndex = DateTime.now().weekday - 1;
  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<DateTime> _getDaysForWeek(int weekNum) {
    final DateTime baseMonday = widget.baseDate.subtract(
      Duration(days: widget.baseDate.weekday - 1),
    );
    final DateTime targetMonday = baseMonday.add(
      Duration(days: (weekNum - 1) * 7),
    );
    return List.generate(7, (i) => targetMonday.add(Duration(days: i)));
  }

  String _formatDateRange(List<DateTime> days) {
    if (days.isEmpty) return '';
    final DateTime start = days.first;
    final DateTime end = days.last;
    return '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> calculatedDays = _getDaysForWeek(
      widget.activeWeekNumber,
    );
    final String dateRangeLabel = _formatDateRange(calculatedDays);

    // --- Private Widget: Konten utama Week Selector (< Week X > & Tanggal) ---
    Widget buildWeekSelectorRow() {
      return Row(
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
                      widget.onDateChanged!(prevWeekDays[_activeDayIndex]);
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
      );
    }

    // --- REFLEKSI MODE RENDERING ---

    // JIKA GROCERY MODE: Langsung kembalikan Card Putih bermaterial elevation 2 tanpa background hijau
    if (widget._isGroceryMode) {
      return Material(
        color: AppTheme.cardWhite,
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: buildWeekSelectorRow(),
        ),
      );
    }

    // JIKA PLANNER MODE (Default): Gunakan bungkusan Container besar Box Hijau asli kamu
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
            child: buildWeekSelectorRow(),
          ),
          if (widget.showDayRow) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const double totalGaps = 6;
                const double gapWidth = 6.0;
                final double availableWidth =
                    constraints.maxWidth - (totalGaps * gapWidth);
                final double itemWidth = availableWidth / 7;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(13, (index) {
                    if (index.isOdd) {
                      return const SizedBox(width: gapWidth);
                    }

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
                        width: itemWidth,
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
