import 'package:flutter/material.dart';
import 'package:work_o_clock/src/screens/register/company_register_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class AdminRegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AdminRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Registration',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BaseColors.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Indicator
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 12, color: BaseColors.primaryColor),
                  SizedBox(width: 8),
                  Icon(Icons.circle, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your last name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your password'
                          : value.length < 6
                              ? 'Password must be at least 6 characters long'
                              : null,
                    ),
                    const SizedBox(height: 24),

                    // Next button
                    BaseButton(
                      text: 'Next',
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyRegisterScreen(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
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
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
