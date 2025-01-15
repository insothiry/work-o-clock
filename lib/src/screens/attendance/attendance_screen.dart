import 'package:flutter/material.dart';
import 'package:work_o_clock/src/screens/attendance/attendance_detail_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Initially selected team is the first one (Mobile Team)
  String? selectedTeam = 'Mobile Team';

  // List of teams and their respective employees with attendance status
  final Map<String, List<Map<String, dynamic>>> teams = {
    'Mobile Team': [
      {
        'name': 'Alice',
        'attendance': 'Present',
        'profilePicture': 'A',
        'clockIn': '9:00 AM',
        'clockOut': '5:00 PM',
      },
      {
        'name': 'Bob',
        'attendance': 'Absent',
        'profilePicture': 'B',
        'clockIn': null,
        'clockOut': null,
      },
      {
        'name': 'Charlie',
        'attendance': 'Present',
        'profilePicture': 'C',
        'clockIn': '9:15 AM',
        'clockOut': '5:10 PM',
      },
      {
        'name': 'Jimmy',
        'attendance': 'Late',
        'profilePicture': 'J',
        'clockIn': '10:15 AM',
        'clockOut': '5:10 PM',
      },
    ],
    'Frontend Team': [
      {
        'name': 'David',
        'attendance': 'Absent',
        'profilePicture': 'D',
        'clockIn': null,
        'clockOut': null,
      },
      {
        'name': 'Eva',
        'attendance': 'Present',
        'profilePicture': 'E',
        'clockIn': '8:50 AM',
        'clockOut': '4:45 PM',
      },
      {
        'name': 'Fay',
        'attendance': 'Present',
        'profilePicture': 'F',
        'clockIn': '9:00 AM',
        'clockOut': '5:00 PM',
      },
    ],
    'Backend Team': [
      {
        'name': 'Grace',
        'attendance': 'Present',
        'profilePicture': 'G',
        'clockIn': '9:10 AM',
        'clockOut': '5:05 PM',
      },
      {
        'name': 'Hank',
        'attendance': 'Absent',
        'profilePicture': 'H',
        'clockIn': null,
        'clockOut': null,
      },
      {
        'name': 'Ivy',
        'attendance': 'Present',
        'profilePicture': 'I',
        'clockIn': '9:00 AM',
        'clockOut': '5:00 PM',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select team
            DropdownButton<String>(
              value: selectedTeam,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam = newValue;
                });
              },
              items: teams.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Display team members and their attendance
            if (selectedTeam != null && teams[selectedTeam] != null) ...[
              const Text(
                'Team Members:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Display the list of employees for the selected team
              Expanded(
                child: ListView.builder(
                  itemCount: teams[selectedTeam]!.length,
                  itemBuilder: (context, index) {
                    final employee = teams[selectedTeam]![index];
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(employee['profilePicture']!),
                          ),
                          title: Text(employee['name']!),
                          trailing: Text(
                            employee['attendance']!,
                            style: TextStyle(
                              color: employee['attendance'] == 'Present'
                                  ? Colors.green
                                  : employee['attendance'] == 'Late'
                                      ? Colors.orange
                                      : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            // Navigate to EmployeeDetailScreen with employee data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceDetailScreen(
                                  employee: employee,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
            // Handle case where no team is selected
            if (selectedTeam == null || teams[selectedTeam] == null)
              const Text('Please select a team from the dropdown'),
          ],
        ),
      ),
    );
  }
}
