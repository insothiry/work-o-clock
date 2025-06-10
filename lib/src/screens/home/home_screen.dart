import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:work_o_clock/src/controller/home_controller.dart';
import 'package:work_o_clock/src/screens/home/request_leave.dart';
import 'package:work_o_clock/src/screens/home/request_ot.dart';
import 'package:work_o_clock/src/screens/rating/employee_rating.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeController controller = Get.put(HomeController());
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller.fetchSmartLeaveSuggestion();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    ever(controller.isClockedIn, (bool isIn) {
      if (isIn) {
        _startPulse();
      } else {
        _stopPulse();
      }
    });

    if (controller.isClockedIn.value) {
      _startPulse();
    }
  }

  void _startPulse() {
    if (!_pulseController.isAnimating) {
      _pulseController.forward();
    }
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Obx(() {
          return HomeAppBar(
            name: controller.name.value,
            position: 'Mobile Developer',
          );
        }),
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
                  Obx(() {
                    final suggestion = controller.leaveSuggestion.value;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: suggestion == null
                          ? Row(
                              key: const ValueKey("loading"),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/tiger-work.png',
                                  height: 60,
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.orange.shade600
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Analyzing your leave... "),
                                      SizedBox(width: 6),
                                      SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : suggestion.suggested
                              ? Row(
                                  key: const ValueKey("suggestion"),
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          border: Border.all(
                                              color: Colors.orange, width: 1),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "📅 Suggested Leave: ${suggestion.date != null ? DateFormat.yMMMMd().format(suggestion.date!) : ''}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              suggestion.suggestion ?? "",
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Image.asset(
                                      'assets/images/tiger-work.png',
                                      height: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey("motivation"),
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.green.shade700
                                              : Colors.green.shade100,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          border: Border.all(
                                              color: Colors.green, width: 1),
                                        ),
                                        child: Text(
                                          suggestion.suggestion ??
                                              suggestion.motivation ??
                                              "You're doing great!",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Image.asset(
                                      'assets/images/tiger-work.png',
                                      height: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                    );
                  }),
                  const SizedBox(height: 20.0),
                  Obx(() => _buildWorkTimeInfo()),
                  const SizedBox(height: 10.0),
                  Obx(
                    () => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: SizedBox(
                            height: 300.0,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: controller.locationFetched.value
                                    ? controller.currentLocation.value
                                    : const LatLng(11.5681, 104.8921),
                                initialZoom: 18.0,
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
                                Obx(() {
                                  return PolygonLayer(
                                    polygons: [
                                      Polygon(
                                        points: _generateCirclePoints(
                                          controller.currentLocation.value,
                                          controller.radius.value,
                                        ),
                                        color: Colors.blue.withOpacity(0.4),
                                        borderColor: Colors.blue,
                                        borderStrokeWidth: 2,
                                        isFilled: true,
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Obx(
                              () {
                                if (controller.isClockedIn.value) {
                                  return AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: _buildClockButton(),
                                  );
                                } else {
                                  return _buildClockButton();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    onTap: () => Get.to(() => const RequestLeaveScreen()),
                  ),
                  const SizedBox(height: 10.0),
                  _buildCard(
                    context,
                    icon: Icons.work,
                    text: 'Request OT',
                    onTap: () => Get.to(() => const RequestOvertimeScreen()),
                  ),
                  const SizedBox(height: 10.0),
                  _buildCard(
                    context,
                    icon: Icons.people,
                    text: 'Evaluate Teammate',
                    onTap: () => Get.to(() => const TeamEvaluationForm()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockButton() {
    return AnimatedContainer(
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
          controller.handleClockInOut();
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: controller.isClockedIn.value
              ? BaseColors.secondaryColor
              : BaseColors.primaryColor,
          padding: const EdgeInsets.all(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: Colors.white, size: 32),
            const SizedBox(height: 8.0),
            Obx(() => Text(
                  controller.isClockedIn.value ? 'Clock Out' : 'Clock In',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.blue.shade100;
    final iconColor = isDarkMode ? Colors.white : Colors.blue;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      elevation: 4.0,
      color: cardColor,
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        leading: Icon(icon, color: iconColor),
        trailing: Icon(Icons.arrow_forward, color: iconColor.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }

  List<LatLng> _generateCirclePoints(LatLng center, double radius) {
    const int pointsCount = 30;
    const double degreesPerPoint = 360 / pointsCount;
    const double earthRadius = 6378137.0;

    List<LatLng> points = [];
    for (int i = 0; i < pointsCount; i++) {
      double angle = degreesPerPoint * i;
      double radians = angle * pi / 180;
      double latOffset = (radius / earthRadius) * (180 / pi);
      double lngOffset = latOffset / cos(center.latitude * pi / 180);

      points.add(LatLng(
        center.latitude + (latOffset * sin(radians)),
        center.longitude + (lngOffset * cos(radians)),
      ));
    }

    return points;
  }

  Widget _buildWorkTimeInfo() {
    final firstClockInTime = controller.firstClockInTime.value;
    final firstClockOutTime = controller.firstClockOutTime.value;
    final secondClockInTime = controller.secondClockInTime.value;
    final secondClockOutTime = controller.secondClockOutTime.value;

    String formatTime(DateTime? time) {
      if (time == null) return "--:--";
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildClockRow(
          firstClockIn: formatTime(firstClockInTime),
          firstClockOut: formatTime(firstClockOutTime),
        ),
        _buildClockRow(
          firstClockIn: formatTime(secondClockInTime),
          firstClockOut: formatTime(secondClockOutTime),
        ),
        const SizedBox(height: 10.0),
        Text(
          "${DateFormat('EEEE, d MMMM, yyyy').format(DateTime.now())}",
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildClockRow(
      {required String firstClockIn, required String firstClockOut}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeContainer(firstClockIn, Colors.blue.shade50),
        const Icon(Icons.arrow_forward),
        _buildTimeContainer(firstClockOut, Colors.green.shade50),
      ],
    );
  }

  Widget _buildTimeContainer(String time, Color fallbackColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey.shade700 : fallbackColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        time,
        style: TextStyle(fontSize: 16.0, color: textColor),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
