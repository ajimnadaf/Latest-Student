import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Subject Model ---
class Subject {
  final String name;
  final IconData icon;
  final Color color;

  const Subject(this.name, this.icon, this.color);
}

class AttendancePerformancePage extends StatefulWidget {
  const AttendancePerformancePage({super.key});

  @override
  State<AttendancePerformancePage> createState() =>
      _AttendancePerformancePageState();
}

class _AttendancePerformancePageState extends State<AttendancePerformancePage> {
  bool offlineSelected = false;
  bool onlineSelected = false;
  DateTime? fromDate;
  DateTime? tillDate;

  final Color primaryBlue = const Color(0xFF1976D2);
  final Color softGray = const Color(0xFFF4F6FA);

  // --- Subject List ---
  final List<Subject> availableSubjects = const [
    Subject("Mathematics", Icons.calculate_rounded, Color(0xFFD32F2F)),
    Subject("Physics", Icons.science_rounded, Color(0xFF2E7D32)),
    Subject("Computer Science", Icons.computer_rounded, Color(0xFF1565C0)),
  ];

  late Subject _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = availableSubjects.first;
  }

  // 📅 Date picker
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          tillDate = picked;
        }
      });
    }
  }

  // 🎓 Subject selection popup (same as assessment)
  void _showSubjectSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Subject",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...availableSubjects.map((subject) {
                  final isSelected = _selectedSubject.name == subject.name;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedSubject = subject);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? subject.color.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(subject.icon,
                              color: subject.color, size: 30),
                          const SizedBox(width: 14),
                          Text(
                            subject.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? subject.color
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Main UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGray,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Color(0xFFEF6C00),
        title: const Text(
          "Attendance Performance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 Header Card with Gradient + Subject
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedSubject.color,
                      _selectedSubject.color.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedSubject.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_selectedSubject.icon,
                        color: Colors.white, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedSubject.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSubjectSelectionDialog,
                            child: const Text(
                              "Tap to change subject",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // CLASS TYPE SECTION
              const Text(
                "Class Type",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: offlineSelected,
                      onChanged: (v) =>
                          setState(() => offlineSelected = v ?? false),
                      title: const Text("Offline Attendance"),
                      secondary: Icon(Icons.class_rounded,
                          color: offlineSelected
                              ? _selectedSubject.color
                              : Colors.grey),
                      activeColor: _selectedSubject.color,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const Divider(height: 0),
                    CheckboxListTile(
                      value: onlineSelected,
                      onChanged: (v) =>
                          setState(() => onlineSelected = v ?? false),
                      title: const Text("Online Attendance"),
                      secondary: Icon(Icons.laptop_mac_rounded,
                          color: onlineSelected
                              ? _selectedSubject.color
                              : Colors.grey),
                      activeColor: _selectedSubject.color,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // DATE RANGE
              const Text(
                "Select Date Range",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildDateTile(
                label: "From Date",
                date: fromDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 15),
              _buildDateTile(
                label: "Till Date",
                date: tillDate,
                onTap: () => _selectDate(context, false),
              ),

              const SizedBox(height: 35),

              // BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Viewing attendance...")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    backgroundColor: _selectedSubject.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 3,
                  ),
                  child: const Text(
                    "VIEW ATTENDANCE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📅 Reusable Date Tile
  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? "Tap to select date"
                      : DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.black54, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
