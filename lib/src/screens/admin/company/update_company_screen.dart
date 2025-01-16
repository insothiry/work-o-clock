import 'package:flutter/material.dart';
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

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _workStartController = TextEditingController();
  final TextEditingController _workEndController = TextEditingController();

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Perform the profile update logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile updated successfully')),
      );
    }
  }

  // Function to show time picker and set selected time
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay initialTime = isStart
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 17, minute: 0);

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      // Format the time in "HH:mm" format (24-hour clock)
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
                // Company Information Fields
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
                const SizedBox(height: 16),

                // Work hours fields in the same row with time scroll
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

                // Password Fields
                BaseTextFormField(
                  controller: _currentPasswordController,
                  labelText: 'Current Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                BaseTextFormField(
                  controller: _newPasswordController,
                  labelText: 'New Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                BaseTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm New Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    } else if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _industryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _workStartController.dispose();
    _workEndController.dispose();
    super.dispose();
  }
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
