import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

SocketService socketService = SocketService();
bool isLoading = false;
String Day = "";
String item = "";

class DayTimetableUI extends StatefulWidget {
  final String days;
  final String item;

  const DayTimetableUI({
    Key? key,
    required this.days,
    required this.item,
  }) : super(key: key);

  @override
  State<DayTimetableUI> createState() => _DayTimetableUIState();
}

class _DayTimetableUIState extends State<DayTimetableUI> {
  List<Data_View_Full_TT> data = [];
  @override
  void initState() {
    super.initState();
    Day = widget.days;
    data.clear();
    item = widget.item;
    Glb.day = Day;
    Glb.sysDate = item;
    print("Day: $Day");
    AsyncTaskloaddata();
  }

  Map<String, List<String>> processRecords(String input) {
    List<String> records =
        input.split('record#').where((record) => record.isNotEmpty).toList();

    Map<String, List<String>> resultMap = {};

    for (var record in records) {
      List<String> items = record.split('&');
      for (var item in items) {
        List<String> parts = item.split('#');
        if (parts.length == 2) {
          String key = parts[0];
          String value = parts[1];
          resultMap.putIfAbsent(key, () => []);
          resultMap[key]!.add(value);
        }
      }
    }
    return resultMap;
  }

  Future<String> loaddata() async {
    String query = "";

    if (Glb.division_cur.toUpperCase() == "NA" ||
        Glb.division_cur == "None" ||
        Glb.division_cur.isEmpty) {
      query = "select timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname from trueguide.ttimetbl,trueguide.tteachertbl,trueguide.psubtbl,trueguide.tusertbl where ttimetbl.instid='" +
          Glb.inst_id +
          "' and ttimetbl.classid='" +
          Glb.classid +
          "' and ttimetbl.secdesc='" +
          Glb.sec_id +
          "' and ((day='" +
          Glb.day +
          "' and ttimetbl.status='1') or (extrdate='" +
          Glb.sysDate +
          "' and day='" +
          Glb.day +
          "' and ttimetbl.status='0')) and ttimetbl.subid=psubtbl.subid and ttimetbl.teacherid=tteachertbl.teacherid and tteachertbl.usrid=tusertbl.usrid and ttimetbl.batchid='" +
          Glb.active_batchid +
          "' group by timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,ttimetbl.batchid order by stime,etime";
    } else {
      query = "select timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname from trueguide.ttimetbl,trueguide.tteachertbl,trueguide.psubtbl,trueguide.tusertbl where ttimetbl.instid='" +
          Glb.inst_id +
          "' and ttimetbl.classid='" +
          Glb.classid +
          "' and (ttimetbl.secdesc='" +
          Glb.sec_id +
          "' or ttimetbl.div='" +
          Glb.division_cur +
          "') and ((day='" +
          Glb.day +
          "' and ttimetbl.status='1') or (extrdate='" +
          Glb.sysDate +
          "' and day='" +
          Glb.day +
          "' and ttimetbl.status='0')) and ttimetbl.subid=psubtbl.subid and ttimetbl.teacherid=tteachertbl.teacherid and tteachertbl.usrid=tusertbl.usrid and ttimetbl.batchid='" +
          Glb.active_batchid +
          "' group by timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,ttimetbl.batchid order by stime,etime";
    }

    print("Query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    print("Responce: $responce");
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      data.clear();
      Glb.View_todayTT_timetblid.clear();
      Glb.sub_name.clear();
      Glb.View_todayTT_Username.clear();
      Glb.View_todayTT_starttime.clear();
      Glb.View_todayTT_endtime.clear();

      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      Glb.View_todayTT_timetblid = data['X^1_1'] ?? [];
      Glb.View_todayTT_teacherID = data['X^2_2'] ?? [];
      Glb.View_todayTT_starttime = data['X^3_3'] ?? [];
      Glb.View_todayTT_endtime = data['X^4_4'] ?? [];
      Glb.View_todayTT_subid = data['X^5_5'] ?? [];
      Glb.View_todayTT_status = data['X^6_6'] ?? [];
      Glb.View_todayTT_userid = data['X^7_7'] ?? [];
      Glb.sub_name = data['X^8_8'] ?? [];
      Glb.View_todayTT_Username = data['X^9_9'] ?? [];
      //  Glb.subtype_lst = data['X^10_10'] ?? [];

      print("timetblid      : ${Glb.View_todayTT_timetblid}");
      print("teacherID      : ${Glb.View_todayTT_teacherID}");
      print("starttime      : ${Glb.View_todayTT_starttime}");
      print("endtime        : ${Glb.View_todayTT_endtime}");
      print("subid          : ${Glb.View_todayTT_subid}");
      print("status         : ${Glb.View_todayTT_status}");
      print("userid         : ${Glb.View_todayTT_userid}");
      print("Username       : ${Glb.View_todayTT_Username}");
      print("sub_name       : ${Glb.sub_name}");
      // print("subtype_lst    : ${Glb.subtype_lst}");
    }

    return "SUCCESS";
  }

  Future<String> AsyncTaskloaddata() async {
    setState(() {
      isLoading = true;
    });
    String result = await loaddata();

    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Connection Lost Pls Check Your Connection And Try Again")));
    }
    if (result.toUpperCase() == "NODATA") {
      setState(() {
        isLoading = false;
        data.clear();
      });
      // data.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO DATA FOUND")));
    }
    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      List<Data_View_Full_TT> data = fill_with_data();
    }

    return "SUCCESS";
  }

  List<Data_View_Full_TT> fill_with_data() {
    DateTime? stime;
    DateTime? etime;
    DateFormat displayFormat = DateFormat("hh:mm a");

    List<Data_View_Full_TT> data = [];

    for (int i = 0; i < Glb.View_todayTT_timetblid.length; i++) {
      String class_stat = Glb.View_todayTT_status[i].toString();

      if (class_stat == "1") {
        class_stat = "";
      }
      if (class_stat == "0") {
        class_stat = " (E)";
      }

      try {
        stime = DateFormat("HH:mm:ss")
            .parse(Glb.View_todayTT_starttime[i].toString());
      } catch (e) {
        print(e);
        stime = DateTime.now(); // fallback if parsing fails
      }

      try {
        etime = DateFormat("HH:mm:ss")
            .parse(Glb.View_todayTT_endtime[i].toString());
      } catch (e) {
        print(e);
        etime = DateTime.now(); // fallback if parsing fails
      }

      data.add(Data_View_Full_TT(
        Glb.View_todayTT_Username[i].toString(),
        displayFormat.format(stime),
        displayFormat.format(etime),
        Glb.sub_name[i].toString() + class_stat,
      ));

      print("DATA is =====: $data");
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🟡 HEADER
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFFFB300),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 36,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Text(
                  "$Day",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ FIXED: Wrap ListView in Expanded
          Expanded(
            child: ListView.builder(
              itemCount: Glb.View_todayTT_timetblid.length,
              itemBuilder: (context, index) {
                return _subjectCard(
                  subject: Glb.sub_name[index],
                  teacher: Glb.View_todayTT_Username[index],
                  start: Glb.View_todayTT_starttime[index],
                  end: Glb.View_todayTT_endtime[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // SUBJECT CARD UI
  Widget _subjectCard({
    required String subject,
    required String teacher,
    required String start,
    required String end,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // LEFT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      teacher,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RIGHT CONTENT (TIME)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Start :  $start",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "End   :  $end",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Data_View_Full_TT {
  String subject;
  String stime;
  String etime;
  String name;

  Data_View_Full_TT(String s, String s1, String s2, String s3)
      : subject = s,
        stime = s1,
        etime = s2,
        name = s3;
}
