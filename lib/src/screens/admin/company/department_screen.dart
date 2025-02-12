import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  Map<String, List<String>> departmentPositions = {};
  Map<String, String> departmentNames = {};
  bool isLoading = true;

  final TextEditingController _departmentNameController =
      TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

// Function to add a new job to a department
  Future<void> addJob(String jobTitle, String departmentId) async {
    const String url = 'http://localhost:3000/api/companies/jobs';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': jobTitle,
          'departmentId': departmentId,
        }),
      );

      if (response.statusCode == 201) {
        fetchDepartments(); // Refresh departments to display the new job
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job "$jobTitle" added to department')),
        );
      } else {
        throw Exception('Failed to add job');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding job: $e');
    }
  }

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Department data: $data");

        final List<dynamic> departments = data['departments'];

        Map<String, List<String>> fetchedPositions = {};
        Map<String, String> fetchedNames = {};

        for (var department in departments) {
          String id = department['department']['_id'];
          String name = department['department']['name'];

          List<String> jobs = [];
          for (var job in department['jobs']) {
            jobs.add(job['title']);
          }

          fetchedPositions[id] = jobs;
          fetchedNames[id] = name;
        }

        setState(() {
          departmentPositions = fetchedPositions;
          departmentNames = fetchedNames;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to add a new department
  Future<void> addDepartment(String departmentName) async {
    const String url = 'http://localhost:3000/api/companies/departments';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': departmentName,
        }),
      );

      if (response.statusCode == 201) {
        // Fetch updated departments after adding the new department
        fetchDepartments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department $departmentName added')),
        );
      } else {
        throw Exception('Failed to add department');
      }
    } catch (e) {
      _showErrorSnackBar('Error adding department: $e');
    }
  }

  // Show the bottom sheet to add a department
  void _showAddDepartmentBottomSheet() {
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
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Department',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _departmentNameController,
                decoration: const InputDecoration(
                  labelText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final newDepartment = _departmentNameController.text.trim();
                  if (newDepartment.isNotEmpty) {
                    addDepartment(newDepartment);
                    _departmentNameController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColors.primaryColor,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Show bottom sheet to add a job
  void _showAddJobBottomSheet(String departmentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Job',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jobTitleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final jobTitle = _jobTitleController.text.trim();
                  if (jobTitle.isNotEmpty) {
                    addJob(jobTitle, departmentId);
                    _jobTitleController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColors.primaryColor,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show error message in Snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : departmentPositions.isEmpty
              ? const Center(
                  child: Text(
                    'No departments available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: departmentPositions.keys.length,
                  itemBuilder: (context, index) {
                    final departmentId =
                        departmentPositions.keys.elementAt(index);
                    final departmentName =
                        departmentNames[departmentId] ?? 'Unknown';
                    final positions = departmentPositions[departmentId]!;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      child: ExpansionTile(
                        leading: const Icon(Icons.business, color: Colors.blue),
                        title: Text(departmentName),
                        children: [
                          ...positions.map((position) {
                            return ListTile(
                              leading:
                                  const Icon(Icons.work, color: Colors.black54),
                              title: Text(position),
                            );
                          }).toList(),
                          TextButton.icon(
                            onPressed: () {
                              print("Department id: $departmentId");
                              _showAddJobBottomSheet(departmentId);
                            },
                            icon: const Icon(Icons.add, color: Colors.blue),
                            label: const Text(
                              'Add Job',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BaseColors.primaryColor,
        onPressed: _showAddDepartmentBottomSheet,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
