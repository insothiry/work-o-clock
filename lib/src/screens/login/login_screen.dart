import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/screens/bottom_navigation/admin_bottom_navigation.dart';
import 'package:work_o_clock/src/screens/bottom_navigation/bottom_navigation.dart';
import 'package:work_o_clock/src/screens/register/register_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> login(BuildContext context) async {
    const String url = 'http://localhost:3000/api/auth/login';
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("mi jkj: $data");

        final String token = data['token'];
        final String role = data['user']['role'];

        // Save token and user details locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userId', data['user']['id']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setString('companyId', data['user']['company']);

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminBottomNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()),
          );
        }
      } else {
        _showErrorSnackBar(context, 'Invalid credentials.');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'An error occurred. Please try again.');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/login-img.jpg'),

              // Title
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BaseColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Log in to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

                    // Password field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Incorrect Password!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    BaseButton(
                      text: 'Login',
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          login(context);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to Forgot Password screen
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: BaseColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Divider(
                      indent: 12,
                    ),

                    const Center(
                      child: Text('Or'),
                    ),

                    // Navigate to Admin Register
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminRegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register as Admin',
                          style: TextStyle(
                            color: BaseColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
