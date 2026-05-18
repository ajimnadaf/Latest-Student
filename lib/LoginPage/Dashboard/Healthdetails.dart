import 'package:flutter/material.dart';

// --- Professional Color Palette ---
const Color primaryBlue = Color(0xFF1976D2); // Calm deep blue
const Color accentTeal = Color(0xFF009688);  // Elegant teal
const Color softAmber = Color(0xFFFFB300);   // Highlight button
const Color textDark = Color(0xFF424242);    // Neutral text
const Color bgLight = Color(0xFFF8F9FA);     // Soft background

class HealthDetailsPopup extends StatefulWidget {
  const HealthDetailsPopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HealthDetailsPopup(),
    );
  }

  @override
  State<HealthDetailsPopup> createState() => _HealthDetailsPopupState();
}

class _HealthDetailsPopupState extends State<HealthDetailsPopup> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  double? bmi;
  String resultText = "Result: None";

  void calculateBMI() {
    final double? height = double.tryParse(heightController.text);
    final double? weight = double.tryParse(weightController.text);

    if (height != null && weight != null && height > 0) {
      final double calculatedBMI = weight / (height * height);
      String category;

      if (calculatedBMI < 18.5) {
        category = "Underweight";
      } else if (calculatedBMI < 24.9) {
        category = "Normal";
      } else if (calculatedBMI < 29.9) {
        category = "Overweight";
      } else {
        category = "Obese";
      }

      setState(() {
        bmi = calculatedBMI;
        resultText = "Result: $category";
      });
    } else {
      setState(() {
        bmi = null;
        resultText = "Invalid Input";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgLight,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Column(
                children: const [
                  Icon(
                    Icons.favorite_rounded,
                    color: accentTeal,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Health Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Height Field
              _buildInputField(
                controller: heightController,
                label: "Height (in meters)",
                icon: Icons.height_rounded,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Weight Field
              _buildInputField(
                controller: weightController,
                label: "Weight (in kg)",
                icon: Icons.monitor_weight_rounded,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // BMI Display
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Body Mass Index (BMI):",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bmi == null
                          ? "0.0  ($resultText)"
                          : "${bmi!.toStringAsFixed(2)}  ($resultText)",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                    ),
                    icon: const Icon(Icons.calculate_rounded,
                        color: Colors.white),
                    label: const Text(
                      "Calculate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softAmber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                    ),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    label: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType inputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
