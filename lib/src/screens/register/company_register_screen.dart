import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:work_o_clock/src/screens/bottom_navigation/admin_bottom_navigation.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class CompanyRegisterScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  CompanyRegisterScreen({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  _CompanyRegisterScreenState createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController establishedYearController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController workStartController = TextEditingController();
  final TextEditingController workEndController = TextEditingController();

  LatLng? selectedLocation;

  // Function to show time picker and set selected time
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay initialTime = isStart
        ? TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: 17, minute: 0);

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
          workStartController.text = formattedTime;
        } else {
          workEndController.text = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Company Details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BaseColors.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 12, color: Colors.grey),
                    SizedBox(width: 8),
                    Icon(Icons.circle,
                        size: 12, color: BaseColors.primaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: companyNameController,
                        label: 'Company Name',
                        icon: Icons.business_outlined,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your company name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: industryController,
                        label: 'Industry',
                        icon: Icons.work_outline,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your industry'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: contactNumberController,
                        label: 'Contact Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your contact number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: websiteController,
                        label: 'Website',
                        icon: Icons.web_outlined,
                        keyboardType: TextInputType.url,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your website'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: establishedYearController,
                        label: 'Established Year',
                        icon: Icons.date_range,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your established year'
                            : null,
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
                                  controller: workStartController,
                                  label: 'Work Start Time',
                                  icon: Icons.access_time_outlined,
                                  validator: (value) =>
                                      value == null || value.isEmpty
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
                                  controller: workEndController,
                                  label: 'Work End Time',
                                  icon: Icons.access_time_outlined,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please select work end time'
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Select your company location',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: radiusController,
                        label: 'Location Radius (in meters)',
                        icon: Icons.date_range,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location radius';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              center: const LatLng(11.5465, 104.9403),
                              zoom: 13,
                              onTap: (tapPosition, LatLng location) {
                                setState(() {
                                  selectedLocation = location;
                                  locationController.text =
                                      '${location.latitude}, ${location.longitude}';
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              if (selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: selectedLocation!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: BaseColors.primaryColor,
                                        size: 48,
                                      ),
                                    ),
                                  ],
                                ),
                              if (selectedLocation != null)
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: selectedLocation!,
                                      radius: double.tryParse(
                                              radiusController.text) ??
                                          100.0, // Default to 100 if empty
                                      color: BaseColors.primaryColor
                                          .withOpacity(0.5),
                                      borderStrokeWidth: 2.0,
                                      borderColor: BaseColors.primaryColor,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: locationController,
                        label: 'Company location (Lat, Long)',
                        icon: Icons.location_pin,
                        keyboardType: TextInputType.text,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select your company location'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      BaseButton(
                        text: 'Register',
                        onPressed: () async {
                          if (_formKey.currentState?.validate() == true &&
                              selectedLocation != null) {
                            double radius =
                                double.tryParse(radiusController.text) ?? 100.0;

                            Map<String, dynamic> registrationData = {
                              'userName':
                                  '${widget.firstName} ${widget.lastName}',
                              'email': widget.email,
                              'password': widget.password,
                              'companyName': companyNameController.text,
                              'industry': industryController.text,
                              'contactNumber': contactNumberController.text,
                              'website': websiteController.text,
                              'establishedYear': int.tryParse(
                                      establishedYearController.text) ??
                                  0,
                              'workHours': {
                                'start': workStartController.text,
                                'end': workEndController.text,
                              },
                              'companyAddress': {
                                'centerLatitude': selectedLocation!.latitude,
                                'centerLongitude': selectedLocation!.longitude,
                                'radius': radius,
                              },
                            };

                            String jsonData = json.encode(registrationData);

                            try {
                              // Send POST request
                              final response = await http.post(
                                Uri.parse(
                                    'http://localhost:3000/api/auth/register'),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: jsonData,
                              );

                              // Handle the response
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                print(
                                    'Registration successful: ${response.body}');
                                Get.offAll(const AdminBottomNavigation());
                              } else {
                                print('Registration failed: ${response.body}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Registration failed: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('An error occurred: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please complete all fields and select a location'),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
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
