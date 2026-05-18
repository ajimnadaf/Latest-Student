import 'package:flutter/material.dart';

// --- Subject Data Model ---
class Subject {
  final String name;
  final IconData icon;
  final Color color; // icon color
  final Color headerColor; // header gradient start

  const Subject(this.name, this.icon, this.color, this.headerColor);
}

class ViewTopicsScreen extends StatefulWidget {
  const ViewTopicsScreen({super.key});

  @override
  State<ViewTopicsScreen> createState() => _ViewTopicsScreenState();
}

class _ViewTopicsScreenState extends State<ViewTopicsScreen> {
  final List<Subject> availableSubjects = const [
    Subject("ENGLISH", Icons.menu_book_rounded, Color(0xFF1976D2), Color(0xFF42A5F5)),
    Subject("MATHS", Icons.calculate_rounded, Color(0xFFD32F2F), Color(0xFFFF7043)),
    Subject("SCIENCE", Icons.science_rounded, Color(0xFF2E7D32), Color(0xFF66BB6A)),
    Subject("HISTORY", Icons.museum_rounded, Color(0xFF6A1B9A), Color(0xFFAB47BC)),
  ];

  late Subject _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = availableSubjects.first;
  }

  // 📋 Subject selection dialog
  void _showSubjectSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Subject",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...availableSubjects.map((subject) => _buildSubjectListItem(subject)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectListItem(Subject subject) {
    final isSelected = _selectedSubject.name == subject.name;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() => _selectedSubject = subject);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? subject.headerColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(subject.icon, color: subject.color, size: 32),
            const SizedBox(width: 14),
            Text(
              subject.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? subject.color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧩 Main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 121, 107),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ White back arrow
        title: const Text(
          "View Topics",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎨 Header with Gradient
          GestureDetector(
            onTap: _showSubjectSelectionDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_selectedSubject.headerColor, _selectedSubject.color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(_selectedSubject.icon, color: Colors.white, size: 42),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSubject.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Tap to change subject",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📚 Chapter Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header of Chapter Card
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.folder_rounded,
                              color: _selectedSubject.color, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Chapter 1 - ${_selectedSubject.name}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "DOCS: Introduction & Overview",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Click to view sub-chapters",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    // Placeholder for sub-topics list
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Sub-chapters and topics will appear here...",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
