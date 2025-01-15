import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_button.dart';

class PaySlipDetail extends StatelessWidget {
  const PaySlipDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 45, bottom: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Pay Slip Details",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Pay Slip",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildReceiptRow("Employee Name", "Thiry Uchiha"),
                          _buildReceiptRow("Employee ID", "#190903"),
                          _buildReceiptRow("Joined Date", "12 Dec 2024"),
                          const Divider(),
                          _buildReceiptRow("Pay Period", "1 Dec - 25 Dec 2024"),
                          _buildReceiptRow("Pay Date", "30 Dec 2024"),
                          _buildReceiptRow("Monthly Rate", "\$2000"),
                          _buildReceiptRow("Working Hour Rate", "240 hours"),
                          _buildReceiptRow("Hourly Rate Rate", "\$8.33"),
                          const Divider(),
                          const Text(
                            "Working Hours",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          _buildReceiptRow("Daily Work Hours", "160 hours"),
                          _buildReceiptRow("Overtime", "5 hours"),
                          _buildReceiptRow("Annual leave", "16 hours"),
                          _buildReceiptRow("Sick leave", "8 hours"),
                          _buildReceiptRow("Unpaid leave", "0 hours"),
                          _buildReceiptRow("Special leave", "0 hours"),
                          _buildReceiptRow("Maternity leave", "0 hours"),
                          _buildReceiptRow("Total Working Hours", "165 hours",
                              isBold: true),
                          const Divider(),
                          const Text(
                            "Earnings",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          _buildReceiptRow("Basic Salary", "\$2000"),
                          _buildReceiptRow("Overtime", "\$300"),
                          _buildReceiptRow("Deductions", "-\$30"),
                          const Divider(),
                          _buildReceiptRow(
                            "Total Salary",
                            "\$2270",
                            valueColor: Colors.green,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    top: 0,
                    child: SvgPicture.asset("assets/icons/success-icon.svg"),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BaseButton(
                    text: 'Reject',
                    onPressed: () {},
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BaseButton(
                    text: 'Confirm',
                    onPressed: () {},
                    backgroundColor: BaseColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
