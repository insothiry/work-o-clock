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
    {'name': 'Sick Leave', 'value': LeaveTypes.sick, 'applicableDays': 15},
    {'name': 'Annual Leave', 'value': LeaveTypes.annual, 'applicableDays': 15},
    {'name': 'Unpaid Leave', 'value': LeaveTypes.unpaid, 'applicableDays': 0},
  ];

  LeaveTypes? selectedLeaveType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();
  LeaveDuration? selectedDuration = LeaveDuration.fullDay;
  double? sickBalance;
  double? annualBalance;
  double? unpaidBalance;

  @override
  void initState() {
    super.initState();
    _getUserData();
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

    // Debug log
    print("Retrieved Sick Balance: $sickBalance");
    print("Retrieved Annual Balance: $annualBalance");
    print("Retrieved Unpaid Balance: $unpaidBalance");
  }

  Future<void> submitLeaveRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
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

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        showSuccessDialog(context, 'Request submitted successfully.');
      } else {
        Get.snackbar('Error', 'Failed to submit the leave request.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error) {
      print('Error submitting leave request: $error');
      Get.snackbar('Error', 'Something went wrong, please try again later.',
          snackPosition: SnackPosition.BOTTOM);
    }
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

                    return Container(
                      margin:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 0.5),
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
                      ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
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
                        ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
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
