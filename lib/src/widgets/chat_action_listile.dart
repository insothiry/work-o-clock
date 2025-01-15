import 'package:flutter/material.dart';

class ChatActionListTile extends StatelessWidget {
  final String name;
  final String action;
  final Widget? postAction;

  const ChatActionListTile({
    Key? key,
    required this.name,
    required this.action,
    this.postAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                action,
                style: const TextStyle(fontSize: 14),
              ),
              if (postAction != null) ...[
                const SizedBox(width: 8),
                postAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
