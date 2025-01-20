import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:work_o_clock/src/widgets/successful_widget.dart';

class RequestOvertimeScreen extends StatefulWidget {
  const RequestOvertimeScreen({super.key});

  @override
  _RequestOvertimeScreenState createState() => _RequestOvertimeScreenState();
}

class _RequestOvertimeScreenState extends State<RequestOvertimeScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the date field with today's date
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    dateController.dispose();
    durationController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> submitOvertimeRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    const String url = 'http://localhost:3000/api/overtimes/request-overtime';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final String date = dateController.text;
    final String durationText = durationController.text;
    final String reason = reasonController.text;

    if (durationText.isEmpty || reason.isEmpty) {
      Get.snackbar('Error', 'All fields are required.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    final int? duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      Get.snackbar('Error', 'Please enter a valid duration.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    final body = {
      "date": date,
      "hours": duration,
      "reason": reason,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        showSuccessDialog(context, 'Request submitted successfully.');

        // Clear the fields after successful submission
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
          durationController.clear();
          reasonController.clear();
        });
      } else {
        Get.snackbar('Error', 'Failed to submit the request. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Overtime',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: BaseColors.primaryColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      dateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Duration (Hours)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: durationController,
                decoration: InputDecoration(
                  hintText: 'Enter duration',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason for Overtime',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Submit Button
              BaseButton(
                text: 'Submit Request',
                onPressed: submitOvertimeRequest,
                backgroundColor: BaseColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
