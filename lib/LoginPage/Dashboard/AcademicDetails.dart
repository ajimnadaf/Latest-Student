import 'package:flutter/material.dart';

// --- Professional Color Palette ---
const Color primaryBlue = Color(0xFF1976D2); // Deep calm blue
const Color accentTeal = Color(0xFF009688);  // Balanced teal accent
const Color textDark = Color(0xFF424242);    // Neutral dark text color
const Color cardBg = Color(0xFFF8F9FA);      // Soft card background

class AcademicDetailsPopup {
  static void show(BuildContext context) {
    // --- Controllers with sample values ---
    final TextEditingController schoolController =
        TextEditingController(text: "LATEST DEMO INSTITUTE");
    final TextEditingController admissionDateController =
        TextEditingController(text: "2025-10-11");
    final TextEditingController classController =
        TextEditingController(text: "CLASS 1(A)");
    final TextEditingController rollController =
        TextEditingController(text: "NA");
    final TextEditingController previousSchoolController =
        TextEditingController(text: "NA");

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: cardBg,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🩵 Header
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.school_rounded,
                            color: primaryBlue, size: 48),
                        SizedBox(height: 8),
                        Text(
                          "Academic Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 📘 Text Fields
                  buildTextField("Current School / College Name", schoolController),
                  buildTextField("Admission Date", admissionDateController),
                  buildTextField("Class (Section)", classController),
                  buildTextField("Roll No", rollController),
                  buildTextField("Previous School / College Name", previousSchoolController),

                  const SizedBox(height: 25),

                  // 💾 Save Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 14),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        "Save Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🧾 Helper Function for Consistent TextFields
  static Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        cursorColor: primaryBlue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: primaryBlue, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: accentTeal, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
