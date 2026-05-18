// Placeholder for data model and mock service

import 'package:student_app/GlobalClasses/Glb.dart' as glb;

/// Data Model for Student Basic Details
class StudentData {
  String studentName;
  String fatherName;
  String motherName;
  String studentContact;
  String fatherContact;
  String motherContact;
  String dob; // Use yyyy-MM-dd format internally
  String aadharNo;
  String gender;
  String presentAddress;
  String permanentAddress;
  String email;
  String bloodGroup;

  StudentData({
    required this.studentName,
    required this.fatherName,
    required this.motherName,
    required this.studentContact,
    required this.fatherContact,
    required this.motherContact,
    required this.dob,
    required this.aadharNo,
    required this.gender,
    required this.presentAddress,
    required this.permanentAddress,
    required this.email,
    required this.bloodGroup,
  });

  // Utility to format DOB for UI (dd-MM-yyyy)
  String get formattedDob {
    if (dob.contains('-')) {
      final parts = dob.split('-');
      // Assuming dob is yyyy-MM-dd
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }
    return dob;
  }
}

/// Mock Service to simulate fetching student data from the server
class StudentService {
  // Simulates sreg.get_personal_details_from_userids()
  static Future<StudentData> fetchBasicDetails() async {
    // Simulating a network delay (like in Java's AsyncTask)
    await Future.delayed(const Duration(seconds: 2));

    // This data should come from your backend/library call (like Login.sreg.glbObj)
    return StudentData(
      studentName: "${glb.student_name}",
      fatherName: "${glb.father_name}",
      motherName: "JANE DOE",
      studentContact: "9876543210",
      fatherContact: "9998887770",
      motherContact: "NA",
      dob: "2008-05-15", // Internal format
      aadharNo: "123456789012",
      gender: "Male",
      presentAddress: "123 Main St, Apt A, Current City",
      permanentAddress: "456 Side Ave, City B, Native Place",
      email: "anthropic@school.com",
      bloodGroup: "O+",
    );
  }

  // Example list of Blood Groups (would typically come from a DB lookup)
  static final List<String> bloodGroups = [
    "Select",
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-"
  ];
}
