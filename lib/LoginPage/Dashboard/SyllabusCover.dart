import 'package:flutter/material.dart';

class SyllabusCoveragePage extends StatefulWidget {
  const SyllabusCoveragePage({super.key});

  @override
  State<SyllabusCoveragePage> createState() => _SyllabusCoveragePageState();
}

class _SyllabusCoveragePageState extends State<SyllabusCoveragePage> {
  // Default selected value
  String selectedValue = "Today's Syllabus";

  // Dropdown options
  final List<String> syllabusOptions = [
    "Today's Syllabus",
    "This Week's Syllabus",
    "Completed Syllabus",
    "Pending Syllabus",
  ];

  // Professional color theme
  final Color primaryColor = const Color(0xFF1976D2); // Deep blue
  final Color accentColor = const Color(0xFF009688); // Teal accent
  final Color backgroundColor = const Color(0xFFF7F9FC); // Soft background
  final Color cardColor = Colors.white;
  final Color borderColor = Colors.black26;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Syllabus Coverage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Body Section
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Row(
              children: [
                Icon(Icons.menu_book_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Syllabus Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Dropdown Container
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  isExpanded: true,
                  items: syllabusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(
                            value == "Today's Syllabus"
                                ? Icons.today_rounded
                                : value == "This Week's Syllabus"
                                    ? Icons.calendar_month_rounded
                                    : value == "Completed Syllabus"
                                        ? Icons.check_circle_rounded
                                        : Icons.pending_actions_rounded,
                            color: value == "Completed Syllabus"
                                ? Colors.green[700]
                                : value == "Pending Syllabus"
                                    ? Colors.orange[800]
                                    : primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Display Selection Result (Stylized Card)
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      selectedValue == "Completed Syllabus"
                          ? Icons.check_circle_rounded
                          : selectedValue == "Pending Syllabus"
                              ? Icons.pending_rounded
                              : Icons.menu_book_rounded,
                      color: selectedValue == "Completed Syllabus"
                          ? Colors.green[700]
                          : selectedValue == "Pending Syllabus"
                              ? Colors.orange[800]
                              : accentColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedValue,
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getStatusDescription(selectedValue),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function for custom text description
  String _getStatusDescription(String value) {
    switch (value) {
      case "Today's Syllabus":
        return "View lessons planned for today and track progress.";
      case "This Week's Syllabus":
        return "Review the topics and goals set for this week.";
      case "Completed Syllabus":
        return "See the portions that have been successfully completed.";
      case "Pending Syllabus":
        return "Check the remaining syllabus yet to be covered.";
      default:
        return "";
    }
  }
}
