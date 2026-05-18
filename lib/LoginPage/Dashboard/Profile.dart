// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

// Your Popup Imports
import 'package:student_app/LoginPage/Dashboard/BasicDetails.dart';
import 'package:student_app/LoginPage/Dashboard/AcademicDetails.dart';
import 'package:student_app/LoginPage/Dashboard/SchlorshipDetails.dart';
import 'package:student_app/LoginPage/Dashboard/HealthDetails.dart';
import 'package:student_app/LoginPage/Dashboard/social_skill.dart';

// --- I. DATA STATUS ENUM ---
enum ProfileDataStatus { initial, loading, loaded, error, connectionError }

const Color primaryBlue = Color(0xFF1976D2);
const Color academicTeal = Color(0xFF009688);
const Color healthRed = Color(0xFFE53935);
const Color defaultBlack = Color(0xFF424242);

class StudentProfilePage extends StatefulWidget {
  final String title;
  const StudentProfilePage({super.key, required this.title});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  // --- II. STATE MANAGEMENT VARIABLES ---
  ProfileDataStatus _status = ProfileDataStatus.initial;
  String _errorMessage = "";
  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Map<String, List<String>> processRecords(String input) {
    List<String> records = input.split('record#').where((record) => record.isNotEmpty).toList();
    Map<String, List<String>> resultMap = {};

    for (var record in records) {
      List<String> items = record.split('&');
      for (var item in items) {
        List<String> parts = item.split('#');
        if (parts.length == 2) {
          String key = parts[0];
          String value = parts[1];
          resultMap.putIfAbsent(key, () => []);
          resultMap[key]!.add(value);
        }
      }
    }
    return resultMap;
  }

  // --- III. REFINED FETCH DATA WITH ERROR HANDLING ---
  Future<void> _fetchStudentData() async {
    setState(() {
      _status = ProfileDataStatus.loading;
      _errorMessage = "";
    });

    try {
      String query = "select fathername,mothername,contactno,fcontact,mcontact, "
          "dob, tusertbl.adhar, gender, bgroup, street, pnative, admno, stsno, usnno, "
          "caste, category, religion, height, weight, mail "
          "from trueguide.tstudenttbl, trueguide.tusertbl "
          "where tstudenttbl.usrid=tusertbl.usrid "
          "and tusertbl.usrid='${Glb.userid}' and studid='${Glb.student_id}'";

      String rawResponse = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      // --- Precise Error Handling (Like Social Skills Code) ---
      if (rawResponse == "101") {
        _status = ProfileDataStatus.connectionError;
        _errorMessage = "Unable to reach server. Please check internet connection.";
      } 
      else if (rawResponse == "0") {
        _status = ProfileDataStatus.error;
        _errorMessage = "No profile data found for this student.";
      } 
      else if (rawResponse == "2") {
        _status = ProfileDataStatus.error;
        _errorMessage = "Security Error / Session Expired (Code 2).";
      } 
      else if (rawResponse.startsWith("record#")) {
        Map<String, List<String>> processedData = processRecords(rawResponse);
        _mapDataToGlobals(processedData);
        _status = ProfileDataStatus.loaded;
      } 
      else {
        _status = ProfileDataStatus.error;
        _errorMessage = "Unexpected Server Response: $rawResponse";
      }
    } catch (e) {
      _status = ProfileDataStatus.error;
      _errorMessage = "Connection Failed: ${e.toString()}";
    } finally {
      setState(() {});
    }
  }

  void _mapDataToGlobals(Map<String, List<String>> data) {
    Glb.father_name     = data['X^1_1']?[0] ?? "NA";
    Glb.mother_name     = data['X^2_2']?[0] ?? "NA";
    Glb.contact_no      = data['X^3_3']?[0] ?? "NA";
    Glb.fcontact        = data['X^4_4']?[0] ?? "NA";
    Glb.mcontact        = data['X^5_5']?[0] ?? "NA";
    Glb.date_of_birth   = data['X^6_6']?[0] ?? "NA";
    Glb.aadhar_no       = data['X^7_7']?[0] ?? "NA";
    Glb.gender          = data['X^8_8']?[0] ?? "NA";
    Glb.blood_group     = data['X^9_9']?[0] ?? "NA";
    Glb.address         = data['X^10_10']?[0] ?? "NA";
    Glb.permanant_addr  = data['X^11_11']?[0] ?? "NA";
    Glb.admission_no    = data['X^12_12']?[0] ?? "NA";
    Glb.stsno           = data['X^13_13']?[0] ?? "NA";
    Glb.usnno           = data['X^14_14']?[0] ?? "NA";
    Glb.caste           = data['X^15_15']?[0] ?? "NA";
    Glb.category        = data['X^16_16']?[0] ?? "NA";
    Glb.religion        = data['X^17_17']?[0] ?? "NA";
    Glb.height          = data['X^18_18']?[0] ?? "0";
    Glb.weight          = data['X^19_19']?[0] ?? "0";
    Glb.email_id        = data['X^20_20']?[0] ?? "NA";
  }

  // --- IV. REFINED UPDATE TASK WITH FEEDBACK ---
  Future<void> _updateInfoTask(String det, String newValue, String query) async {
    // Show non-blocking loading if needed, or overlay
    setState(() => _status = ProfileDataStatus.loading);

    try {
      String updateRes = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (updateRes == "0") {
        setState(() => _syncGlobalVariables(det, newValue));
        Fluttertoast.showToast(msg: "Upload Successfully", backgroundColor: Colors.green);
      } 
      else if (updateRes == "101") {
        Fluttertoast.showToast(msg: "Update Failed: Server Unreachable", backgroundColor: Colors.red);
      }
      else {
        Fluttertoast.showToast(msg: "Update Error: Code $updateRes", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "System Error: Update Failed", backgroundColor: Colors.red);
    } finally {
      setState(() => _status = ProfileDataStatus.loaded);
    }
  }

  void _syncGlobalVariables(String det, String val) {
    if (det == "fname") Glb.father_name = val;
    else if (det == "mname") Glb.mother_name = val;
    else if (det == "scontact") Glb.contact_no = val;
    else if (det == "aadharno") Glb.aadhar_no = val;
    else if (det == "address") Glb.address = val;
    else if (det == "height") Glb.height = val;
    else if (det == "weight") Glb.weight = val;
    else if (det == "Religion") Glb.religion = val;
    else if (det == "Caste") Glb.caste = val;
    else if (det == "Category") Glb.category = val;
    else if (det == "BloodGroup") Glb.blood_group = val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 94, 187),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildMainContent(),
    );
  }

  // --- V. DYNAMIC BODY CONTENT (Like _buildBody in Social Skills) ---
  Widget _buildMainContent() {
    if (_status == ProfileDataStatus.loading && Glb.usnno == "NA") {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            SizedBox(height: 20),
            Text("Gathering Student Information...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (_status == ProfileDataStatus.connectionError || _status == ProfileDataStatus.error) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 15),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchStudentData, 
                child: const Text("Retry Connection")
              )
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUpdateCard(
                title: "Update Basic Details",
                icon: Icons.person_outline,
                iconColor: primaryBlue,
                onTap: () => UpdateBasicDetailsPopup.show,
              ),
              _buildUpdateCard(
                title: "Update Educational Details",
                icon: Icons.school_outlined,
                iconColor: academicTeal,
                onTap: () => AcademicDetailsPopup.show,
              ),
              _buildUpdateCard(
                title: "Update Scholarship Details",
                icon: Icons.workspace_premium_outlined,
                iconColor: academicTeal,
                onTap: () => ScholarshipDetailsPopup.show,
              ),
              _buildUpdateCard(
                title: "Update Health Details",
                icon: Icons.favorite_outline,
                iconColor: healthRed,
                onTap: () => HealthDetailsPopup.show,
              ),
              _buildUpdateCard(
                title: "Social & Skills",
                icon: Icons.psychology_outlined,
                iconColor: Colors.purple,
                onTap: () => Navigator.push,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (_status == ProfileDataStatus.loading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          )
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 0, 94, 187),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[200],
              child: Text(
                Glb.student_name.isNotEmpty ? Glb.student_name[0] : "S",
                style: const TextStyle(fontSize: 40, color: primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            Glb.student_name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          Text(
            "USN: ${Glb.usnno}",
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard({required String title, required IconData icon, required VoidCallback onTap, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4))
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: defaultBlack)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}