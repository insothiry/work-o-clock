import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/controller/create_task_controller.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:work_o_clock/src/widgets/switch_tile.dart';

class CreateMeetingForm extends StatelessWidget {
  const CreateMeetingForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTaskController());

    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: BaseColors.greyBackground,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildForm(controller, context),
              const SizedBox(height: 16),
              _buildButtons(controller),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Build header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        const Text(
          'Create New Meeting',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Build the form fields
  Widget _buildForm(CreateTaskController controller, BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildSwitchTile(),
          const SizedBox(height: 16),
          _buildDatePicker(controller, context),
          const SizedBox(height: 20),
          _buildMeetingDetails(controller),
          const SizedBox(height: 20),
          _buildPriorityAndAttachments(controller),
        ],
      ),
    );
  }

  // Build "All Day" switch tile
  Widget _buildSwitchTile() {
    return Container(
      decoration: _buildBoxDecoration(),
      child: const SwitchTile(title: 'All Day'),
    );
  }

  // Build date picker for due date
  Widget _buildDatePicker(
      CreateTaskController controller, BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(),
      child: ListTile(
        title: Text(
          controller.dueDate == null
              ? 'Select Meeting Date'
              : 'Meeting Date: ${controller.dueDate!.toLocal()}'.split(' ')[0],
        ),
        leading:
            const Icon(Icons.calendar_today, color: BaseColors.primaryColor),
        onTap: () => controller.selectDueDate(context),
      ),
    );
  }

  // Build meeting title, type, members, and description fields
  Widget _buildMeetingDetails(CreateTaskController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildBoxDecoration(),
      child: Column(
        children: [
          _buildTextField(
            controller.titleController,
            'Meeting Title',
            Icons.title,
            'Please enter a meeting title',
          ),
          _buildTextField(
            controller.taskTypeController,
            'Meeting Type',
            Icons.category,
          ),
          _buildTextField(
            controller.assignToController,
            'Members',
            Icons.people,
          ),
          _buildTextField(
            controller.descriptionController,
            'Meeting Description',
            Icons.description,
            'Please enter a meeting description',
          ),
        ],
      ),
    );
  }

  // Build priority dropdown and attachments field
  Widget _buildPriorityAndAttachments(CreateTaskController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildBoxDecoration(),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: controller.priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              prefixIcon: Icon(Icons.flag, color: BaseColors.primaryColor),
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.priority = newValue;
                controller.update();
              }
            },
            items: ['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file,
                    color: BaseColors.primaryColor),
                onPressed: controller.pickAttachment,
              ),
              Expanded(
                child: Text(
                  controller.attachmentsController.text.isEmpty
                      ? 'Attachments'
                      : controller.attachmentsController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the save and create buttons
  Widget _buildButtons(CreateTaskController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(
            'Save to draft', () => Get.back(), BaseColors.secondaryColor),
        _buildButton('Create Task', () => controller.submitForm(Get.context!)),
      ],
    );
  }

  // Helper method to build text form fields
  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      [String? validatorMessage]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: BaseColors.primaryColor),
      ),
      validator: validatorMessage != null
          ? (value) {
              if (value == null || value.isEmpty) {
                return validatorMessage;
              }
              return null;
            }
          : null,
    );
  }

  // Helper method to build rounded containers for form sections
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
    );
  }

  // Helper method to build buttons
  Widget _buildButton(String text, VoidCallback onPressed,
      [Color? backgroundColor]) {
    return SizedBox(
      width: 170,
      child: BaseButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? BaseColors.primaryColor,
      ),
    );
  }
}
