import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/Profile.dart';
import 'package:student_app/LoginPage/Dashboard/Password.dart';
import 'package:student_app/LoginPage/Dashboard/Form.dart';
import 'package:student_app/LoginPage/login.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/Services/SharedPreKey.dart';
import 'package:student_app/Services/shared_preffrences.dart';

SharedPreferenceService pref = SharedPreferenceService();
SocketService socketService = SocketService();

// --- COLOR PALETTE FOR ICON THEMES ---
const Color securityColor =
    Color(0xFF00C853); // Bright Green for Security/Identity
const Color actionColor = Color(0xFFFF9800); // Amber/Orange for Action/Forms
const Color infoColor =
    Color(0xFF1E88E5); // Bright Blue for Information/Support
const Color logoutColor = Color(0xFFD32F2F); // Deep Red for Critical Action
const Color defaultColor = Colors.black87; // Default black for other text

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Drawer UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- HOME PAGE (Container for the Drawer) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
      ),
      drawer: const StudentDrawer(),
      body: const Center(
        child: Text("Main Dashboard Content"),
      ),
    );
  }
}

// --- STUDENT DRAWER WITH THEMED ICONS ---
class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🟦 Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF42A5F5)], // Blue Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: defaultColor),
            ),
            accountName: Text(
              "${Glb.student_name}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: null,
          ),

          // 🟩 IDENTITY & SECURITY
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: "Profile",
            page: const StudentProfilePage(title: "Profile Page"),
            iconColor: securityColor,
          ),
          _buildDrawerItem(
            icon: Icons.lock_outline,
            text: "Change Password",
            page: const SetNewCredentialsPage(title: "Change Password"),
            iconColor: securityColor,
          ),

          const Divider(),

          // 🟧 ACTION & FORMS
          _buildDrawerItem(
            icon: Icons.assignment_outlined,
            text: "Student Clearance Form",
            page: const StudentClearanceForm(title: "Student Clearance Form"),
            iconColor: actionColor,
          ),
          _buildDrawerItem(
            icon: Icons.edit_note,
            text: "Raise A Complaint",
            page: const DummyPage(title: "Raise A Complaint"),
            iconColor: actionColor,
          ),

          const Divider(),

          // 🟦 INFORMATION & SUPPORT
          _buildDrawerItem(
            icon: Icons.help_outline,
            text: "Help",
            page: const DummyPage(title: "Help Page"),
            iconColor: infoColor,
          ),
          _buildDrawerItem(
            icon: Icons.question_answer,
            text: "FAQ",
            page: const DummyPage(title: "FAQ"),
            iconColor: infoColor,
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            text: "About Us",
            page: const DummyPage(title: "About Us"),
            iconColor: infoColor,
          ),

          const Divider(),

          // 🟥 CRITICAL ACTION (Logout)
          ListTile(
            leading: const Icon(Icons.logout, color: logoutColor),
            title: const Text(
              "Log Out",
              style: TextStyle(
                fontSize: 16,
                color: logoutColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Confirm Logout",
                    style: TextStyle(
                      color: logoutColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text("Are you sure you want to log out?"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoutColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await pref.saveString(Sharedprekey.LoginIdKey, "NA");
                        await pref.saveString(Sharedprekey.Paasswdkey, "NA");
                        await pref.saveString(Sharedprekey.HostIDkey, "NA");
                        Navigator.pop(context); // close popup
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text("Log Out"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔧 Drawer Item Helper
  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required Widget page,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title:
          Text(text, style: const TextStyle(fontSize: 16, color: defaultColor)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

// --- DUMMY PAGE FOR TESTING ---
class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
