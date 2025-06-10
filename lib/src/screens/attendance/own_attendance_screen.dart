import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:work_o_clock/src/controller/attendance_controller.dart';
import 'package:work_o_clock/src/utils/base_time_convertor.dart';
import 'package:work_o_clock/src/widgets/base_table_calender.dart';

class OwnAttendanceScreen extends StatelessWidget {
  const OwnAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: Obx(() {
        final selectedDate = controller.selectedDate.value;
        List<Map<String, dynamic>> attendanceHistory =
            controller.attendanceHistory;

        // ✅ Filter attendance by selected date (using isSameDay)
        if (selectedDate != null) {
          attendanceHistory = attendanceHistory.where((history) {
            final rawDate = history['attendanceDate'];
            if (rawDate == null || rawDate == 'N/A') return false;

            final recordDate = DateTime.parse(rawDate).toLocal();
            return isSameDay(recordDate, selectedDate);
          }).toList();
        }

        // ✅ Group attendance by formatted date
        Map<String, List<Map<String, dynamic>>> groupedAttendance = {};
        for (var record in attendanceHistory) {
          if (record['attendanceDate'] == null ||
              record['attendanceDate'] == 'N/A') continue;

          final localDate = DateTime.parse(record['attendanceDate']).toLocal();
          final key =
              "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";

          groupedAttendance.putIfAbsent(key, () => []).add(record);
        }

        return Column(
          children: [
            BaseCalendar(
              onDaySelected: (selectedDate) {
                controller.selectedDate.value = selectedDate;
                controller.attendanceHistory.clear();
                controller.fetchUserAttendance(
                  from: _formatDate(selectedDate),
                  to: _formatDate(selectedDate),
                );
              },
              onRangeSelected: (start, end) {
                controller.selectedDate.value = null;
                controller.fetchUserAttendance(
                  from: _formatDate(start),
                  to: _formatDate(end),
                );
              },
            ),
            const SizedBox(height: 10),
            if (controller.isLoading.value)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchUserAttendance,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: groupedAttendance.isEmpty
                        ? 1
                        : groupedAttendance.length,
                    itemBuilder: (context, index) {
                      if (groupedAttendance.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text(
                              'No Attendance Records',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      String date = groupedAttendance.keys.elementAt(index);
                      List<Map<String, dynamic>> records =
                          groupedAttendance[date]!;

                      double totalWorkHours = records.fold(0.0, (sum, record) {
                        return sum +
                            (record['workHours'] != null
                                ? double.tryParse(
                                        record['workHours'].toString()) ??
                                    0.0
                                : 0.0);
                      });

                      return Card(
                        // color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (var record in records) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Shift',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: record['shift'] == 'morning'
                                            ? Colors.green
                                            : Colors.blueAccent,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        record['shift']
                                                ?.toString()
                                                .capitalizeFirst ??
                                            '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                _buildRow(
                                  'Clock-In',
                                  record['clockInStatus'] == 'On Leave'
                                      ? 'On Leave'
                                      : record['clockIn'] != null
                                          ? BaseTimeConvertor.formatTime(
                                              record['clockIn'])
                                          : 'N/A',
                                  icon: Icons.login,
                                  color: record['clockInStatus'] == 'Present'
                                      ? Colors.green
                                      : record['clockInStatus'] == 'Late'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                _buildReasonRow(record['reasonClockIn']),
                                _buildRow(
                                  'Clock-Out',
                                  (record['clockOut'] != null &&
                                          record['clockOut']
                                              .toString()
                                              .isNotEmpty)
                                      ? BaseTimeConvertor.formatTime(
                                          record['clockOut'])
                                      : 'N/A',
                                  icon: Icons.logout,
                                  color:
                                      record['clockOutStatus'] == 'Left Early'
                                          ? Colors.orange
                                          : null,
                                ),
                                _buildReasonRow(record['reasonClockOut']),
                                const Divider(height: 20, thickness: 1),
                              ],
                              _buildRow(
                                'Total Work Hours',
                                totalWorkHours.toStringAsFixed(2),
                                icon: Icons.timer,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildRow(String title, String value, {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: color ?? Colors.black54),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildReasonRow(String? reason) {
    if (reason == null || reason.trim().isEmpty || reason == "N/A") {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          reason,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
