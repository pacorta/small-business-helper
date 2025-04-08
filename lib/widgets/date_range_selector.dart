import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange) onDateRangeSelected;

  const DateRangeSelector({
    super.key,
    this.initialDateRange,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  DateTimeRange? selectedRange;
  late DateTime displayedMonth;
  late final DateTime firstAllowedDate;
  final DateTime lastAllowedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedRange = widget.initialDateRange;
    displayedMonth = DateTime.now();
    // Permitir seleccionar fechas desde hace 2 años
    firstAllowedDate = DateTime(lastAllowedDate.year - 2, 1, 1);
  }

  Widget _buildPresetChips() {
    final now = DateTime.now();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPresetChip(
          'Última semana',
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
        ),
        _buildPresetChip(
          'Último mes',
          DateTimeRange(
            start: DateTime(now.year, now.month - 1, now.day),
            end: now,
          ),
        ),
        _buildPresetChip(
          'Últimos 3 meses',
          DateTimeRange(
            start: DateTime(now.year, now.month - 3, now.day),
            end: now,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, DateTimeRange range) {
    final isSelected =
        selectedRange?.start == range.start && selectedRange?.end == range.end;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          selectedRange = range;
          displayedMonth = range.start;
        });
        widget.onDateRangeSelected(range);
      },
      selectedColor: Colors.purple.shade100,
      checkmarkColor: Colors.purple,
    );
  }

  Widget _buildMonthNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: displayedMonth.year <= firstAllowedDate.year &&
                  displayedMonth.month <= firstAllowedDate.month
              ? null
              : () {
                  setState(() {
                    displayedMonth = DateTime(
                      displayedMonth.year,
                      displayedMonth.month - 1,
                    );
                  });
                },
        ),
        TextButton(
          onPressed: () => _showMonthPicker(),
          child: Text(
            DateFormat('MMMM yyyy').format(displayedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: displayedMonth.year >= lastAllowedDate.year &&
                  displayedMonth.month >= lastAllowedDate.month
              ? null
              : () {
                  setState(() {
                    displayedMonth = DateTime(
                      displayedMonth.year,
                      displayedMonth.month + 1,
                    );
                  });
                },
        ),
      ],
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar mes'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            itemCount: (lastAllowedDate.year - firstAllowedDate.year + 1) * 12,
            itemBuilder: (context, index) {
              final year = firstAllowedDate.year + (index ~/ 12);
              final month = (index % 12) + 1;
              final date = DateTime(year, month);

              if (date.isAfter(lastAllowedDate)) {
                return const SizedBox.shrink();
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    displayedMonth = date;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: date.year == displayedMonth.year &&
                            date.month == displayedMonth.month
                        ? Colors.purple.shade100
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    DateFormat('MMM\ny').format(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: date.year == displayedMonth.year &&
                              date.month == displayedMonth.month
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    return Column(
      children: [
        // Días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((day) => SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Días del mes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayNumber = index - (firstWeekday - 1);
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox();
            }

            final date = DateTime(
              displayedMonth.year,
              displayedMonth.month,
              dayNumber,
            );

            // Mejoramos la lógica de selección
            final isStartDate = selectedRange?.start != null &&
                date.isAtSameMomentAs(selectedRange!.start);
            final isEndDate = selectedRange?.end != null &&
                date.isAtSameMomentAs(selectedRange!.end);
            final isInRange = selectedRange != null &&
                date.isAfter(selectedRange!.start) &&
                date.isBefore(selectedRange!.end);

            return InkWell(
              onTap: () {
                if (date.isAfter(lastAllowedDate) ||
                    date.isBefore(firstAllowedDate)) {
                  return;
                }

                setState(() {
                  if (selectedRange == null) {
                    // Primera selección
                    selectedRange = DateTimeRange(start: date, end: date);
                  } else if (selectedRange!.start == selectedRange!.end) {
                    // Segunda selección para completar el rango
                    if (date.isBefore(selectedRange!.start)) {
                      selectedRange = DateTimeRange(
                        start: date,
                        end: selectedRange!.start,
                      );
                    } else {
                      selectedRange = DateTimeRange(
                        start: selectedRange!.start,
                        end: date,
                      );
                    }
                    widget.onDateRangeSelected(selectedRange!);
                  } else {
                    // Nueva selección, reinicia el rango
                    selectedRange = DateTimeRange(start: date, end: date);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isStartDate || isEndDate
                      ? Colors.purple
                      : isInRange
                          ? Colors.purple.shade100
                          : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    color: isStartDate || isEndDate ? Colors.white : null,
                    fontWeight:
                        isStartDate || isEndDate ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Seleccionar rango de fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPresetChips(),
          ),
          const Divider(height: 32),
          _buildMonthNavigator(),
          const SizedBox(height: 16),
          _buildCalendar(),
        ],
      ),
    );
  }
}
