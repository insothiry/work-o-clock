import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:work_o_clock/src/widgets/successful_widget.dart';

class UpdateLocationScreen extends StatefulWidget {
  const UpdateLocationScreen({Key? key}) : super(key: key);

  @override
  State<UpdateLocationScreen> createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  LatLng? selectedLocation;

  // Fetch location data from the backend
  Future<void> _fetchLocationData() async {
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
        final data = jsonDecode(response.body);
        final company = data['companies'][0];
        final geofence = company['geofence'];

        setState(() {
          // Populate the controllers with the fetched geofence data
          _latitudeController.text = geofence['centerLatitude'].toString();
          _longitudeController.text = geofence['centerLongitude'].toString();
          _radiusController.text = geofence['radius'].toString();

          // Set the map's initial location based on the fetched coordinates
          selectedLocation =
              LatLng(geofence['centerLatitude'], geofence['centerLongitude']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch company data')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
  }

  // Update the location when the form is submitted
  void _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      final updatedLocation = {
        'geofence': {
          'centerLatitude': double.tryParse(_latitudeController.text),
          'centerLongitude': double.tryParse(_longitudeController.text),
          'radius': double.tryParse(_radiusController.text),
        },
      };

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
          body: jsonEncode(updatedLocation),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const SuccessWidget(
                  message: 'Location updated successfully');
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update location')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: MapOptions(
                        center: selectedLocation ?? LatLng(11.5465, 104.9403),
                        zoom: 18,
                        onTap: (tapPosition, location) {
                          setState(() {
                            selectedLocation = location;
                            _latitudeController.text =
                                location.latitude.toString();
                            _longitudeController.text =
                                location.longitude.toString();
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
                                  color: Colors.red,
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
                                radius:
                                    double.tryParse(_radiusController.text) ??
                                        100.0,
                                color: Colors.red.withOpacity(0.5),
                                borderStrokeWidth: 2.0,
                                borderColor: Colors.red,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Center Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the latitude';
                    } else if (double.tryParse(value) == null) {
                      return 'Please enter a valid latitude';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Center Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the longitude';
                    } else if (double.tryParse(value) == null) {
                      return 'Please enter a valid longitude';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _radiusController,
                  decoration: const InputDecoration(
                    labelText: 'Radius (in meters)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the radius';
                    } else if (double.tryParse(value) == null) {
                      return 'Please enter a valid radius';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                BaseButton(text: 'Update Location', onPressed: _updateLocation)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
