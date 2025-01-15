import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

enum LeaveDuration { morning, afternoon, fullDay }

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({Key? key}) : super(key: key);

  @override
  RequestLeaveScreenState createState() => RequestLeaveScreenState();
}

class RequestLeaveScreenState extends State<RequestLeaveScreen> {
  final leaveTypes = ['Sick Leave', 'Casual Leave', 'Annual Leave'];
  String? selectedLeaveType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();
  LeaveDuration? selectedDuration = LeaveDuration.fullDay;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
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
              // Leave Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedLeaveType,
                hint: const Text('Select Leave Type'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLeaveType = newValue;
                  });
                },
                items: leaveTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Leave Type',
                  prefixIcon: const Icon(Icons.category),
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
              const SizedBox(height: 16),

              // Start Date Picker
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
                      ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
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

              // End Date Picker
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
                      ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
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

              // Leave Duration Radio Buttons
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

              // Reason TextField
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

              // Submit Button
              BaseButton(
                text: 'Submit Request',
                onPressed: () {
                  // Handle the submission logic here
                  Get.snackbar('Request Submitted',
                      'Your leave request has been submitted.',
                      snackPosition: SnackPosition.BOTTOM);
                },
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
