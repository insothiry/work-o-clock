import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:work_o_clock/src/screens/attendance/attendance_detail_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<String> departmentNames = [];
  Map<String, List<Map<String, String>>> departmentEmployees = {};
  List<Map<String, String>> allEmployees = [];
  Map<String, String> employeeAttendanceStatus =
      {}; // To store attendance status for each employee
  bool isLoading = true;
  String selectedDepartment = 'All';

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    const String url = 'http://localhost:3000/api/companies/get-departments';
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final departments = data['departments'] ?? [];

        Map<String, List<Map<String, String>>> fetchedEmployees = {};
        List<String> fetchedDepartmentNames = [];
        List<Map<String, String>> allFetchedEmployees = [];

        for (var department in departments) {
          String departmentId = department['department']['_id'];
          String departmentName = department['department']['name'];

          // Get users for each department
          final employeeResponse = await http.post(
            Uri.parse(
                'http://localhost:3000/api/users/get-users?department=$departmentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (employeeResponse.statusCode == 200) {
            final employeeData = jsonDecode(employeeResponse.body);
            final users = employeeData['users'];

            List<Map<String, String>> employeeList = [];
            for (var user in users) {
              final userName = user['name'];
              final userId = user['_id'];

              // Store both name and ID as a map
              final Map<String, String> employeeData = {
                'name': userName as String,
                'id': userId as String,
              };

              employeeList.add(employeeData);
              allFetchedEmployees.add(employeeData);
            }

            fetchedEmployees[departmentName] = employeeList;
            fetchedDepartmentNames.add(departmentName);
          } else {
            throw Exception('Failed to load employees for $departmentName');
          }
        }

        // Now fetch attendance records
        await fetchAttendanceRecords(token);

        if (mounted) {
          setState(() {
            departmentEmployees = fetchedEmployees;
            departmentNames = fetchedDepartmentNames;
            allEmployees = allFetchedEmployees;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fetch attendance records and update the status
  Future<void> fetchAttendanceRecords(String? token) async {
    const String attendanceUrl =
        'http://localhost:3000/api/attendances/records/';

    try {
      final response = await http.get(
        Uri.parse(attendanceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attendanceRecords = data['attendanceRecords'] ?? [];
        print("Attendance records $attendanceRecords");

        // Map the attendance status to each employee
        for (var record in attendanceRecords) {
          final employeeName = record['user']['name'];
          final status = record['status'];

          setState(() {
            employeeAttendanceStatus[employeeName] = status;
          });
        }
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // Get today's date in the desired format
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Date: $todayDate",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: ['All', ...departmentNames]
                            .map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDepartment = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh:
                        fetchDepartments, // Call the existing fetch logic
                    child: _buildEmployeeList(selectedDepartment == 'All'
                        ? allEmployees
                        : departmentEmployees[selectedDepartment] ?? []),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmployeeList(List<Map<String, String>> employees) {
    return employees.isEmpty
        ? const Center(
            child: Text(
              'No employees in this department',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final employeeName = employee['name']!;
              final employeeId = employee['id']!;
              final status =
                  employeeAttendanceStatus[employeeName] ?? 'No record';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(employeeName),
                  trailing: Text(
                    status, // Show attendance status (e.g., "late", "No record")
                    style: TextStyle(
                      color: status == 'late'
                          ? Colors.red
                          : status == 'No record'
                              ? Colors.grey
                              : Colors.green,
                    ),
                  ),
                  onTap: () {
                    // Navigate to detail screen with employee ID
                    Get.to(
                      AttendanceDetailScreen(employeeId: employeeId),
                    );
                  },
                ),
              );
            },
          );
  }
}
