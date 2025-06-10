import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

void showBaseDialog({
  required String title,
  required String description,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool showReasonField = false,
  bool showCancelButton = true,
  TextEditingController? reasonController,
}) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🏷 Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 📄 Description
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📝 Optional Reason Field
            if (showReasonField) ...[
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: "Reason (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // 🚀 Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ❌ Cancel Button
                if (showCancelButton) ...[
                  OutlinedButton(
                    onPressed: onCancel ?? () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ],

                // ✅ Confirm Button
                ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
