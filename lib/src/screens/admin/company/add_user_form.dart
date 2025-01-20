import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/widgets/base_button.dart';

class AddUserForm extends StatefulWidget {
  const AddUserForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

Map<String, List<Map<String, String>>> departmentJobs = {};
Map<String, String> departmentNames = {};
bool isLoading = true;

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  String? selectedDepartment;
  String? selectedJob;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> _addUser() async {
    const String url = 'http://localhost:3000/api/users/add-user';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (_formKey.currentState!.validate()) {
      final payload = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phone": phoneController.text,
        "dateOfBirth": dobController.text,
        "department": selectedDepartment,
        "job": selectedJob,
        "positionTitle": positionController.text
      };

      print("Add user: $payload ");

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User added successfully!')),
          );
        } else {
          throw Exception('Failed to add user');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
        final List<dynamic> departments = data['departments'];

        Map<String, List<Map<String, String>>> fetchedJobs = {};
        Map<String, String> fetchedNames = {};

        for (var department in departments) {
          String id = department['department']['_id'];
          String name = department['department']['name'];

          List<Map<String, String>> jobs = [];
          for (var job in department['jobs']) {
            jobs.add({
              'id': job['_id'],
              'title': job['title'],
            });
          }

          fetchedJobs[id] = jobs;
          fetchedNames[id] = name;
        }

        setState(() {
          departmentJobs = fetchedJobs;
          departmentNames = fetchedNames;
          isLoading = false;
        });

        print("Departments and jobs: $departmentJobs, $departmentNames");
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching departments: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add User',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                _buildTextField(
                  controller: phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: dobController,
                      label: 'Date of Birth',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        items: departmentNames.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                            selectedJob = null;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedJob,
                        items: selectedDepartment != null
                            ? departmentJobs[selectedDepartment]!
                                .map((job) => DropdownMenuItem(
                                      value:
                                          job['id'], // Use job ID as the value
                                      child: Text(job['title'] ?? ''),
                                    ))
                                .toList()
                            : [],
                        onChanged: (value) {
                          setState(() {
                            selectedJob = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Job',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: positionController,
                  label: 'Position',
                  icon: Icons.work,
                ),
                const SizedBox(height: 16),
                BaseButton(
                  onPressed: _addUser,
                  text: 'Add User',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator ??
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
