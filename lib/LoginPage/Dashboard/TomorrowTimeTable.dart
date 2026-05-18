// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TomorrowsTimetablePage extends StatefulWidget {
  const TomorrowsTimetablePage({super.key});

  @override
  State<TomorrowsTimetablePage> createState() => _TomorrowsTimetablePageState();
}

class _TomorrowsTimetablePageState extends State<TomorrowsTimetablePage> {
  String tomorrowDay = '';
  String tomorrowDate = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    tomorrowDay = DateFormat('EEE').format(tomorrow).toUpperCase();
    tomorrowDate = DateFormat('dd-MM-yyyy').format(tomorrow);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1976D2);
    const Color softGrey = Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Tomorrow's Timetable",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // Blue header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- Date/Day Card ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: primaryBlue, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        tomorrowDay,
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tomorrowDate,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Decorative icon
                const Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.schedule_rounded,
                        size: 50, color: primaryBlue),
                    SizedBox(height: 12),
                    Text(
                      "Your timetable for tomorrow will appear here",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Stay ready for a productive day ahead 🌙",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
