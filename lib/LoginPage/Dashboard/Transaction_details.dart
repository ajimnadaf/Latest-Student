import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======== HEADER SECTION ========
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long,
                        size: 30, color: Colors.teal[700]),
                    const SizedBox(width: 10),
                    Text(
                      "Transaction Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    buildDetailRow(
                      icon: Icons.calendar_today,
                      title: "Date",
                      value: "11-10-2025",
                      color: Colors.blue[700]!,
                    ),
                    const SizedBox(height: 14),

                    buildDetailRow(
                      icon: Icons.currency_rupee_rounded,
                      title: "Paid Amount",
                      value: "₹15,700.00",
                      color: Colors.green[700]!,
                    ),
                    const SizedBox(height: 14),

                    buildDetailRow(
                      icon: Icons.payments_rounded,
                      title: "Transaction Mode",
                      value: "Cash",
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 14),

                    buildDetailRow(
                      icon: Icons.swap_vert_circle_outlined,
                      title: "Type",
                      value: "(Credit)",
                      color: Colors.orange[800]!,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Empty bottom space
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // Professional Detail Row Widget
  // ===============================
  Widget buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
