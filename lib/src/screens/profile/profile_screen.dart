// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/screens/profile/add_account_screen.dart';
import 'package:work_o_clock/src/screens/profile/change_password_screen.dart';
import 'package:work_o_clock/src/screens/profile/edit_profile_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:work_o_clock/src/widgets/base_confirm_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  String selectedLanguage = "English";
  String activeAccountType = "Admin";
  List<String> accounts = ["Admin", "Employee"];

  @override
  void initState() {
    super.initState();
    isDarkMode = Get.isDarkMode;
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void _showSwitchAccountBottomSheet(BuildContext context) {
    final accountDetails = [
      {
        'name': 'Admin',
        'email': 'admin@example.com',
        'image': 'assets/images/profile-icon.png'
      },
      {
        'name': 'Employee',
        'email': 'employee@example.com',
        'image': 'assets/images/iu_pf.jpg'
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...accountDetails.map((account) {
                final isSelected = activeAccountType == account['name'];
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      activeAccountType = account['name']!;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to ${account['name']} account'),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(account['image']!),
                  ),
                  title: Text(
                    account['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(account['email']!),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: BaseColors.primaryColor)
                      : null,
                );
              }).toList(),
              const SizedBox(height: 16),
              Center(
                child: BaseButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAccountScreen(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        accounts.add(result['email']);
                      });
                    }
                  },
                  text: 'Add Account',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(const EditProfileScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/iu_pf.jpg'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Naksu In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Senior Mobile Developer',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'haein@melonpeach.com',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                '+855 11 999 777',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Change Password'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onTap: () {
                  Get.to(const ChangePasswordScreen());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
                onTap: () {
                  _toggleDarkMode(!isDarkMode);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: selectedLanguage,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: <String>['English', 'Khmer'].map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          language,
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.switch_account),
                title: const Text('Switch Account'),
                onTap: () => _showSwitchAccountBottomSheet(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return LogoutConfirmDialog(
        title: 'Confirm Logout',
        content: 'Are you sure you want to logout?',
        onConfirm: () {},
        onCancel: () {},
      );
    },
  );
}
