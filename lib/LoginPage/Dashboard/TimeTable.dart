import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/LoginPage/Dashboard/Attendence_perf.dart';
import 'package:student_app/studentfeautures/FullWeekTimeTable.dart';
import 'package:student_app/studentfeautures/ViewAttandanceper.dart';
import 'package:student_app/studentfeautures/today_timetable.dart';
import 'package:student_app/studentfeautures/tommorrow_time-table.dart';

class NewTimeTable extends StatefulWidget {
  const NewTimeTable({super.key});

  @override
  State<NewTimeTable> createState() => _NewTimeTableState();
}

class _NewTimeTableState extends State<NewTimeTable> {
  late DateTime today;
  late DateTime tomorrow;

  late String todayDay;
  late String tomorrowDay;
  late String todayDate;
  late String tomorrowDate;

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  void _initDates() {
    today = DateTime.now();
    tomorrow = today.add(const Duration(days: 1));

    todayDay = DateFormat('EEE').format(today).toUpperCase();
    Glb.todayDay = todayDay;
    tomorrowDay = DateFormat('EEE').format(tomorrow).toUpperCase();
    Glb.tommorow = tomorrowDay;

    if (todayDay == "MON") {
      Glb.day = "Mon";
      print("Glb.Day: ${Glb.day}");
    }
    if (todayDay == "TUE") {
      Glb.day = "Tue";
    }
    if (todayDay == "WED") {
      Glb.day = "Wed";
    }
    if (todayDay == "THU") {
      Glb.day = "Thu";
    }
    if (todayDay == "FRI") {
      Glb.day = "Fir";
    }
    if (todayDay == "SAT") {
      Glb.day = "Sat";
    }
    if (todayDay == "SUN") {
      Glb.day = "Sun";
    }

    print("Glb.day: $todayDay");

    if (tomorrowDay == "MON") {
      Glb.nextdayTom = "Mon";
    }
    if (tomorrowDay == "TUE") {
      Glb.nextdayTom = "Tue";
    }
    if (tomorrowDay == "WED") {
      Glb.nextdayTom = "Wed";
    }
    if (tomorrowDay == "THU") {
      Glb.nextdayTom = "Thu";
    }
    if (tomorrowDay == "FRI") {
      Glb.nextdayTom = "Fir";
    }
    if (tomorrowDay == "SAT") {
      Glb.nextdayTom = "Sat";
    }
    if (tomorrowDay == "SUN") {
      Glb.nextdayTom = "Sun";
    }

    todayDate = DateFormat('yyyy-MM-dd').format(today);
    Glb.tdy_date = todayDate;
    tomorrowDate = DateFormat('yyyy-MM-dd').format(tomorrow);
    Glb.date = tomorrowDate;
  }

  void getAllDaysAndDates() {
    if (Glb.Days_to_Date.isNotEmpty) {
      DateTime date = DateTime.now();
      String todayDay = _getDayName(date);
      String todayDate = _formatDate(date);

      String? mapDate = Glb.Days_to_Date[todayDay];
      if (mapDate == todayDate) {
        return;
      } else {
        Glb.Days_to_Date.clear();
      }
    }

    DateTime date = DateTime.now();
    String todayDay = _getDayName(date);
    String todayDate = _formatDate(date);

    Glb.Days_to_Date[todayDay] = todayDate;

    if (todayDay == "Mon") {
      for (int i = 0; i < 6; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }
    }

    if (todayDay == "Tue") {
      for (int i = 0; i < 5; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }

      DateTime prevDate = date.subtract(const Duration(days: 1));
      Glb.Days_to_Date[_getDayName(prevDate)] = _formatDate(prevDate);
    }

    if (todayDay == "Wed") {
      for (int i = 0; i < 4; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }

      for (int i = 0; i < 2; i++) {
        DateTime prevDate = date.subtract(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(prevDate)] = _formatDate(prevDate);
      }
    }

    if (todayDay == "Thu") {
      for (int i = 0; i < 3; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }

      for (int i = 0; i < 3; i++) {
        DateTime prevDate = date.subtract(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(prevDate)] = _formatDate(prevDate);
      }
    }

    if (todayDay == "Fri") {
      for (int i = 0; i < 2; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }

      for (int i = 0; i < 4; i++) {
        DateTime prevDate = date.subtract(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(prevDate)] = _formatDate(prevDate);
      }
    }

    if (todayDay == "Sat") {
      DateTime nextDate = date.add(const Duration(days: 1));
      Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);

      for (int i = 0; i < 5; i++) {
        DateTime prevDate = date.subtract(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(prevDate)] = _formatDate(prevDate);
      }
    }

    if (todayDay == "Sun") {
      for (int i = 0; i < 6; i++) {
        DateTime nextDate = date.add(Duration(days: i + 1));
        Glb.Days_to_Date[_getDayName(nextDate)] = _formatDate(nextDate);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _getDayName(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  Future<void> _onTodayTap() async {
    debugPrint("Today Time Table tapped");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodayTimeTablePage()));
    await Future.delayed(const Duration(milliseconds: 300));
    // Navigator.push(...)
  }

  Future<void> _onTomorrowTap() async {
    Glb.from_feature = "Tomo";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TommorrowTimePage()));

    debugPrint("Tomorrow Time Table tapped");
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _onFullWeekTap() async {
    Glb.from_feature = "FullWeek";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FullWeekTimetable()));
    debugPrint("Full Week Time Table tapped");
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _onAttendanceTap() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => New_Attendance_Performance()));
    debugPrint("Attendance Performance tapped");
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔶 Orange Info Banner
          Container(
            width: double.infinity,
            color: const Color(0xFFFFB300),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.calendar_today, size: 40, color: Colors.black),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "To view your today's, tomorrow's, full-week time table click below options",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 📅 TODAY
          _timeTableTile(
            day: todayDay,
            title: "Today Time Table",
            date: todayDate,
            onTap: _onTodayTap,
          ),

          // 📅 TOMORROW
          _timeTableTile(
            day: tomorrowDay,
            title: "Tomorrow Time Table",
            date: tomorrowDate,
            onTap: _onTomorrowTap,
          ),

          // 📆 FULL WEEK
          _simpleTile(
            icon: Icons.calendar_month,
            title: "Full Week Time Table",
            onTap: _onFullWeekTap,
          ),

          // 📊 ATTENDANCE
          _simpleTile(
            icon: Icons.bar_chart,
            title: "Attendence Performance",
            onTap: _onAttendanceTap,
          ),
        ],
      ),
    );
  }

  // ================= UI WIDGETS =================

  Widget _timeTableTile({
    required String day,
    required String title,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            _calendarIcon(day),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(date),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _simpleTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48),
            const SizedBox(width: 14),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _calendarIcon(String day) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            height: 12,
            color: Colors.black,
          ),
          Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }
}
