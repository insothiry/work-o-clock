import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTaskController extends GetxController {
  // Form Fields
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController taskTypeController = TextEditingController();
  final TextEditingController assignToController = TextEditingController();
  final TextEditingController attachmentsController = TextEditingController();

  DateTime? dueDate;
  String priority = 'Low';

  void submitForm(BuildContext context) {
    if (formKey.currentState!.validate()) {
      String title = titleController.text;
      // String description = descriptionController.text;

      // Logic to save or create the task can be added here
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Task Created: $title'),
      ));

      Get.back();
    }
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      dueDate = picked;
      update();
    }
  }

  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      attachmentsController.text = result.files.first.name;
      update();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    taskTypeController.dispose();
    assignToController.dispose();
    attachmentsController.dispose();
    super.onClose();
  }
}
