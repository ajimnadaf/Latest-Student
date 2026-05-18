// lib/LoginPage/Dashboard/OnlineExam.dart

import 'package:student_app/LoginPage/Dashboard/Examination.dart';

import 'package:flutter/material.dart';
import 'package:student_app/LoginPage/Dashboard/Avg_marks.dart';

class OnlineExamScreen extends StatefulWidget {
  const OnlineExamScreen({super.key});

  @override
  State<OnlineExamScreen> createState() => _OnlineExamScreenState();
}

class _OnlineExamScreenState extends State<OnlineExamScreen> {
  final List<Subject> availableSubjects = const [
    Subject("ENGLISH", Icons.menu_book_rounded, Color(0xFF1976D2),
        Color(0xFF42A5F5)),
    Subject("MATHEMATICS", Icons.calculate_rounded, Color(0xFFD32F2F),
        Color(0xFFFF7043)),
    Subject(
        "SCIENCE", Icons.science_rounded, Color(0xFF2E7D32), Color(0xFF66BB6A)),
    Subject(
        "HISTORY", Icons.museum_rounded, Color(0xFF6A1B9A), Color(0xFFAB47BC)),
  ];

  late Subject _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = availableSubjects.first;
  }

  // --------------------- Subject Popup Dialog ---------------------
  void _showSubjectSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                const Text(
                  "SELECT SUBJECT",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = availableSubjects[index];
                    return _buildSubjectListItem(context, subject);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectListItem(BuildContext context, Subject subject) {
    final isSelected = _selectedSubject.name == subject.name;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSubject = subject;
        });
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.menu_book,
              size: 36,
              color: subject.color,
            ),
            const SizedBox(width: 16),
            Text(
              subject.name,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? subject.color : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- Marks Options Popup (PIE CHART FUNCTIONALITY) ---------------------
  void _showMarksOptionsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SELECT MARKS REPORT",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              const SizedBox(height: 15),

              // --- 1️⃣ Subject-wise Chart (Exam Performance) ---
              GestureDetector(
                child: Row(
                  children: [
                    Icon(Icons.menu_book,
                        color: Colors.blue.shade700, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${_selectedSubject.name} MARKS IN ALL EXAMS",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- 2️⃣ Average Chart (Avg Percentage) ---
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AvgPercentageChart(
                        subject: _selectedSubject,
                        isAverage: true, // All subjects average marks
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.stacked_bar_chart,
                        color: Colors.teal.shade700, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "AVG. % OF ALL SUBJECTS IN ALL EXAMS",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 1,
        // --- White Back Arrow Icon ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Online Exams",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.pie_chart,
              color: Colors.white,
              size: 30,
            ),
            // ✅ CALLS THE POPUP
            onPressed: _showMarksOptionsPopup,
          ),
          const SizedBox(width: 4),
        ],
      ),

      // --- Body Section ---
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with subject info
          GestureDetector(
            onTap: _showSubjectSelectionDialog,
            child: Container(
              width: double.infinity,
              color: _selectedSubject.headerColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    _selectedSubject.icon,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSubject.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Click here to change subject",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main body text
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Center(
                child: Text(
                  "No exams available for ${_selectedSubject.name}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
