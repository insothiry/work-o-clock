import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController locationController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();

  LatLng? selectedLocation;

  @override
  void dispose() {
    locationController.dispose();
    radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Update Company Location',
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
                      const Text(
                        'Select your company location',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: radiusController,
                        label: 'Location Radius (in meters)',
                        icon: Icons.circle_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              center: const LatLng(11.5465, 104.9403),
                              zoom: 18,
                              onTap: (tapPosition, location) {
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
                                          100.0, // Default radius
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your company location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BaseButton(
                        text: 'Update',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Handle update logic
                            final location = locationController.text;
                            final radius = radiusController.text;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Updated Location: $location, Radius: $radius meters',
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
