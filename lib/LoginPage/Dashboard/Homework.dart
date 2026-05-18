import 'package:flutter/material.dart';
import 'package:student_app/LoginPage/Dashboard/Dashboard.dart';

void main() {
  runApp(const HomeworkApp());
}

class HomeworkApp extends StatelessWidget {
  const HomeworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeworkScreen(),
    );
  }
}

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String selectedDate = "2025-10-29";

  final List<String> pastDates = [
    "2025-11-06",
    "2025-10-11",
    "2025-09-28",
    "2025-08-15",
  ];

  // === Custom Color Palette ===
  final Color primaryBlue = const Color(0xFF1976D2); // Deep Professional Blue
  final Color accentGrey = const Color(0xFF455A64); // Text and icon color
  final Color backgroundGrey = const Color(0xFFF5F6FA); // Page background
  final Color headerColor = const Color(0xFF1E88E5); // Header gradient/blue tone

  // Show dialog to select date
  void _showDateSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  children: [
                    Icon(Icons.event_note, color: primaryBlue, size: 26),
                    const SizedBox(width: 8),
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // List of Dates
                ListView.separated(
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
                  shrinkWrap: true,
                  itemCount: pastDates.length,
                  itemBuilder: (context, index) {
                    final date = pastDates[index];
                    return _buildDateListItem(context, date);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Date item widget
  Widget _buildDateListItem(BuildContext context, String date) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(10),
      splashColor: primaryBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.calendar_month,
                size: 28,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              date,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(103, 50, 32, 1),
        titleSpacing: 0,
        title: Row(
          children: [
            // ⬅️ Back Arrow beside "Home-Work"
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 26),
              onPressed: () {
                // ✅ Always go to Home Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentDashboard1()),
                );
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "Home-Work",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (Clickable)
            GestureDetector(
              onTap: _showDateSelectionDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, const Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Click here to check past homework",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Homework Container
            Container(
              margin: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Homework for $selectedDate appears here.',
                  style: TextStyle(
                    color: accentGrey,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
