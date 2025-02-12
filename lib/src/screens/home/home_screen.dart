import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:work_o_clock/src/controller/home_controller.dart';
import 'package:work_o_clock/src/screens/home/request_leave.dart';
import 'package:work_o_clock/src/screens/home/request_ot.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        name: controller.name.string,
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
                              center: controller.locationFetched.value
                                  ? controller.currentLocation.value
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
                                markers: controller.locationFetched.value
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
                                circles: controller.locationFetched.value
                                    ? [
                                        CircleMarker(
                                          point:
                                              controller.currentLocation.value,
                                          radius: controller.radius.value,
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
                                color: controller.isAnimatingBorder.value
                                    ? (controller.isClockedIn.value
                                        ? BaseColors.secondaryColor
                                        : Colors.transparent)
                                    : Colors.transparent,
                                width: 5,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                controller.toggleClockInOut();
                                if (controller.isClockedIn.value) {
                                  // _clockInRequest(
                                  //   _currentLocation.latitude,
                                  //   _currentLocation.longitude,
                                  // );
                                  controller.startBorderAnimation();
                                } else {
                                  controller.borderAnimationTimer!.cancel();
                                  // _clockOutRequest(
                                  //   _currentLocation.latitude,
                                  //   _currentLocation.longitude,
                                  // );
                                  setState(() {
                                    controller.isAnimatingBorder.isFalse;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(24),
                                primary: controller.isClockedIn.value
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
                                        controller.isClockedIn.value
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
                          controller.elapsedTimeString,
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
    final firstClockInTime = controller.firstClockInTime.value;
    final firstClockOutTime = controller.firstClockOutTime.value;
    final secondClockInTime = controller.secondClockInTime.value;
    final secondClockOutTime = controller.secondClockOutTime.value;

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
    String workTime = "Work Time: ${controller.elapsedTimeString}";

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
