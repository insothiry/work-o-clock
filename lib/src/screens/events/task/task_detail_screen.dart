import 'package:flutter/material.dart';
import 'package:work_o_clock/src/models/task_model.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Requesting':
        return const Icon(Icons.flag, color: Colors.yellow);
      case 'Pending':
        return const Icon(Icons.flag, color: Colors.orange);
      case 'In Progress':
        return const Icon(Icons.flag, color: Colors.blue);
      case 'Complete':
        return const Icon(Icons.flag, color: Colors.green);
      default:
        return const Icon(Icons.flag, color: Colors.grey);
    }
  }

  void _showEditTaskDialog(BuildContext context) {
    final _nameController = TextEditingController(text: task.name);
    final _descriptionController =
        TextEditingController(text: task.description);
    String _status = task.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  onChanged: (String? newStatus) {
                    if (newStatus != null) {
                      _status = newStatus;
                    }
                  },
                  items: ['Requesting', 'Pending', 'In Progress', 'Complete']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          _getStatusIcon(value),
                          const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name
            Text(
              task.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Task Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Date: ${task.date}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Time: ${task.time}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.edit_document, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Created at: ${task.createdAt}', // Update to use actual createdAt
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 32),
            // Description
            const Text('Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text(
              task.description,
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 32),
            // Task Status
            const Text('Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Row(
              children: [
                _getStatusIcon(task.status),
                const SizedBox(width: 8),
                Text(
                  task.status,
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: task.status,
                  onChanged: (String? newStatus) {
                    // Handle status change here
                  },
                  items: ['Requesting', 'Pending', 'In Progress', 'Complete']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          _getStatusIcon(value),
                          const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Divider(height: 32),
            // Task Assigned To
            const Text(
              'Assigned to',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    task.assignedTo[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  task.assignedTo,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Go to Chat Button
                  BaseButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    text: 'Go to Chat',
                    backgroundColor: BaseColors.secondaryColor,
                    borderRadius: 50,
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: BaseButton(
                          onPressed: () => _showEditTaskDialog(context),
                          text: 'Edit Task',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BaseButton(
                          onPressed: () {
                            // Delete action
                          },
                          text: 'Delete Task',
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
