import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:work_o_clock/src/widgets/base_text_form_field.dart';

class UpdateCompanyProfileScreen extends StatefulWidget {
  const UpdateCompanyProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateCompanyProfileScreen> createState() =>
      _UpdateCompanyProfileScreenState();
}

class _UpdateCompanyProfileScreenState
    extends State<UpdateCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _workStartController = TextEditingController();
  final TextEditingController _workEndController = TextEditingController();

  // This function will fetch company data from your backend
  Future<void> _fetchCompanyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    try {
      final url =
          Uri.parse('http://localhost:3000/api/companies/get-companies');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        // Parse the company data from the response
        final data = jsonDecode(response.body);
        final company = data['companies'][0];

        // Update the controllers with the current company data
        setState(() {
          _companyNameController.text = company['name'];
          _industryController.text = company['industry'];
          _emailController.text = company['website'];
          _phoneController.text = company['contactNumber'];
          _workStartController.text = company['workingHours']['start'];
          _workEndController.text = company['workingHours']['end'];
        });
      } else {
        // Handle error case (show message to user)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch company data')),
        );
      }
    } catch (error) {
      // Handle network errors or other issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCompanyData(); // Fetch the company data when the screen is loaded
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Create a map of the profile data
      final workStart = _workStartController.text;
      final workEnd = _workEndController.text;

      // Create a map of the profile data
      final updatedData = {
        'companyName': _companyNameController.text,
        'industry': _industryController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'workingHours': {
          'start': workStart,
          'end': workEnd,
        },
      };

      // Simulate sending the data to the backend
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      try {
        final url =
            Uri.parse('http://localhost:3000/api/companies/update-company');
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(updatedData),
        );
        if (response.statusCode == 200) {
          // Simulate a successful update response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Company profile updated successfully')),
          );
          Get.back();
        } else {
          // Handle error case (show message to user)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update company profile')),
          );
        }
      } catch (error) {
        // Handle network errors or other issues
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay initialTime = isStart
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 17, minute: 0);

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      String formattedTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _workStartController.text = formattedTime;
        } else {
          _workEndController.text = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Company Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseTextFormField(
                  controller: _companyNameController,
                  labelText: 'Company Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BaseTextFormField(
                  controller: _industryController,
                  labelText: 'Industry',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the industry';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BaseTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BaseTextFormField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, true),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _workStartController,
                            label: 'Work Start Time',
                            icon: Icons.access_time_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select work start time'
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, false),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _workEndController,
                            label: 'Work End Time',
                            icon: Icons.access_time_outlined,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select work end time'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BaseButton(
                  text: 'Update Profile',
                  onPressed: _updateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _workStartController.dispose();
    _workEndController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
