import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalEmployees = 0;
  int totalDepartments = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> pendingRequestsOT = [];
  List<Map<String, dynamic>> approvedOTRequests = [];
  List<Map<String, dynamic>> activities = [];
  List<Map<String, dynamic>> approvedLeaveRequests = [];
  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> allOTRequests = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    fetchAllRequests();
    fetchAllOTRequests();
  }

  String _formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchDashboardData() async {
    try {
      // Fetch total employees
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      const String url = 'http://localhost:3000/api/users/get-users';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final userResponse = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (userResponse.statusCode == 200) {
        final usersData = json.decode(userResponse.body);
        setState(() {
          totalEmployees = usersData['totalUsers'] ?? 0;
        });
      }
      print("all employees $totalEmployees");

      // Fetch total departments
      final departmentResponse = await http.get(
        Uri.parse('http://localhost:3000/api/companies/get-departments'),
        headers: headers,
      );
      if (departmentResponse.statusCode == 200) {
        final departmentsData = json.decode(departmentResponse.body);
        print("total departments $departmentsData");
        setState(() {
          totalDepartments = departmentsData['totalDepartments'] ?? 0;
        });
      } else
        print("total departmentssss");
    } catch (e) {
      // Handle errors
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data')),
      );
    }
  }

  Future<void> fetchAllRequests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url =
          'http://localhost:3000/api/leaves/get-all-leave-requests';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          allRequests = List<Map<String, dynamic>>.from(jsonData['data']);
        });
        print("All requests: ${pendingRequests.toString()}");
        filterApprovedRequests();
        filterPendingRequests();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  void filterApprovedRequests() {
    setState(() {
      approvedLeaveRequests = allRequests
          .where((request) => request['status'] == 'approved')
          .toList();
    });
  }

  void filterPendingRequests() {
    setState(() {
      pendingRequests = allRequests
          .where((request) => request['status'] == 'pending')
          .toList();
    });
  }

  void filterApprovedOTRequests() {
    setState(() {
      approvedOTRequests = allOTRequests
          .where((request) => request['status'] == 'approved')
          .toList();
    });
  }

  void filterPendingOTRequests() {
    setState(() {
      pendingRequestsOT = allOTRequests
          .where((request) => request['status'] == 'pending')
          .toList();
    });
  }

  Future<void> fetchAllOTRequests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url =
          'http://localhost:3000/api/overtimes/get-all-overtime-requests';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          allOTRequests = List<Map<String, dynamic>>.from(jsonData['data']);
        });
        filterApprovedOTRequests();
        filterPendingOTRequests();
        print("Pending requests: ${allOTRequests.toString()}");
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  Future<void> acceptLeaveRequest(String leaveId) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url =
          'http://localhost:3000/api/leaves/accept-leave/$leaveId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchAllRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave approved'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Error accepting leave request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error accepting leave request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> acceptOTRequest(String overtimeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String url =
          'http://localhost:3000/api/overtimes/accept-overtime/$overtimeId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchAllOTRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Overtime approved'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Error accepting overtime request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error accepting overtime request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: BaseColors.primaryColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchDashboardData();
          await fetchAllRequests();
          await fetchAllOTRequests();
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
                            'Employees', totalEmployees.toString()),
                      ),
                      Expanded(
                        child: _buildInfoCard(
                            'Departments', totalDepartments.toString()),
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
                  ...approvedLeaveRequests.map(
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
                  ...approvedOTRequests.map(
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

                  if (_isLoading)
                    Container(
                      color: BaseColors.primaryColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (pendingRequests.isEmpty)
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
                    ...pendingRequests.map((request) => RequestCard(
                          userName: request['user']['name'],
                          status: request['status'],
                          reason: request['reason'],
                          duration: request['duration'],
                          startDate: _formatDate(request['startDate']),
                          endDate: _formatDate(request['endDate']),
                          leaveId: request['_id'],
                          onAccept: acceptLeaveRequest,
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
                  if (_isLoading)
                    Container(
                      color: BaseColors.primaryColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (pendingRequestsOT.isEmpty)
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
                    ...pendingRequestsOT.map((request) => RequestCard(
                          userName: request['user']['name'],
                          status: request['status'],
                          reason: request['reason'],
                          duration: request['hours'].toString(),
                          startDate: _formatDate(request['date']),
                          endDate: _formatDate(request['date']),
                          leaveId: request['_id'],
                          onAccept: acceptOTRequest,
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

// Widget for displaying a single request
class RequestCard extends StatelessWidget {
  final String userName;
  final String status;
  final String reason;
  final String duration;
  final String startDate;
  final String endDate;
  final String leaveId; // Add leaveId to the constructor
  final Function(String) onAccept; // Callback for accepting leave

  const RequestCard({
    Key? key,
    required this.userName,
    required this.status,
    required this.reason,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.leaveId, // Initialize leaveId
    required this.onAccept, // Initialize callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '$userName - $status',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: $reason',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Duration: $duration',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'From: $startDate to $endDate',
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
                    onAccept(leaveId);
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
                    // Reject action
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
    );
  }
}
