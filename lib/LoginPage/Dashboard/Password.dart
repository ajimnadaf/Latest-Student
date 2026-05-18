import 'package:flutter/material.dart';

// --- Professional Color Constant ---
const Color primaryActionBlue = Color(0xFF1976D2); // Deep Blue for security actions
const Color lightBorderColor = Colors.black26;
const Color darkTextColor = Colors.black87;

class SetNewCredentialsPage extends StatefulWidget {
  // Fixed: The State widget constructor should not require 'title' if it's not used in the State class directly.
  final String title;
  const SetNewCredentialsPage({super.key, required this.title});

  @override
  State<SetNewCredentialsPage> createState() => _SetNewCredentialsPageState();
}

class _SetNewCredentialsPageState extends State<SetNewCredentialsPage> {
  // Controllers for text fields
  final TextEditingController oldLoginIdController = TextEditingController();
  final TextEditingController newLoginIdController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  // Function for button actions (for now, just showing SnackBars)
  void updateLoginId() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login ID updated successfully!")),
    );
  }

  void updatePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully!")),
    );
  }

  // Helper method for consistent professional TextField style
  Widget _buildCredentialTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        // Add a professional icon
        prefixIcon: Icon(icon, color: primaryActionBlue.withOpacity(0.7)),
        // Standard OutlineInputBorder
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: lightBorderColor),
        ),
        // Focused border uses the primary blue color
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primaryActionBlue, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        elevation: 1,
        centerTitle: true,
        title: Text(
          widget.title, // Use widget.title
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔑 SET NEW LOGIN ID BOX
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: lightBorderColor), // Lighter border
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "UPDATE LOGIN ID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryActionBlue, // Title color matches action color
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Old Login ID Field
                  _buildCredentialTextField(
                    controller: oldLoginIdController,
                    labelText: "Enter Old Login ID:",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  
                  // New Login ID Field
                  _buildCredentialTextField(
                    controller: newLoginIdController,
                    labelText: "Enter New Login ID:",
                    icon: Icons.person_add_alt_outlined,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Update Login ID Button
                  ElevatedButton(
                    onPressed: updateLoginId,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: primaryActionBlue, // Professional blue color
                      foregroundColor: Colors.white,
                      elevation: 3,
                    ),
                    child: const Text(
                      "UPDATE LOGIN ID",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔒 SET NEW PASSWORD BOX
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: lightBorderColor), // Lighter border
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "UPDATE PASSWORD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryActionBlue, // Title color matches action color
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Old Password Field
                  _buildCredentialTextField(
                    controller: oldPasswordController,
                    labelText: "Enter Old Password:",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  
                  // New Password Field
                  _buildCredentialTextField(
                    controller: newPasswordController,
                    labelText: "Enter New Password:",
                    icon: Icons.vpn_key_outlined,
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Update Password Button
                  ElevatedButton(
                    onPressed: updatePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: primaryActionBlue, // Professional blue color
                      foregroundColor: Colors.white,
                      elevation: 3,
                    ),
                    child: const Text(
                      "UPDATE PASSWORD",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}