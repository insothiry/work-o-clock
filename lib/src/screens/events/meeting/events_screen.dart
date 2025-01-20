import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:work_o_clock/src/screens/events/meeting/create_meeting_form.dart';
import 'package:work_o_clock/src/screens/events/task/create_task_form.dart';
import 'package:work_o_clock/src/screens/events/task/task_tab.dart';
import 'package:work_o_clock/src/widgets/base_table_calender.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Meetings'),
            ],
          ),
        ),
        body: Column(
          children: [
            const BaseCalendar(),
            Expanded(
              child: TabBarView(
                children: [
                  TaskTab(),
                  MeetingsTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () => _showOptionsDialog(context),
          tooltip: 'Create Event',
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Function to show options dialog
  void _showOptionsDialog(BuildContext context) {
    showAlignedDialog(
      targetAnchor: Alignment.bottomRight,
      offset: const Offset(-150, -200),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  _buildOptionTile(context, 'Create New Task', Icons.task,
                      const CreateTaskForm()),
                  _buildOptionTile(context, 'Create New Meeting', Icons.people,
                      const CreateMeetingForm()),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build an option tile dynamically
  Widget _buildOptionTile(
      BuildContext context, String title, IconData icon, Widget form) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blueAccent,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        onTap: () => _showBottomSheet(context, form),
      ),
    );
  }

  // General method to show modal bottom sheet
  void _showBottomSheet(BuildContext context, Widget form) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.transparent,
            ),
            child: IntrinsicHeight(
              child: form,
            ),
          ),
        );
      },
    );
  }
}

class MeetingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Meetings List',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
