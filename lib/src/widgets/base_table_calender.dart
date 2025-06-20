import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class BaseCalendar extends StatefulWidget {
  final Function(DateTime)? onMonthChanged;
  final Function(DateTime)? onDaySelected;
  final Function(DateTime, DateTime)? onRangeSelected;

  const BaseCalendar(
      {super.key,
      this.onMonthChanged,
      this.onDaySelected,
      this.onRangeSelected});

  @override
  BaseCalendarState createState() => BaseCalendarState();
}

class BaseCalendarState extends State<BaseCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  bool _isWeekView = false;
  bool isDarkMode = false;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    isDarkMode = Get.isDarkMode;
  }

  List<DateTime> getDaysInWeek(DateTime day) {
    final startOfWeek = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  TableCalendar _buildCalendar() {
    return TableCalendar(
      calendarFormat: _isWeekView ? CalendarFormat.week : CalendarFormat.month,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode: RangeSelectionMode.toggledOn,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _rangeStart = null;
          _rangeEnd = null;
        });
        widget.onDaySelected?.call(selectedDay);
      },
      onRangeSelected: (start, end, focusedDay) {
        setState(() {
          _rangeStart = start;
          _rangeEnd = end;
          _selectedDay = null;
          _focusedDay = focusedDay;
        });
        if (start != null && end != null) {
          widget.onRangeSelected?.call(start, end);
        }
      },
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 14.0,
          height: 1.5,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange
              : Colors.red,
          fontSize: 14.0,
          height: 1.5,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: BaseColors.secondaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: BaseColors.primaryColor,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
        ),
        weekendTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange
              : Colors.red,
        ),
        outsideTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.black54,
        ),
      ),
      daysOfWeekVisible: true,
      headerVisible: true,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onMonthChanged?.call(focusedDay);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        IconButton(
          icon: Icon(
            _isWeekView ? Icons.arrow_drop_down : Icons.arrow_drop_up,
            color: Colors.blue,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _isWeekView = !_isWeekView;
            });
          },
        ),
      ],
    );
  }
}
