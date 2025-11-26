import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';

class DateRangePickerScreen {
  static void show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    Function(DateTime, DateTime)? onDateRangeSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => DateRangePickerDialog(
        displayedMonth: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        onDateRangeSelected: onDateRangeSelected ?? (start, end) {},
        onDisplayedMonthChanged: (month) {},
      ),
    );
  }
}

class DateRangePickerDialog extends StatefulWidget {
  final DateTime displayedMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;
  final Function(DateTime) onDisplayedMonthChanged;

  const DateRangePickerDialog({
    required this.displayedMonth,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
    required this.onDisplayedMonthChanged,
  });

  @override
  State<DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<DateRangePickerDialog> {
  late DateTime _displayedMonth;
  late DateTime? _selectedStart;
  late DateTime? _selectedEnd;

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.displayedMonth;
    _selectedStart = widget.startDate;
    _selectedEnd = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // 👈 removes padding limit
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: SizedBox(
          width: Platform.isAndroid ? 320 : 330,
          // 👈 FIXED DIALOG WIDTH (change as you like)
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Date Range",
                  style: TextStyle(
                    color: ColorsContent.blackThemeColor,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // Date Range Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'From',
                                  style: TextStyle(
                                    color: ColorsContent.datePickerGreyText,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedStart != null
                                    ? _formatDateFull(_selectedStart!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: ColorsContent.datePickerDarkText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🔥 Full-Height Vertical Divider
                        const VerticalDivider(
                          width: 20,
                          thickness: 1,
                          color: Colors.grey,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 35.0),
                                child: Text(
                                  'To',
                                  style: TextStyle(
                                    color: ColorsContent.datePickerGreyText,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedEnd != null
                                    ? _formatDateFull(_selectedEnd!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: ColorsContent.datePickerDarkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity, // 🔥 forces full width
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Calendar Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _displayedMonth = DateTime(
                              _displayedMonth.year, _displayedMonth.month - 1);
                          widget.onDisplayedMonthChanged(_displayedMonth);
                        });
                      },
                      child: SvgPicture.asset(
                        ImageConstant.dateMove,
                      ),
                    ),
                    Text(
                      _getMonthYearString(_displayedMonth),
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorsContent.datePickerGreyText,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _displayedMonth = DateTime(
                              _displayedMonth.year, _displayedMonth.month + 1);
                          widget.onDisplayedMonthChanged(_displayedMonth);
                        });
                      },
                      child: SvgPicture.asset(
                        ImageConstant.dateUpMove,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weekday Headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                      .map((day) => SizedBox(
                            width: 35,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorsContent.newThemeColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),

                // Calendar Grid
                _buildCalendarGrid(),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: ColorsContent.newThemeColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorsContent.newThemeColor,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedStart != null &&
                                _selectedEnd != null
                            ? () {
                                widget.onDateRangeSelected(
                                    _selectedStart!, _selectedEnd!);
                                Navigator.pop(context); // ✅ Close the dialog
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsContent.newThemeColor,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDay =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize =
            constraints.maxWidth / 7; // <-- Fully responsive cell width

        List<Widget> items = [];

        // Empty cells before first day
        for (int i = 1; i < startingWeekday; i++) {
          items.add(SizedBox(width: cellSize, height: cellSize));
        }

        // Calendar Day Cells
        for (int day = 1; day <= daysInMonth; day++) {
          final date =
              DateTime(_displayedMonth.year, _displayedMonth.month, day);
          final isStart =
              _selectedStart != null && _isSameDay(date, _selectedStart!);
          final isEnd = _selectedEnd != null && _isSameDay(date, _selectedEnd!);
          final isInRange = _selectedStart != null &&
              _selectedEnd != null &&
              date.isAfter(_selectedStart!) &&
              date.isBefore(_selectedEnd!);

          items.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedStart == null) {
                    _selectedStart = date;
                  } else if (_selectedEnd == null) {
                    if (date.isBefore(_selectedStart!)) {
                      _selectedEnd = _selectedStart;
                      _selectedStart = date;
                    } else {
                      _selectedEnd = date;
                    }
                  } else {
                    _selectedStart = date;
                    _selectedEnd = null;
                  }
                });
              },
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: isInRange
                      ? ColorsContent.newThemeColor.withOpacity(0.2)
                      : Colors.transparent,
                  shape:
                      (isStart || isEnd) ? BoxShape.circle : BoxShape.rectangle,
                ),
                child: Center(
                  child: Container(
                    width: cellSize * 0.7,
                    height: cellSize * 0.7,
                    decoration: (isStart || isEnd)
                        ? BoxDecoration(
                            color: ColorsContent.newThemeColor,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          color: (isStart || isEnd)
                              ? Colors.white
                              : isInRange
                                  ? ColorsContent.newThemeColor
                                  : Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: isStart || isEnd || isInRange
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Wrap(
          spacing: 0,
          runSpacing: 8,
          children: items,
        );
      },
    );
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  String _formatDateFull(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
