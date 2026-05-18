import 'package:flutter/material.dart';

// --- Professional Color Palette ---
const Color primaryBlue = Color(0xFF1976D2); // Calm deep blue
const Color accentTeal = Color(0xFF009688);  // Elegant teal
const Color textDark = Color(0xFF424242);    // Neutral text
const Color cardBg = Color(0xFFF8F9FA);      // Soft background

class ScholarshipDetailsPopup {
  static void show(BuildContext context) {
    String? selectedReligion;
    String? selectedCategory;
    String? selectedCaste;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: cardBg,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
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
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: primaryBlue,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Scholarship Details",
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

                      // 🕌 Religion
                      buildDropdownField(
                        label: "Religion",
                        value: selectedReligion,
                        items: const [
                          "Hindu",
                          "Muslim",
                          "Christian",
                          "Sikh",
                          "Buddhist",
                          "Jain",
                          "Other"
                        ],
                        onChanged: (value) {
                          setState(() => selectedReligion = value);
                        },
                      ),

                      // 🏛️ Category
                      buildDropdownField(
                        label: "Category",
                        value: selectedCategory,
                        items: const [
                          "General",
                          "OBC",
                          "SC",
                          "ST",
                          "EWS",
                          "NT",
                        ],
                        onChanged: (value) {
                          setState(() => selectedCategory = value);
                        },
                      ),

                      // 🧾 Caste
                      buildDropdownField(
                        label: "Caste",
                        value: selectedCaste,
                        items: const [
                          "Select",
                          "OPEN",
                          "OBC",
                          "SC",
                          "ST",
                          "VJNT",
                          "Other"
                        ],
                        onChanged: (value) {
                          setState(() => selectedCaste = value);
                        },
                      ),

                      const SizedBox(height: 25),

                      // 💾 Save Button
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 14,
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                          ),
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
              );
            },
          ),
        );
      },
    );
  }

  // 🧩 Dropdown Field Widget
  static Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            hint: const Text("Select"),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            icon: const Icon(
              Icons.arrow_drop_down_circle,
              color: primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
