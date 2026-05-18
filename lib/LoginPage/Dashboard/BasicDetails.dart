import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

// 🎨 Professional Color Theme
const Color primaryBlue = Color(0xFF1565C0); // Deep professional blue
const Color accentBlue = Color(0xFF42A5F5); // Light blue accents
const Color backgroundGray = Color(0xFFF5F7FA); // Clean gray background
const Color labelBlack = Color(0xFF263238); // Text black
const Color borderGray = Color(0xFFB0BEC5); // Border gray

class UpdateBasicDetailsPopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String gender = "Male";
        String? bloodGroup;

        final TextEditingController nameController =
            TextEditingController(text: "${Glb.student_name}");
        final TextEditingController fatherController =
            TextEditingController(text: "NA");
        final TextEditingController motherController =
            TextEditingController(text: "mother_name");
        final TextEditingController studentContactController =
            TextEditingController(text: "9561382402");
        final TextEditingController fatherContactController =
            TextEditingController(text: "9122241267");
        final TextEditingController motherContactController =
            TextEditingController(text: "NA");
        final TextEditingController dobController =
            TextEditingController(text: "10-10-2025");
        final TextEditingController aadharController =
            TextEditingController(text: "NA");
        final TextEditingController presentAddressController =
            TextEditingController(text: "NA");
        final TextEditingController permanentAddressController =
            TextEditingController(text: "None");
        final TextEditingController emailController =
            TextEditingController(text: "NA");

        return Dialog(
          backgroundColor: backgroundGray,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🟦 Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_pin, color: primaryBlue, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Update Basic Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // 🧾 Input Fields
                      buildTextField("Name", nameController),
                      buildTextField("Father Name", fatherController),
                      buildTextField("Mother Name", motherController),
                      buildTextField("Student Contact", studentContactController),
                      buildTextField("Father Contact No.", fatherContactController),
                      buildTextField("Mother Contact No.", motherContactController),
                      buildTextField("Date Of Birth", dobController),
                      buildTextField("Aadhar No", aadharController),

                      const SizedBox(height: 10),
                      const Text(
                        "Gender",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: labelBlack,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              activeColor: primaryBlue,
                              title: const Text("Male"),
                              value: "Male",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() => gender = value!);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              activeColor: primaryBlue,
                              title: const Text("Female"),
                              value: "Female",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() => gender = value!);
                              },
                            ),
                          ),
                        ],
                      ),

                      buildTextField("Present Address", presentAddressController),
                      buildTextField("Permanent Address", permanentAddressController),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Blood Group",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: labelBlack,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: bloodGroup,
                              hint: const Text("Select"),
                              icon: const Icon(Icons.bloodtype, color: primaryBlue),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderGray, width: 1),
                                ),
                              ),
                              items: [
                                "A+",
                                "A-",
                                "B+",
                                "B-",
                                "O+",
                                "O-",
                                "AB+",
                                "AB-"
                              ]
                                  .map((group) => DropdownMenuItem(
                                        value: group,
                                        child: Text(group),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => bloodGroup = value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      buildTextField("Email ID", emailController),

                      const SizedBox(height: 25),
                      const SizedBox(height: 10),
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

  // 🔹 Common TextField Widget
  static Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: labelBlack, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primaryBlue, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: borderGray),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
