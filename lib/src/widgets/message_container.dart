import 'package:flutter/material.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({
    super.key,
    required this.isUserMessage,
    required this.message,
    this.profileImage,
  });

  final bool isUserMessage;
  final Map<String, dynamic> message;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUserMessage)
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                    profileImage ?? 'assets/images/profile-icon.png'),
              ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isUserMessage
                      ? BaseColors.primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message['text'],
                  style: TextStyle(
                    color: isUserMessage ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
