import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:work_o_clock/src/controller/dashboard_controller.dart';
import 'package:work_o_clock/src/models/request_card_model.dart';
import 'package:work_o_clock/src/screens/notifications/notification_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome, Admin!',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: BaseColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Get.to(const NotificationScreen());
            },
          ),
        ],
      ),
      backgroundColor: BaseColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchDashboardData();
          await controller.fetchAllRequests();
          await controller.fetchAllOTRequests();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Attendance Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card for attendance statistics
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pie Chart
                        SizedBox(
                          height: 230,
                          width: 230,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: BaseColors.lightBlue,
                                  value: 60,
                                  title: '60%',
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  color: BaseColors.darkPurple,
                                  value: 30,
                                  title: '30%',
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  color: BaseColors.darkPink,
                                  value: 10,
                                  title: '10%',
                                  radius: 50,
                                ),
                              ],
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LegendItem(
                                color: BaseColors.lightBlue, text: 'Present'),
                            SizedBox(height: 8),
                            LegendItem(
                                color: BaseColors.darkPurple, text: 'Leave'),
                            SizedBox(height: 8),
                            LegendItem(
                                color: BaseColors.darkPink, text: 'Late'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Total Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                            'Employees', controller.totalEmployees.toString()),
                      ),
                      Expanded(
                        child: _buildInfoCard('Departments',
                            controller.totalDepartments.toString()),
                      ),
                      Expanded(
                        child: _buildInfoCard('Positions', '140'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display leave activities
                  ...controller.approvedLeaveRequests.map(
                    (approvedLeaveRequests) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${approvedLeaveRequests['user']['name']} - Leave ${approvedLeaveRequests['status']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reason: ${approvedLeaveRequests['reason']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...controller.approvedOTRequests.map(
                    (approvedOTRequests) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${approvedOTRequests['user']['name']} - OT ${approvedOTRequests['status']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reason: ${approvedOTRequests['reason']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pending Leave Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display pending leave requests with Accept/Reject buttons

                  if (controller.isLoadingOT.value)
                    Container(
                      color: BaseColors.primaryColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.pendingRequests.isEmpty)
                    const Center(
                      child: Text(
                        "No leave requests",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...controller.pendingRequests.map((request) => RequestCard(
                          userName: request['user']['name'],
                          status: request['status'],
                          reason: request['reason'],
                          duration: request['duration'],
                          startDate:
                              controller.formatDate(request['startDate']),
                          endDate: controller.formatDate(request['endDate']),
                          leaveId: request['_id'],
                          onAccept: controller.acceptLeaveRequest,
                        )),
                  const SizedBox(height: 20),
                  const Text(
                    'Pending Overtime Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display pending OT requests
                  if (controller.isLoadingOT.value)
                    Container(
                      color: BaseColors.primaryColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.pendingRequestsOT.isEmpty)
                    const Center(
                      child: Text(
                        "No overtime requests",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...controller.pendingRequestsOT
                        .map((request) => RequestCard(
                              userName: request['user']['name'],
                              status: request['status'],
                              reason: request['reason'],
                              duration: request['hours'].toString(),
                              startDate: controller.formatDate(request['date']),
                              endDate: controller.formatDate(request['date']),
                              leaveId: request['_id'],
                              onAccept: controller.acceptOTRequest,
                            )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget to display legend items
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Function to build individual cards
Widget _buildInfoCard(String title, String data) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
    child: Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BaseColors.primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            data,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
