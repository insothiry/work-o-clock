import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/controller/attendance_controller.dart';
import 'package:work_o_clock/src/models/holiday_model.dart';
import 'package:work_o_clock/src/widgets/base_table_calender.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  final controller = Get.put(AttendanceController);
  List<Holiday> holidays = [];
  List<Holiday> todayEvents = [];
  List<Holiday> upcomingEvents = [];
  List<Holiday> pastEvents = [];

  DateTime selectedMonth = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHolidays(month: selectedMonth);
  }

  Future<void> fetchHolidays(
      {DateTime? from, DateTime? to, DateTime? month}) async {
    setState(() => isLoading = true);

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString('token');

      String url = 'http://localhost:3000/api/holidays/get-holidays';
      if (from != null && to != null) {
        final fromStr = from.toIso8601String();
        final toStr = to.toIso8601String();
        url += '?from=$fromStr&to=$toStr';
      } else if (month != null) {
        final formattedMonth =
            '${month.year}-${month.month.toString().padLeft(2, '0')}';
        url += '?month=$formattedMonth';
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final holidaysData = json.decode(response.body)['data'] as List;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        holidays = holidaysData.map((h) => Holiday.fromJson(h)).toList();

        todayEvents.clear();
        upcomingEvents.clear();
        pastEvents.clear();

        for (var h in holidays) {
          final date = DateTime.parse(h.date);
          final eventDate = DateTime(date.year, date.month, date.day);

          if (eventDate.isAtSameMomentAs(today)) {
            todayEvents.add(h);
          } else if (eventDate.isAfter(today)) {
            upcomingEvents.add(h);
          } else {
            pastEvents.add(h);
          }
        }

        pastEvents.sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
      } else {
        debugPrint("Failed to fetch holidays.");
      }
    } catch (e) {
      debugPrint("Error fetching holidays: $e");
    }

    setState(() => isLoading = false);
  }

  void onMonthChanged(DateTime newMonth) {
    if (newMonth.year != selectedMonth.year ||
        newMonth.month != selectedMonth.month) {
      setState(() => selectedMonth = newMonth);
      fetchHolidays(month: newMonth);
    }
  }

  Future<void> _onRefresh() async {
    await fetchHolidays(month: selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          BaseCalendar(
            onMonthChanged: onMonthChanged,
            onDaySelected: (selectedDate) {
              fetchHolidays(from: selectedDate, to: selectedDate);
            },
            onRangeSelected: (start, end) {
              fetchHolidays(from: start, to: end);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : holidays.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No events found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            if (todayEvents.isNotEmpty)
                              _buildEventSection(
                                  'Today\'s Events', todayEvents),
                            if (upcomingEvents.isNotEmpty)
                              _buildEventSection(
                                  'Upcoming Events', upcomingEvents),
                            if (pastEvents.isNotEmpty)
                              _buildEventSection('Past Events', pastEvents),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSection(String title, List<Holiday> events) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color getCardColor() {
      if (title.contains('Today')) {
        return isDarkMode ? Colors.blue.shade800 : Colors.blue.shade50;
      }
      if (title.contains('Upcoming')) {
        return isDarkMode ? Colors.green.shade700 : Colors.green.shade50;
      }
      return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200; // Past
    }

    Color getTextColor() => isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: getTextColor(),
            ),
          ),
        ),
        ...events.map((holiday) {
          final parsedDate = DateTime.parse(holiday.date);
          final formattedDate =
              '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          return Card(
            color: getCardColor(),
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                holiday.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getTextColor(),
                ),
              ),
              subtitle: Text(
                'Date: $formattedDate',
                style: TextStyle(color: getTextColor().withOpacity(0.8)),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
