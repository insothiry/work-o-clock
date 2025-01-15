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
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
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
                child: const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 70,
                        child: Icon(
                          Icons.credit_card,
                          color: BaseColors.primaryColor,
                          size: 60,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Rate',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text('350 USD',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Hourly Rate',
                                    style: TextStyle(color: Colors.white)),
                                Text('1.45 USD',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
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
                  const Text('From '),
                  Obx(() {
                    return payrollController.startDate.value != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              payrollController.startDate.value!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                            ),
                          )
                        : TextButton(
                            onPressed: () =>
                                payrollController.selectStartDate(context),
                            child: const Text('Start Date'),
                          );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text('to'),
                  ),
                  Obx(() {
                    return payrollController.endDate.value != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              payrollController.endDate.value!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                            ),
                          )
                        : TextButton(
                            onPressed: () =>
                                payrollController.selectEndDate(context),
                            child: const Text('End Date'),
                          );
                  }),
                ],
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),
                TrackingContainer(
                  icon: Icons.access_alarm,
                  title: 'Working Hours',
                  value: '120',
                  maxValue: '240',
                  textColor: BaseColors.primaryColor,
                ),
                TrackingContainer(
                  icon: Icons.attach_money,
                  title: 'Salary',
                  value: '174',
                  maxValue: '350',
                  textColor: BaseColors.secondaryColor,
                ),
                SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Others',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                    Get.to(const PaySlipDetail());
                  }),
            )
          ],
        ),
      ),
    );
  }
}
