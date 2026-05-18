import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/studentfeautures/ViewTimeTable.dart';

SocketService socketService = SocketService();

class FullWeekTimetable extends StatefulWidget {
  const FullWeekTimetable({Key? key}) : super(key: key);

  @override
  State<FullWeekTimetable> createState() => _FullWeekTimetableState();
}

class _FullWeekTimetableState extends State<FullWeekTimetable> {
  void initState() {
    super.initState();
    get_all_days_and_dates();
    fill_with_data();
  }

  List<Data_FullWeek_TT> data = [];
  void get_all_days_and_dates() {
    if (Glb.Days_to_Date.length > 0) {
      DateTime date = DateTime.now();

      String Today_Day = DateFormat("EE", 'en').format(date);
      String Today_Date = DateFormat("yyyy-MM-dd").format(date);

      String? map_date = Glb.Days_to_Date[Today_Day];

      if (map_date == Today_Date) {
        return;
      } else {
        Glb.Days_to_Date.clear();
      }
    }

    DateTime date = DateTime.now();
    String Today_Day = DateFormat("EE", 'en').format(date);
    String Today_Date = DateFormat("yyyy-MM-dd").format(date);

    Glb.Days_to_Date[Today_Day] = Today_Date;

    if (Today_Day == "Mon") {
      for (int i = 0; i < 6; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }
    }

    if (Today_Day == "Tue") {
      for (int i = 0; i < 5; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }

      DateTime prev_date = date.subtract(const Duration(days: 1));
      String prv_date = DateFormat("yyyy-MM-dd").format(prev_date);
      String prev_day = DateFormat("EE", 'en').format(prev_date);
      Glb.Days_to_Date[prev_day] = prv_date;
    }

    if (Today_Day == "Wed") {
      for (int i = 0; i < 4; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }

      for (int i = 0; i < 2; i++) {
        DateTime prev_date = date.subtract(Duration(days: 1 + i));
        String prv_date = DateFormat("yyyy-MM-dd").format(prev_date);
        String prev_day = DateFormat("EE", 'en').format(prev_date);
        Glb.Days_to_Date[prev_day] = prv_date;
      }
    }

    if (Today_Day == "Thu") {
      for (int i = 0; i < 3; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }

      for (int i = 0; i < 3; i++) {
        DateTime prev_date = date.subtract(Duration(days: 1 + i));
        String prv_date = DateFormat("yyyy-MM-dd").format(prev_date);
        String prev_day = DateFormat("EE", 'en').format(prev_date);
        Glb.Days_to_Date[prev_day] = prv_date;
      }
    }

    if (Today_Day == "Fri") {
      for (int i = 0; i < 2; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }

      for (int i = 0; i < 4; i++) {
        DateTime prev_date = date.subtract(Duration(days: 1 + i));
        String prv_date = DateFormat("yyyy-MM-dd").format(prev_date);
        String prev_day = DateFormat("EE", 'en').format(prev_date);
        Glb.Days_to_Date[prev_day] = prv_date;
      }
    }

    if (Today_Day == "Sat") {
      DateTime next_date = date.add(const Duration(days: 1));
      String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
      String nxt_day = DateFormat("EE", 'en').format(next_date);
      Glb.Days_to_Date[nxt_day] = nxt_date;

      for (int i = 0; i < 5; i++) {
        DateTime prev_date = date.subtract(Duration(days: 1 + i));
        String prv_date = DateFormat("yyyy-MM-dd").format(prev_date);
        String prev_day = DateFormat("EE", 'en').format(prev_date);
        Glb.Days_to_Date[prev_day] = prv_date;
      }
    }

    if (Today_Day == "Sun") {
      for (int i = 0; i < 6; i++) {
        DateTime next_date = date.add(Duration(days: i + 1));
        String nxt_date = DateFormat("yyyy-MM-dd").format(next_date);
        String nxt_day = DateFormat("EE", 'en').format(next_date);
        Glb.Days_to_Date[nxt_day] = nxt_date;
      }
    }
  }

  final List<String> days = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  List<Data_FullWeek_TT> fill_with_data() {
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Mon"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Tue"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Wed"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Thu"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Fri"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Sat"]}", Icons.calendar_month));
    data.add(
        Data_FullWeek_TT("${Glb.Days_to_Date["Sun"]}", Icons.calendar_month));

    print("Data Is : $data");

    return data;
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime(2026, 1, 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Full-Week Timetable"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: Colors.orange,
            padding: const EdgeInsets.all(16),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.calendar_month, size: 40),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return _timeTableCard(
                  day: days[index],
                  date: item.title.replaceAll("", ""),
                  icon: item.imageId,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DayTimetableUI(
                                  days: days[index],
                                  item: item.title,
                                )));
                    debugPrint("Clicked ${days[index]} - ${item.title}");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeTableCard({
    required String day,
    required String date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26),
                Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: $date",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xffFF7A18), Color(0xffFFD194)],
                        ),
                      ),
                      child: const Text(
                        "VIEW TIME TABLE",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Data_FullWeek_TT {
  String title;
  IconData imageId;

  Data_FullWeek_TT(this.title, this.imageId);
}
