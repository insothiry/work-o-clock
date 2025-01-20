import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/models/holiday_model.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_table_calender.dart';

class CalendarScreen extends StatefulWidget {
  CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Holiday> holidays = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchRoleFromPreferences();
    fetchHolidays();
  }

  // Fetch user role to check if they are admin
  Future<void> fetchRoleFromPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('role');
      if (role == 'admin') {
        setState(() {
          isAdmin = true;
        });
      }
    } catch (e) {
      print("Error fetching user role from preferences: $e");
    }
  }

  // Fetch holidays data
  Future<void> fetchHolidays() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url = 'http://localhost:3000/api/holidays/get-holidays';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final holidaysData = json.decode(response.body)['data'] as List;
        setState(() {
          holidays =
              holidaysData.map((holiday) => Holiday.fromJson(holiday)).toList();
        });
      } else {
        print("Failed to fetch holidays");
      }
    } catch (e) {
      print("Error fetching holidays: $e");
    }
  }

// Modify addHoliday to accept the title and date
  Future<void> addHoliday(String title, String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url = 'http://localhost:3000/api/holidays/add-holiday';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'name': title,
          'date': date,
        }),
      );

      if (response.statusCode == 201) {
        fetchHolidays();
        print("Holiday added: ${json.decode(response.body)['data']}");
      } else {
        print("Failed to add holiday");
      }
    } catch (e) {
      print("Error adding holiday: $e");
    }
  }

  void _addVacationDay(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 36,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Vacation Day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid date';
                      }
                      // Add basic date validation
                      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                      if (!regex.hasMatch(value)) {
                        return 'Enter date in YYYY-MM-DD format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() == true) {
                              addHoliday(
                                  titleController.text, dateController.text);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BaseColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // Calendar widget to select a date
          const BaseCalendar(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Upcoming Events',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 10),

          // Check if there are holidays
          holidays.isEmpty
              ? Center(
                  child: Text(
                    'No upcoming events',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];
                      // Parse the ISO8601 date string
                      final DateTime parsedDate = DateTime.parse(holiday.date);
                      // Format the date in "YYYY-MM-DD"
                      final String formattedDate =
                          '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';

                      return Card(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                holiday.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Date: $formattedDate',
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: BaseColors.primaryColor,
              onPressed: () => _addVacationDay(context),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
