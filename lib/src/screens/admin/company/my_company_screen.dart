import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/screens/admin/company/department_screen.dart';
import 'package:work_o_clock/src/screens/admin/company/employee_screen.dart';
import 'package:work_o_clock/src/screens/admin/company/update_company_screen.dart';
import 'package:work_o_clock/src/screens/admin/company/update_location.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class MyCompanyScreen extends StatefulWidget {
  const MyCompanyScreen({Key? key}) : super(key: key);

  @override
  State<MyCompanyScreen> createState() => _MyCompanyScreenState();
}

class _MyCompanyScreenState extends State<MyCompanyScreen> {
  Map<String, dynamic>? companyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompanyDetails();
  }

  Future<void> fetchCompanyDetails() async {
    const String url = 'http://localhost:3000/api/companies/get-companies';

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
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> companies = data['companies'];
        if (companies.isNotEmpty) {
          setState(() {
            companyData = companies[0];
            isLoading = false;
          });
          print("Company details $companyData");
        } else {
          throw Exception('No companies found');
        }
      } else {
        throw Exception('Failed to load company details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  final List<Map<String, dynamic>> cardData = [
    {
      "icon": Icons.door_sliding,
      "title": "Departments",
      "onTap": () {
        Get.to(const DepartmentScreen());
      },
    },
    {
      "icon": Icons.people,
      "title": "Employees",
      "onTap": () {
        Get.to(const EmployeeScreen());
      },
    },
    {
      "icon": Icons.location_on,
      "title": "Locations",
      "onTap": () {
        Get.to(const UpdateLocationScreen());
      },
    },
    {
      "icon": Icons.assignment,
      "title": "Projects",
      "onTap": () {},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Company'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(const UpdateCompanyProfileScreen());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : companyData == null
              ? const Center(child: Text('Failed to load company details.'))
              : RefreshIndicator(
                  onRefresh: fetchCompanyDetails,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                AssetImage('assets/logos/work-logo.png'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            companyData?['name'] ?? 'Company Name',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyData?['industry'] ?? 'Industry',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            companyData?['website'] ?? 'Email',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyData?['contactNumber'] ?? 'Phone',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: cardData.length,
                            itemBuilder: (context, index) {
                              final data = cardData[index];
                              return _buildCard(
                                icon: data['icon'],
                                title: data['title'],
                                onTap: data['onTap'],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: BaseColors.primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
