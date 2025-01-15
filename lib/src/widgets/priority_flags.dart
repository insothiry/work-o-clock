import 'package:flutter/material.dart';

class PriorityFlag extends StatelessWidget {
  final String priority;

  const PriorityFlag({
    Key? key,
    required this.priority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor;

    // Assign colors based on the priority level
    switch (priority.toLowerCase()) {
      case 'low':
        priorityColor = Colors.green;
        break;
      case 'normal':
        priorityColor = Colors.orange;
        break;
      case 'high':
        priorityColor = Colors.red;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          priority[0].toUpperCase() + priority.substring(1),
          style: TextStyle(
            color: priorityColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
