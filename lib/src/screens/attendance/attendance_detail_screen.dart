import 'package:flutter/material.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const AttendanceDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    // Static history data
    final List<Map<String, String>> attendanceHistory = [
      {
        'date': '2024-12-18',
        'clockIn': '09:00 AM',
        'clockOut': '05:00 PM',
        'workHours': '8 hrs'
      },
      {
        'date': '2024-12-17',
        'clockIn': '09:15 AM',
        'clockOut': '05:10 PM',
        'workHours': '7 hrs 55 mins'
      },
      {
        'date': '2024-12-16',
        'clockIn': '08:45 AM',
        'clockOut': '04:30 PM',
        'workHours': '7 hrs 45 mins'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${employee['name']}'s Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      employee['profilePicture']!,
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${employee['name']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Today's Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance: ${employee['attendance']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (employee['clockIn'] != null &&
                employee['clockOut'] != null) ...[
              Text(
                'Clock-In Time: ${employee['clockIn']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Clock-Out Time: ${employee['clockOut']}',
                style: const TextStyle(fontSize: 16),
              ),
            ] else
              const Text(
                'Clock-In and Clock-Out times not available',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // History List
            Expanded(
              child: ListView.separated(
                itemCount: attendanceHistory.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final history = attendanceHistory[index];
                  return ListTile(
                    title: Text(
                      history['date']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clock-In: ${history['clockIn']}'),
                        Text('Clock-Out: ${history['clockOut']}'),
                        Text('Work Hours: ${history['workHours']}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
