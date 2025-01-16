import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalEmployees = 0;
  int totalDepartments = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      // Fetch total employees
      final userResponse = await http
          .get(Uri.parse('http://localhost:3000/api/users/get-users'));
      if (userResponse.statusCode == 200) {
        final usersData = json.decode(userResponse.body);
        setState(() {
          totalEmployees = usersData['totalUsers'] ?? 0;
        });
      }
      print("all employees $totalEmployees");

      // Fetch total departments
      final departmentResponse = await http.get(
          Uri.parse('http://localhost:3000/api/companies/get-departments'));
      if (departmentResponse.statusCode == 200) {
        final departmentsData = json.decode(departmentResponse.body);
        setState(() {
          totalDepartments = departmentsData['total'] ?? 0;
        });
      }
    } catch (e) {
      // Handle errors
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data')),
      );
    }
  }

  final List<Map<String, String>> activities = [
    {
      'name': 'Alice Wonderland',
      'activity': 'Pending Leave',
      'reason': 'Personal Reasons',
    },
    {
      'name': 'Rosie Rose',
      'activity': 'Leave Approved',
      'reason': 'Sick Leave',
    },
  ];

  final List<Map<String, String>> pendingRequests = [
    {
      'name': 'Jeon Jungkook',
      'activity': 'Pending Leave',
      'reason': 'Personal Reasons',
    },
  ];

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
      ),
      backgroundColor: BaseColors.primaryColor,
      body: SingleChildScrollView(
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
                        height: 250,
                        width: 250,
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
                          LegendItem(color: BaseColors.darkPink, text: 'Late'),
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
                          'Employees', totalEmployees.toString()),
                    ),
                    Expanded(
                      child: _buildInfoCard(
                          'Departments', totalDepartments.toString()),
                    ),
                    Expanded(
                      child: _buildInfoCard('Actives', '140'),
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
                ...activities.map(
                  (activity) => Card(
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
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/avatar5.jpg'),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${activity['name']} - ${activity['activity']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reason: ${activity['reason']}',
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
                  'Pending Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Display pending leave requests with Accept/Reject buttons
                ...pendingRequests.map((request) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${request['name']} - ${request['activity']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${request['reason']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Action for accepting leave
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${request['name']}\'s leave approved.'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: BaseColors.primaryColor),
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Action for rejecting leave
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${request['name']}\'s leave rejected.'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
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
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
