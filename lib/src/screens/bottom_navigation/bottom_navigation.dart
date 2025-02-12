import 'package:flutter/material.dart';
import 'package:work_o_clock/src/screens/attendance/own_attendance_screen.dart';
import 'package:work_o_clock/src/screens/calendar/calendar_screen.dart';
import 'package:work_o_clock/src/screens/home/home_screen.dart';
import 'package:work_o_clock/src/screens/payment/payroll_screen.dart';
import 'package:work_o_clock/src/screens/profile/profile_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  // List of widgets to display in each tab
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    CalendarScreen(),
    const PayrollScreen(),
    const OwnAttendanceScreen(),
    const ProfileScreen(),
  ];

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: _buildAnimatedIcon(index),
            label: _getLabelForIndex(index),
          );
        }),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: BaseColors.primaryColor,
      ),
    );
  }

  // Returns the label based on the index
  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Calendar';
      case 2:
        return 'Payroll';
      case 3:
        return 'Attendance';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  // Build animated icon for each navigation item
  Widget _buildAnimatedIcon(int index) {
    return AnimatedScale(
      scale: _selectedIndex == index ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        _getIconForIndex(index),
        size: 24,
      ),
    );
  }

  // Returns the icon based on the index
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.event;
      case 2:
        return Icons.payment;
      case 3:
        return Icons.people;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }
}
