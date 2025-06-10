import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:work_o_clock/src/screens/notifications/notification_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

void showBannerNotification(String message) {
  showOverlayNotification(
    (context) {
      return GestureDetector(
        onTap: () {
          OverlaySupportEntry.of(context)?.dismiss();
          Get.to(() => const NotificationScreen());
        },
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notifications,
                    color: BaseColors.primaryColor, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    duration: const Duration(seconds: 5),
    position: NotificationPosition.top,
  );
}
