import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OwnAttendanceScreen extends StatefulWidget {
  const OwnAttendanceScreen({super.key});

  @override
  State<OwnAttendanceScreen> createState() => _OwnAttendanceScreenState();
}

class _OwnAttendanceScreenState extends State<OwnAttendanceScreen> {
  Map<String, dynamic>? employee;
  List<Map<String, dynamic>> attendanceHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserAttendance();
  }

  Future<void> fetchUserAttendance() async {
    String url = 'http://localhost:3000/api/attendances/own-records';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attendanceRecords = data['data'] ?? [];

        if (attendanceRecords.isNotEmpty) {
          final user = attendanceRecords.first['user'];

          if (mounted) {
            setState(() {
              employee = user;
              attendanceHistory = attendanceRecords
                  .map<Map<String, dynamic>>((record) => {
                        'date': DateTime.parse(record['clockIn'])
                            .toLocal()
                            .toString()
                            .split(' ')[0], // Extract date
                        'clockIn': DateTime.parse(record['clockIn'])
                            .toLocal()
                            .toString(), // Parse clockIn time
                        'clockOut': DateTime.parse(record['clockOut'])
                            .toLocal()
                            .toString(), // Parse clockOut time
                        'workHours': record['totalWorkHours']
                            .toString(), // Total work hours
                      })
                  .toList();
              isLoading = false;
            });
          }
        } else {
          throw Exception('No attendance records found');
        }
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee != null
            ? "${employee!['name']}'s Attendance"
            : 'Attendance Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employee == null
              ? const Center(child: Text('No employee data found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: Text(
                                employee!['name']![0],
                                style: const TextStyle(
                                    fontSize: 32, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              employee!['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const Text(
                        'History',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: attendanceHistory.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final history = attendanceHistory[index];
                            return ListTile(
                              title: Text(
                                history['date']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Clock-In: ${history['clockIn']}'),
                                  Text('Clock-Out: ${history['clockOut']}'),
                                  Text('Work Hours: ${history['workHours']}'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
