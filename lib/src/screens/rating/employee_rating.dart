import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class TeamEvaluationForm extends StatefulWidget {
  const TeamEvaluationForm({Key? key}) : super(key: key);

  @override
  State<TeamEvaluationForm> createState() => _TeamEvaluationFormState();
}

class _TeamEvaluationFormState extends State<TeamEvaluationForm> {
  String? selectedMember;
  double punctuality = 5;
  double collaboration = 5;
  double workQuality = 5;
  double communication = 5;
  final commentController = TextEditingController();

  List<Map<String, dynamic>> teamMembers = [];
  String? departmentId;
  String? userId;
  String? token;

  bool? isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartmentAndFetchMembers();
  }

  Future<void> _loadDepartmentAndFetchMembers() async {
    final pref = await SharedPreferences.getInstance();
    departmentId = pref.getString('departmentId');
    userId = pref.getString('userId');
    token = pref.getString('token');

    if (departmentId != null && token != null) {
      await _fetchTeamMembers(departmentId!, token!);
    } else {
      Get.snackbar('Error', 'Missing login information. Please login again.');
    }
  }

  Future<void> _fetchTeamMembers(String departmentId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/api/users/users/department/$departmentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List;

        setState(() {
          teamMembers = users
              .where((user) => user['_id'] != userId)
              .map<Map<String, dynamic>>((user) {
            return {
              'id': user['_id'],
              'name': user['name'],
              'email': user['email'],
            };
          }).toList();
        });
      } else {
        Get.snackbar('Error', 'Failed to fetch team members.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Member Evaluation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Team Member",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMember,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a member',
                ),
                items: teamMembers.map<DropdownMenuItem<String>>((member) {
                  return DropdownMenuItem<String>(
                    value: member['id'] as String, // 🔥 make sure it's String
                    child: Text(member['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMember = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSlider("Punctuality", punctuality, (value) {
                setState(() => punctuality = value);
              }),
              _buildSlider("Collaboration", collaboration, (value) {
                setState(() => collaboration = value);
              }),
              _buildSlider("Work Quality", workQuality, (value) {
                setState(() => workQuality = value);
              }),
              _buildSlider("Communication", communication, (value) {
                setState(() => communication = value);
              }),
              const SizedBox(height: 24),
              const Text(
                "Additional Comments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Write your comments...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              BaseButton(
                text: 'Submit Evaluation',
                onPressed: _submitEvaluation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
      String title, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submitEvaluation() async {
    if (selectedMember == null) {
      Get.snackbar('Error', 'Please select a team member to evaluate');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'Missing token. Please login again.');
      return;
    }

    final url = Uri.parse('http://localhost:3000/api/evaluate/add-evaluation');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'evaluatedUserId': selectedMember,
          'punctuality': punctuality,
          'collaboration': collaboration,
          'workQuality': workQuality,
          'communication': communication,
          'comment': commentController.text,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Evaluation submitted successfully ✅');

        // Clear form first
        setState(() {
          selectedMember = null;
          punctuality = 5;
          collaboration = 5;
          workQuality = 5;
          communication = 5;
          commentController.clear();
        });

        // 🔥 Go back after a small delay
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(); // 👈 This will return to previous screen
      } else {
        final error = jsonDecode(response.body)['message'] ??
            'Failed to submit evaluation.';
        Get.snackbar('Error', error);
      }
    } catch (e) {
      print('Error submitting evaluation: $e');
      Get.snackbar('Error', 'An error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
