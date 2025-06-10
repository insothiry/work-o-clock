import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/controller/payroll_controller.dart';
import 'package:work_o_clock/src/screens/payment/payslip_detail.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';
import 'package:work_o_clock/src/widgets/tracking_container.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PayrollController payrollController = Get.put(PayrollController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll'),
      ),
      body: Obx(() => RefreshIndicator(
            onRefresh: () async {
              await payrollController.fetchUserRates();
              await payrollController.fetchSalaryForSelectedMonth();
            },
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // ensure it's scrollable even if short
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: BaseColors.primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 70,
                              child: Icon(
                                Icons.credit_card,
                                color: BaseColors.primaryColor,
                                size: 60,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Monthly Salary',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text(
                                          '${formatNumber(payrollController.monthlyRate.value)} USD',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Hourly Rate',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text(
                                          '${formatNumber(payrollController.hourlyRate.value)} USD',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        const Text('Pay Period: '),
                        Obx(() {
                          final selected =
                              payrollController.selectedMonth.value;
                          return TextButton(
                            onPressed: () =>
                                payrollController.selectMonth(context),
                            child: Text(
                              '${selected.year}-${selected.month.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      TrackingContainer(
                        icon: Icons.access_alarm,
                        title: 'Working Hours',
                        value: formatNumber(payrollController.totalHours.value),
                        maxValue: '240',
                        textColor: BaseColors.primaryColor,
                      ),
                      TrackingContainer(
                        icon: Icons.attach_money,
                        title: 'Salary',
                        value:
                            formatNumber(payrollController.totalSalary.value),
                        maxValue:
                            formatNumber(payrollController.monthlyRate.value),
                        textColor: BaseColors.secondaryColor,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Others',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    leading: Text(
                      'Monthly Tax',
                      style: TextStyle(fontSize: 16),
                    ),
                    title: Text('10%'),
                    trailing: Text(
                      '3.5 USD',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    leading: Text(
                      'NSSF',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Text(
                      '12 USD',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: BaseButton(
                      text: 'View Pay Slip',
                      onPressed: () {
                        Get.to(() => const PaySlipDetail());
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  String formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }
}
