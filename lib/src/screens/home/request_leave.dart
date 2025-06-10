// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:work_o_clock/src/widgets/successful_widget.dart';

enum LeaveDuration { morning, afternoon, fullDay }

enum LeaveTypes { sick, annual, unpaid }

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({Key? key}) : super(key: key);

  @override
  RequestLeaveScreenState createState() => RequestLeaveScreenState();
}

class RequestLeaveScreenState extends State<RequestLeaveScreen> {
  final leaveTypes = [
    {'name': 'Sick Leave', 'value': LeaveTypes.sick, 'applicableDays': 7},
    {'name': 'Annual Leave', 'value': LeaveTypes.annual, 'applicableDays': 15},
    {'name': 'Unpaid Leave', 'value': LeaveTypes.unpaid, 'applicableDays': 3},
  ];

  LeaveTypes? selectedLeaveType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();
  LeaveDuration? selectedDuration = LeaveDuration.fullDay;
  double? sickBalance;
  double? annualBalance;
  double? unpaidBalance;

  bool leaveTypeError = false;
  bool reasonError = false;
  bool dateError = false;

  @override
  void initState() {
    super.initState();
    fetchAndSetUserLeaveBalances();
    startDate = DateTime.now();
    endDate = DateTime.now();
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sickBalance = prefs.getDouble('sick');
      annualBalance = prefs.getDouble('annual');
      unpaidBalance = prefs.getDouble('unpaid');
    });
  }

  Future<void> submitLeaveRequest() async {
    setState(() {
      leaveTypeError = selectedLeaveType == null;
      reasonError = reasonController.text.trim().isEmpty;
      dateError = startDate == null || endDate == null;
    });

    if (leaveTypeError || reasonError || dateError) {
      Get.snackbar('Error', 'Please fill in all required fields.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userId = prefs.getString('userId');

    if (selectedLeaveType == null) {
      Get.snackbar('Error', 'Please select a leave type.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final url = Uri.parse('http://localhost:3000/api/leaves/request-leave');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final requestBody = {
      'leaveType': selectedLeaveType.toString().split('.').last,
      'startDate':
          startDate != null ? startDate!.toString().substring(0, 10) : '',
      'endDate': endDate != null ? endDate!.toString().substring(0, 10) : '',
      'duration': selectedDuration == LeaveDuration.morning
          ? 'morning'
          : selectedDuration == LeaveDuration.afternoon
              ? 'afternoon'
              : 'full',
      'reason': reasonController.text,
    };

    print(requestBody);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        // ✅ Refresh leave balances
        final userRes = await http.get(
          Uri.parse('http://localhost:3000/api/users/get-user/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (userRes.statusCode == 200) {
          final userData = json.decode(userRes.body)['user'];
          await prefs.setDouble(
              'sick', userData['leaveBalance']['sick']?.toDouble() ?? 0.0);
          await prefs.setDouble(
              'annual', userData['leaveBalance']['annual']?.toDouble() ?? 0.0);
          await prefs.setDouble(
              'unpaid', userData['leaveBalance']['unpaid']?.toDouble() ?? 0.0);

          await fetchAndSetUserLeaveBalances();
        }

        showSuccessDialog(context, 'Request submitted successfully.');
      }
    } catch (error) {
      print('Error submitting leave request: $error');
      Get.snackbar('Error', 'Something went wrong, please try again later.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchAndSetUserLeaveBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userId = prefs.getString('userId');

    final userRes = await http.get(
      Uri.parse('http://localhost:3000/api/users/get-user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(token);
    print(userRes.statusCode);
    print(userId);

    if (userRes.statusCode == 200) {
      final userData = json.decode(userRes.body)['user'];
      final leave = userData['leaveBalance'];

      setState(() {
        sickBalance = leave['sick']?.toDouble() ?? 0.0;
        annualBalance = leave['annual']?.toDouble() ?? 0.0;
        unpaidBalance = leave['unpaid']?.toDouble() ?? 0.0;
      });
    } else {
      print('⚠️ Failed to fetch user leave balance');
    }

    print('sick: $sickBalance, annual: $annualBalance, unpaid: $unpaidBalance');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Leave',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: BaseColors.primaryColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Leave Type",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(leaveTypes.length, (index) {
                    var leaveType = leaveTypes[index];
                    double? balance;

                    if (leaveType['value'] == LeaveTypes.sick) {
                      balance = sickBalance;
                    } else if (leaveType['value'] == LeaveTypes.annual) {
                      balance = annualBalance;
                    } else if (leaveType['value'] == LeaveTypes.unpaid) {
                      balance = unpaidBalance;
                    }

                    final isSelected = selectedLeaveType == leaveType['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLeaveType = leaveType['value'] as LeaveTypes;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 10, right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: leaveTypeError
                                ? Colors.red
                                : isSelected
                                    ? BaseColors.primaryColor
                                    : Colors.black,
                            width:
                                leaveTypeError ? 1.5 : (isSelected ? 1.5 : 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<LeaveTypes>(
                                  value: leaveType['value'] as LeaveTypes,
                                  groupValue: selectedLeaveType,
                                  onChanged: (LeaveTypes? value) {
                                    setState(() {
                                      selectedLeaveType = value;
                                    });
                                  },
                                ),
                                Text(leaveType['name'] as String),
                              ],
                            ),
                            Text('Balance: $balance days'),
                            Text('Full: ${leaveType['applicableDays']} days'),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.5),
                  ),
                ),
                controller: TextEditingController(
                  text: startDate != null
                      ? "${startDate!.year} - ${startDate!.month.toString().padLeft(2, '0')} - ${startDate!.day.toString().padLeft(2, '0')}"
                      : '',
                ),
                onTap: () async {
                  final pickedDate = await _selectDate(context);
                  if (pickedDate != null) {
                    setState(() {
                      startDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (selectedDuration == LeaveDuration.fullDay) ...[
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.5),
                    ),
                  ),
                  controller: TextEditingController(
                    text: endDate != null
                        ? "${endDate!.year} - ${endDate!.month.toString().padLeft(2, '0')} - ${endDate!.day.toString().padLeft(2, '0')}"
                        : '',
                  ),
                  onTap: () async {
                    final pickedDate = await _selectDate(context);
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Leave for",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Radio<LeaveDuration>(
                              value: LeaveDuration.morning,
                              groupValue: selectedDuration,
                              onChanged: (LeaveDuration? value) {
                                setState(() {
                                  selectedDuration = value;
                                  endDate = startDate;
                                });
                              },
                            ),
                            const Text("Morning"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<LeaveDuration>(
                              value: LeaveDuration.afternoon,
                              groupValue: selectedDuration,
                              onChanged: (LeaveDuration? value) {
                                setState(() {
                                  selectedDuration = value;
                                  endDate = startDate;
                                });
                              },
                            ),
                            const Text("Afternoon"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<LeaveDuration>(
                              value: LeaveDuration.fullDay,
                              groupValue: selectedDuration,
                              onChanged: (LeaveDuration? value) {
                                setState(() {
                                  selectedDuration = value;
                                });
                              },
                            ),
                            const Text("Full Day"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for Leave',
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: reasonError ? 'This field is required' : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: reasonError ? Colors.red : Colors.black,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: reasonError ? Colors.red : Colors.black,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BaseButton(
                text: 'Submit Request',
                onPressed: submitLeaveRequest,
                backgroundColor: BaseColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }
}
