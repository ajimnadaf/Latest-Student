import 'package:flutter/material.dart';
import 'package:student_app/LoginPage/Dashboard/BarChart.dart';
import 'package:student_app/LoginPage/Dashboard/LineChart.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

// --- Data Model for Charts ---
class ExamResult {
  final String exam;
  final double score;
  final int index;

  ExamResult(this.exam, this.score, this.index);
}

// Dummy Data
final List<ExamResult> examData = [
  ExamResult('FA-1', 75, 0),
  ExamResult('FA-3', 40, 1),
  ExamResult('FA-2', 25, 2),
];

// --- Main Report Widget ---
class ConsolidatedMarksReport extends StatelessWidget {
  final String subject; // ✅ Required subject

  const ConsolidatedMarksReport({super.key, required this.subject});

  // Professional colors
  static const Color _headerColor = Color(0xFFBBDEFB); // Light Blue
  static const Color _rowColor = Color(0xFFE3F2FD);    // Lighter Blue
  static const Color _allColumnColor = Color(0xFFC8E6C9); // Light Green
  static const Color _accentColor = Color(0xFF1976D2); // Dark Blue Accent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject - Marks Report'),
        backgroundColor: _accentColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15),
            _buildStudentInfo('Student Name', "${Glb.student_name}"),
            _buildStudentInfo('Roll Number', 'NA'),
            _buildStudentInfo('Class', 'CLASS 1(A)'),
            const SizedBox(height: 25),

            // --- Marks Table Section ---
            _buildMarksTable(_headerColor, _rowColor, _allColumnColor),
            const SizedBox(height: 30),

            // --- Aggregate Exam Performance Chart (Bar Chart) ---
            Text(
              'Aggregate Exam Performance',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _accentColor),
            ),
            const SizedBox(height: 10),
            const AggregateBarChart(),
            const SizedBox(height: 20),

            // --- Company Performance Chart (Line Chart) ---
            Text(
              'Company Performance',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _accentColor),
            ),
            const SizedBox(height: 10),
            const PerformanceLineChart(),
            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _accentColor,
        child: const Icon(Icons.description, color: Colors.white),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildStudentInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksTable(
      Color headerColor, Color rowColor, Color allColumnColor) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: headerColor),
          children: [
            _tableHeaderCell('Exams/Subject', headerColor),
            _tableHeaderCell('FA-2', headerColor),
            _tableHeaderCell('FA-3', headerColor),
            _tableHeaderCell('FA-1', headerColor),
            _tableHeaderCell('ALL', allColumnColor),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: rowColor),
          children: [
            _tableBodyCell(subject, rowColor, isSubject: true),
            _tableBodyCell('25.0% (5/20)', rowColor),
            _tableBodyCell('40.0% (8/20)', rowColor),
            _tableBodyCell('75.0% (15/20)', rowColor),
            _tableBodyCell('46.66%', allColumnColor),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: headerColor),
          children: [
            _tableBodyCell('TOTAL', headerColor, isSubject: true),
            _tableBodyCell('25.0%', headerColor),
            _tableBodyCell('40.0%', headerColor),
            _tableBodyCell('75.0%', headerColor),
            _tableBodyCell('46.66%', allColumnColor),
          ],
        ),
      ],
    );
  }

  Widget _tableHeaderCell(String text, Color color) {
    return Container(
      color: color,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableBodyCell(String text, Color color, {bool isSubject = false}) {
    return Container(
      color: color,
      alignment: isSubject ? Alignment.centerLeft : Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSubject ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
        textAlign: isSubject ? TextAlign.start : TextAlign.center,
      ),
    );
  }
}
