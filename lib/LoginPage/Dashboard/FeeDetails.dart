import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/LoginPage/Dashboard/Transaction_details.dart';

// ------------------------------------------------------
// FEES DETAILS SCREEN
// ------------------------------------------------------
class FeesDetailsScreen extends StatelessWidget {
  const FeesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Fees Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.teal[700],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Student Info Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person, "Name:", "${Glb.student_name}"),
                  const Divider(),
                  _buildDetailRow(Icons.class_, "Class:", "CLASS 1(A)"),
                  const Divider(),
                  _buildDetailRow(
                      Icons.calendar_today, "Year:", "Current Year"),
                  const Divider(),
                  _buildDetailRow(Icons.account_balance_wallet, "Total Fees:",
                      "₹15,700.00"),
                  const Divider(),
                  _buildDetailRow(
                      Icons.check_circle, "Paid Fees:", "₹15,700.00"),
                  const Divider(),
                  _buildDetailRow(
                      Icons.pending_actions, "Remaining Fees:", "₹0.00"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- View Transaction Button ---
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransactionDetailsPage()),
                  );
                },
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                label: const Text(
                  'VIEW TRANSACTION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Payment Form Section ---
            const Text(
              'Online Payment Details',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: "Contact No",
              hint: "Enter contact number",
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Email ID",
              hint: "Enter email address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Amount",
              hint: "Enter amount",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // --- Payment Button ---
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  _showPaymentPopup(context);
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'MAKE PAYMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Custom Widget: Detail Row with Icon ---
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal[700], size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Custom Widget: Styled Text Field ---
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.teal[700]),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black45),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.teal[700]!, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

// ------------------------------------------------------
// PAYMENT POPUP 
// ------------------------------------------------------
  void _showPaymentPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental close
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          title: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange[100],
                child: Icon(
                  Icons.payment_rounded,
                  color: Colors.orange[700],
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Confirm Payment",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to proceed with this payment?",
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 14),
          actions: [
            // Cancel Button
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Pay Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
                elevation: 3,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Processing Payment...",
                      style: TextStyle(fontSize: 16),
                    ),
                    backgroundColor: Colors.teal[700],
                  ),
                );

                // TODO: 👉 Add your PAYMENT API integration here
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Pay Now",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
