import 'package:flutter/material.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<String>> departmentEmployees = {
    'Human Resources': ['Alice Johnson', 'Bob Smith'],
    'Finance': ['Charles Brown', 'Diana Prince'],
    'Engineering': ['Evan Taylor', 'Fiona Davis', 'George Wilson'],
    'Marketing': ['Helen White', 'Ian Clark'],
    'Sales': ['Jack Harris', 'Karen Lewis'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: departmentEmployees.keys.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        bottom: TabBar(
          labelColor: BaseColors.primaryColor,
          indicatorColor: BaseColors.primaryColor,
          controller: _tabController,
          isScrollable: true,
          tabs: departmentEmployees.keys.map((department) {
            return Tab(
              text: department,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: departmentEmployees.keys.map((department) {
          final employees = departmentEmployees[department]!;
          return employees.isEmpty
              ? const Center(
                  child: Text(
                    'No employees in this department',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(employees[index]),
                        subtitle: Text(department),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            // Handle edit employee action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Edit ${employees[index]}')),
                            );
                          },
                        ),
                        onTap: () {
                          // Handle tap action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${employees[index]} selected')),
                          );
                        },
                      ),
                    );
                  },
                );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BaseColors.primaryColor,
        onPressed: () {
          // Handle adding a new employee
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Employee')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
