// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodaysTimetablePage extends StatefulWidget {
  const TodaysTimetablePage({super.key});

  @override
  State<TodaysTimetablePage> createState() => _TodaysTimetablePageState();
}

class _TodaysTimetablePageState extends State<TodaysTimetablePage> {
  String todayDay = '';
  String todayDate = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    todayDay = DateFormat('EEE').format(now).toUpperCase();
    todayDate = DateFormat('dd-MM-yyyy').format(now);
  }

  void _refreshPage() {
    setState(() {
      final now = DateTime.now();
      todayDay = DateFormat('EEE').format(now).toUpperCase();
      todayDate = DateFormat('dd-MM-yyyy').format(now);
    });
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
          "Today's Timetable",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ================== BODY ==================
      body: Column(
        children: [
          // Header Section
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
                        todayDay,
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        todayDate,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Refresh Section ---
                InkWell(
                  onTap: _refreshPage,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: const [
                      Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Refresh Page",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Timetable Placeholder
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
                    Icon(Icons.access_time_filled_rounded,
                        size: 50, color: primaryBlue),
                    SizedBox(height: 12),
                    Text(
                      "Your timetable for today will appear here",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Check back later for updates 📅",
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
