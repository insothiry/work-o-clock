import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/screens/admin/company/add_user_form.dart';
import 'package:work_o_clock/src/screens/admin/company/update_employee.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> departmentNames = [];
  Map<String, List<Map<String, String>>> departmentEmployees = {};
  List<Map<String, String>> allEmployees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

            List<Map<String, String>> employeeDetails = [];
            for (var user in users) {
              final userName = user['name'];
              final userId = user['_id'];
              final userPosition = user['position']['title'];

              employeeDetails.add({
                'name': '$userName - $userPosition',
                'id': userId,
              });
            }

            fetchedEmployees[departmentName] = employeeDetails;
            fetchedDepartmentNames.add(departmentName);
            allFetchedEmployees.addAll(employeeDetails);
          } else {
            throw Exception('Failed to load employees for $departmentName');
          }
        }

        if (mounted) {
          setState(() {
            departmentEmployees = fetchedEmployees;
            departmentNames = fetchedDepartmentNames;
            allEmployees = allFetchedEmployees;
            isLoading = false;

            _tabController = TabController(
              length: departmentNames.length + 1,
              vsync: this,
            );
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

  void _showAddUserBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddUserForm();
      },
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
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(employee['name'] ?? 'Unknown'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      Get.to(UpdateEmployeeScreen(employeeId: employee['id']!));
                    },
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${employee['name']} selected')),
                    );
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        bottom: isLoading
            ? null
            : TabBar(
                labelColor: BaseColors.primaryColor,
                indicatorColor: BaseColors.primaryColor,
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'All'),
                  ...departmentNames.map((department) => Tab(text: department)),
                ],
              ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeeList(allEmployees),
                ...departmentNames.map((department) =>
                    _buildEmployeeList(departmentEmployees[department] ?? [])),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BaseColors.primaryColor,
        onPressed: _showAddUserBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
