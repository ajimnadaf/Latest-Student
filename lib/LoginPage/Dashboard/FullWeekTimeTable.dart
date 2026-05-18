// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullWeekTimeTablePage extends StatelessWidget {
  const FullWeekTimeTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1976D2);
    const Color lightGrey = Color(0xFFF5F7FA);

    final now = DateTime.now();

    // Generate full week (starting Monday)
    final weekDays = List.generate(7, (i) {
      final date = now.add(Duration(days: i - now.weekday + 1));
      return {
        'day': DateFormat('EEE').format(date).toUpperCase(),
        'date': DateFormat('dd-MM-yyyy').format(date),
      };
    });

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Full Week Timetable",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =================== BODY ===================
      body: Column(
        children: [
          // --- Blue header ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "View your complete weekly timetable below",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --- List of week days ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final dayInfo = weekDays[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // --- Left icon box ---
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: primaryBlue,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // --- Day + Date ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayInfo['day']!,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayInfo['date']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- View button ---
                        Container(
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Viewing timetable for ${dayInfo['day']}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: primaryBlue,
                                    duration:
                                        const Duration(milliseconds: 1000),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(
                                  "VIEW",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
