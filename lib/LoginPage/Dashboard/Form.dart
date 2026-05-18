import 'package:flutter/material.dart';

class StudentClearanceForm extends StatefulWidget {
  const StudentClearanceForm({super.key, required String title});

  @override
  State<StudentClearanceForm> createState() => _StudentClearanceFormState();
}

class _StudentClearanceFormState extends State<StudentClearanceForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Student Clearance Form",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),

            const SizedBox(height: 16),

            _buildSectionTitle("🎓 Scholarship Details"),
            _buildCard(
              _buildTable([
                ["Year", "Class", "Scholarship", "Applied Date", "Sanctioned Date", "Sanctioned Amount", "Released Amount"],
                ["-", "-", "-", "-", "-", "-", "-"]
              ]),
            ),

            const SizedBox(height: 16),

            _buildSectionTitle("📘 Subject Teacher Remarks"),
            _buildCard(
              _buildTableWithIcons([
                ["ENGLISH", "SUHANA NADAF", "Good progress", "45/50", "90.00"],
                ["MATHS", "AAMIR PATIL", "Needs Improvement", "30/50", "60.00"],
                ["SCIENCE", "ANITA MORE", "Excellent", "48/50", "96.00"],
              ]),
            ),

            const SizedBox(height: 16),

            _buildSectionTitle("🗒️ Other Remarks"),
            _buildCard(
              _buildTable([
                ["Remarks Category", "Date", "Remark"],
                ["Discipline", "2025-10-01", "Good behavior"]
              ]),
            ),

            const SizedBox(height: 16),

            _buildSectionTitle("📚 Library Books (Not Returned)"),
            _buildCard(
              _buildTable([
                ["Book Name", "Author", "Issue Date", "Due Date", "Fine"],
                ["Physics", "S. Chand", "2025-10-13", "2025-10-20", "0"],
                ["Chemistry", "ABC", "2025-10-12", "2025-10-20", "10"],
              ]),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Authorised Signatory",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Header Section
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        border: Border.all(color: Colors.teal.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("STUDENT CLEARANCE REPORT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text("Name: AJIM RAMJAN NADAF"),
          Text("Class: CLASS 1(A)"),
          Text("Date: Thu Oct 30, 2025"),
        ],
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade100.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // 🔹 Card Container
  Widget _buildCard(Widget child) {
    return Card(
      elevation: 1,
      shadowColor: Colors.teal.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }

  // 🔹 Basic Table
  Widget _buildTable(List<List<String>> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: data.map((row) {
        return TableRow(
          children: row.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                cell,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // 🔹 Table with performance icons
  Widget _buildTableWithIcons(List<List<String>> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE0F2F1)),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Subject", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Teacher", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Remarks", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Marks", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("Perf (%)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        for (var row in data)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row[0], textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row[1], textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getPerformanceIcon(row[2]),
                    const SizedBox(width: 4),
                    Flexible(child: Text(row[2], textAlign: TextAlign.center)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row[3], textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(row[4], textAlign: TextAlign.center),
              ),
            ],
          ),
      ],
    );
  }

  // 🔹 Icon logic based on remarks/performance
  Icon _getPerformanceIcon(String remark) {
    if (remark.toLowerCase().contains("excellent")) {
      return const Icon(Icons.star, color: Colors.green, size: 18);
    } else if (remark.toLowerCase().contains("good")) {
      return const Icon(Icons.check_circle, color: Colors.teal, size: 18);
    } else if (remark.toLowerCase().contains("improve")) {
      return const Icon(Icons.warning, color: Colors.orange, size: 18);
    } else {
      return const Icon(Icons.info_outline, color: Colors.grey, size: 18);
    }
  }
}
