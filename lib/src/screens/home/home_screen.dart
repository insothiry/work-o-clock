import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/controller/notification_controller.dart';
import 'package:work_o_clock/src/screens/home/request_leave.dart';
import 'package:work_o_clock/src/screens/home/request_ot.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/home_appbar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  var elapsedTime = Duration.zero.obs;
  var isClockedIn = false.obs;
  var clockInCount = 0.obs;
  var clockOutCount = 0.obs;
  var firstClockInTime = Rxn<DateTime>();
  var firstClockOutTime = Rxn<DateTime>();
  var secondClockInTime = Rxn<DateTime>();
  var secondClockOutTime = Rxn<DateTime>();

  late Timer _borderAnimationTimer;
  bool _isAnimatingBorder = false;
  late LatLng _currentLocation;
  double _radius = 200.0;
  bool _locationFetched = false;
  String name = '';
  String userToken = '';
  final SocketService _socketService = SocketService();

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? 'N/A';
      userToken = prefs.getString('token') ?? '';
    });
    print("userToken: " + userToken);
  }

  @override
  void initState() {
    super.initState();
    final socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': userToken},
    });
    Get.put(NotificationController(socket));

    _initializeData();
    _startBorderAnimation();
    _getUserLocation();
  }

  Future<void> _initializeData() async {
    await _getUserData();
    _connectToSocket();
  }

  @override
  void dispose() {
    _borderAnimationTimer.cancel();
    _socketService.disconnectSocket();
    super.dispose();
  }

  void _connectToSocket() {
    String token = userToken;
    _socketService.connectSocket(token);
  }

  // Fetch user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permission is denied.');
        return;
      }
    }

    setState(() {
      _currentLocation = LatLng(11.5681, 104.8921);
      _locationFetched = true;
    });
    print("Current loaction: " + _currentLocation.toString());
  }

  void _startBorderAnimation() {
    _borderAnimationTimer =
        Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (isClockedIn.value) {
        setState(() {
          _isAnimatingBorder = !_isAnimatingBorder;
        });
      } else {
        _borderAnimationTimer.cancel();
      }
    });
  }

  Future<void> _clockInRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-in";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar(context, "Clock-in successful!");
        print("Response: ${response.body}");
      } else {
        _showSnackBar(context, "Failed to clock in. Please try again.");
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _showSnackBar(context, "An error occurred: $e");
      print("Exception: $e");
    }
  }

  Future<void> _clockOutRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-out";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar(context, "Clock-out successful!");
        print("Response: ${response.body}");
      } else {
        _showSnackBar(context, "Failed to clock out. Please try again.");
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _showSnackBar(context, "An error occurred: $e");
      print("Exception: $e");
    }
  }

  void startTimer() {
    elapsedTime.value = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      elapsedTime.value += const Duration(minutes: 1);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void toggleClockInOut() {
    final currentTime = DateTime.now();

    if (!isClockedIn.value) {
      // Clock in logic
      if (clockInCount.value < 2) {
        if (clockOutCount.value > 0 || clockInCount.value == 0) {
          // Allow clocking in if clockOutCount is more than 0 (meaning clocked out at least once)
          isClockedIn.value = true;
          startTimer();
          clockInCount.value++;

          if (clockInCount.value == 1) {
            firstClockInTime.value = currentTime;
            print(
                "Clocked in at ${currentTime.toString()}. Total clock-ins: ${clockInCount.value}");
          } else if (clockInCount.value == 2) {
            secondClockInTime.value = currentTime;
            print(
                "Clocked in at ${currentTime.toString()}. Total clock-ins: ${clockInCount.value}");
          }

          _clockInRequest(
              _currentLocation.latitude, _currentLocation.longitude);
        } else {
          // If the user hasn't clocked out at all, show the message
          print("Please clock out first before clocking in.");
          _showSnackBar(
              context, "You cannot clock in again without clocking out.");
        }
      } else {
        print("You have already clocked in 2 times today.");
        _showSnackBar(context, "You have already clocked in 2 times today.");
      }
    } else {
      // Clock out logic
      if (clockOutCount.value < 2) {
        isClockedIn.value = false;
        stopTimer();
        clockOutCount.value++;

        if (clockOutCount.value == 1) {
          firstClockOutTime.value = currentTime;
          print(
              "Clocked out at ${currentTime.toString()}. Total clock-outs: ${clockOutCount.value}");
        } else if (clockOutCount.value == 2) {
          secondClockOutTime.value = currentTime;
          print(
              "Clocked out at ${currentTime.toString()}. Total clock-outs: ${clockOutCount.value}");
        }

        _clockOutRequest(_currentLocation.latitude,
            _currentLocation.longitude); // Call clock-out request
      } else {
        print("You have already clocked out 2 times today.");
        _showSnackBar(context, "You have already clocked out 2 times today.");
      }
    }
  }

  String get elapsedTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(elapsedTime.value.inHours);
    final minutes = twoDigits(elapsedTime.value.inMinutes.remainder(60));
    return "$hours:$minutes";
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    debugPrint("Snackbar displayed with message: $message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        name: name,
        position: 'Mobile Developer',
        imageUrl: 'assets/images/iu_pf.jpg',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "WorkO'Clock",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: BaseColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  _buildWorkTimeInfo(),
                  const SizedBox(height: 10.0),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 300.0,
                          child: FlutterMap(
                            options: MapOptions(
                              center: _locationFetched
                                  ? _currentLocation
                                  : const LatLng(11.5681, 104.8921),
                              zoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: _locationFetched
                                    ? [
                                        const Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: LatLng(11.5681, 104.8921),
                                          child: Icon(
                                            Icons.location_pin,
                                            color: BaseColors.primaryColor,
                                            size: 50,
                                          ),
                                        ),
                                      ]
                                    : [],
                              ),
                              CircleLayer(
                                circles: _locationFetched
                                    ? [
                                        CircleMarker(
                                          point: _currentLocation,
                                          radius: _radius,
                                          color: Colors.blue.withOpacity(0.4),
                                          borderStrokeWidth: 2,
                                          borderColor: Colors.blue,
                                        ),
                                      ]
                                    : [],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isAnimatingBorder
                                    ? (isClockedIn.value
                                        ? BaseColors.secondaryColor
                                        : Colors.transparent)
                                    : Colors.transparent,
                                width: 5,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                toggleClockInOut();
                                if (isClockedIn.value) {
                                  // _clockInRequest(
                                  //   _currentLocation.latitude,
                                  //   _currentLocation.longitude,
                                  // );
                                  _startBorderAnimation();
                                } else {
                                  _borderAnimationTimer.cancel();
                                  // _clockOutRequest(
                                  //   _currentLocation.latitude,
                                  //   _currentLocation.longitude,
                                  // );
                                  setState(() {
                                    _isAnimatingBorder = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(24),
                                primary: isClockedIn.value
                                    ? BaseColors.secondaryColor
                                    : BaseColors.primaryColor,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Obx(() => Text(
                                        isClockedIn.value
                                            ? 'Clock Out'
                                            : 'Clock In',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60.0),
                  Center(
                    child: Obx(() => Text(
                          elapsedTimeString,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20.0),
                  _buildCard(
                    context,
                    icon: Icons.time_to_leave,
                    text: 'Request Leave',
                    color: Colors.blue.shade100,
                    onTap: () => Get.to(() => const RequestLeaveScreen()),
                  ),
                  const SizedBox(height: 10.0),
                  _buildCard(
                    context,
                    icon: Icons.work,
                    text: 'Request OT',
                    color: Colors.blue.shade100,
                    onTap: () => Get.to(() => const RequestOvertimeScreen()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String text,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      color: color,
      child: ListTile(
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(icon, color: Colors.blue),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  // Function to display clock-in/out times and work time
  Widget _buildWorkTimeInfo() {
    final firstClockInTime = this.firstClockInTime.value;
    final firstClockOutTime = this.firstClockOutTime.value;
    final secondClockInTime = this.secondClockInTime.value;
    final secondClockOutTime = this.secondClockOutTime.value;

    // Default time if no clock-in/out
    String firstClockIn = firstClockInTime != null
        ? firstClockInTime.toLocal().toString().substring(11, 19)
        : "0:00";
    String firstClockOut = firstClockOutTime != null
        ? firstClockOutTime.toLocal().toString().substring(11, 19)
        : "0:00";
    String secondClockIn = secondClockInTime != null
        ? secondClockInTime.toLocal().toString().substring(11, 19)
        : "0:00";
    String secondClockOut = secondClockOutTime != null
        ? secondClockOutTime.toLocal().toString().substring(11, 19)
        : "0:00";

    // Display work time
    String workTime = "Work Time: ${elapsedTimeString}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // First Clock In/Out Container
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                firstClockIn,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),

            const Icon(Icons.arrow_forward),
            // Second Clock In/Out Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                firstClockOut,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),

        // First Clock In/Out Container
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                secondClockIn,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),

            const Icon(Icons.arrow_forward),
            // Second Clock In/Out Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                secondClockOut,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10.0),
        // Work Time Display
        Text(
          workTime,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
