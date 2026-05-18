import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

SocketService socketService = SocketService();

bool isLoading = false;

class TodayTimeTablePage extends StatefulWidget {
  const TodayTimeTablePage({super.key});

  @override
  State<TodayTimeTablePage> createState() => _TodayTimeTablePageState();
}

class _TodayTimeTablePageState extends State<TodayTimeTablePage> {
  void initState() {
    super.initState();
    Glb.sysDate = Glb.tdy_date;
    AsyncTaskloaddata();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await AsyncTaskloaddata();
    setState(() {
      isLoading = false;
    });

    if (isLoading) Glb.showLoadingIndicator(context);
    // await Future.delayed(const Duration(milliseconds: 300));
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

  Future<void> _onViewMaterial() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("This Feauture Will Come soon. pls Cooprate. ")));
    await Future.delayed(const Duration(milliseconds: 300));
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
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO DATA FOUND")));
    }
    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      List<Data_Today_TT> data = fill_with_data();
    }

    return "SUCCESS";
  }

  List<Data_Today_TT> fill_with_data() {
    setState(() {
      isLoading = true;
    });
    DateTime? stime;
    DateTime? etime;

    final DateFormat displayFormat = DateFormat('hh:mm a');
    List<Data_Today_TT> data = [];
    for (int i = 0;
        Glb.View_todayTT_timetblid != null &&
            i < Glb.View_todayTT_timetblid.length;
        i++) {
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
        setState(() {
          isLoading = false;
        });
        print(e);
      }

      try {
        etime = DateFormat("HH:mm:ss")
            .parse(Glb.View_todayTT_endtime[i].toString());
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
      }

      data.add(
        Data_Today_TT(
          Glb.sub_name[i].toString() + class_stat,
          displayFormat.format(stime!),
          displayFormat.format(etime!),
          Glb.View_todayTT_Username[i].toString(),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });

    return data;
  }

  Future<String> loaddata() async {
    Glb.View_todayTT_timetblid = [];
    Glb.View_todayTT_teacherID = [];
    Glb.View_todayTT_starttime = [];
    Glb.View_todayTT_endtime = [];
    Glb.View_todayTT_subid = [];
    Glb.View_todayTT_status = [];
    Glb.View_todayTT_userid = [];
    Glb.View_todayTT_Username = [];
    Glb.sub_name = [];
    String query = "";

    if (Glb.division_cur.toUpperCase() == "NA" ||
        Glb.division_cur == "None" ||
        Glb.division_cur.isEmpty) {
      query = "select timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,psubtbl.subtype from trueguide.ttimetbl,trueguide.tteachertbl,trueguide.psubtbl,trueguide.tusertbl where ttimetbl.instid='" +
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
          "' group by timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,psubtbl.subtype,ttimetbl.batchid order by stime,etime";
    } else {
      query = "select timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,psubtbl.subtype from trueguide.ttimetbl,trueguide.tteachertbl,trueguide.psubtbl,trueguide.tusertbl where ttimetbl.instid='" +
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
          "' group by timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,psubtbl.subtype,ttimetbl.batchid order by stime,etime";
    }

    print("Query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    print("Responce: $responce");
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
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
      Glb.View_todayTT_Username = data['X^8_8'] ?? [];
      Glb.sub_name = data['X^9_9'] ?? [];
      Glb.subtype_lst = data['X^10_10'] ?? [];

      print("timetblid      : ${Glb.View_todayTT_timetblid}");
      print("teacherID      : ${Glb.View_todayTT_teacherID}");
      print("starttime      : ${Glb.View_todayTT_starttime}");
      print("endtime        : ${Glb.View_todayTT_endtime}");
      print("subid          : ${Glb.View_todayTT_subid}");
      print("status         : ${Glb.View_todayTT_status}");
      print("userid         : ${Glb.View_todayTT_userid}");
      print("Username       : ${Glb.View_todayTT_Username}");
      print("sub_name       : ${Glb.sub_name}");
      print("subtype_lst    : ${Glb.subtype_lst}");

      Glb.conf_ttid_lst = [];
      Glb.conf_link_lst = [];
      Glb.embedinapp_lst = [];
    }
    if (Glb.division_cur.toUpperCase() == "NA" ||
        Glb.division_cur == "None" ||
        Glb.division_cur.isEmpty) {
      query =
          "select timetblid,link,embedinapp from trueguide.tliveconflinktbl where instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and secdesc='" +
              Glb.sec_id +
              "' and sbdate='" +
              Glb.sysDate +
              "' and livetime!='-1'";
    } else {
      query =
          "select timetblid,link,embedinapp from trueguide.tliveconflinktbl where instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and (secdesc='" +
              Glb.sec_id +
              "' or div='" +
              Glb.division_cur +
              "') and sbdate='" +
              Glb.sysDate +
              "' and livetime!='-1'";
    }
    print("Query: $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    print("Responce: $responce");
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
     // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      Glb.conf_ttid_lst = data['X^1_1'] ?? [];
      Glb.conf_link_lst = data['X^2_2'] ?? [];
      Glb.embedinapp_lst = data['X^3_3'] ?? [];

      print('conf_ttid_lst = ${Glb.conf_ttid_lst}');
      print('conf_link_lst = ${Glb.conf_link_lst}');
      print('embedinapp_lst = ${Glb.embedinapp_lst}');
    }

    return "SUCCESS";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Timetable"),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔶 ORANGE HEADER at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              color: const Color(0xFFFFB300),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _calendarIcon("${Glb.todayDay}"),
                  const Spacer(),
                  InkWell(
                    onTap: _onRefresh,
                    child: Row(
                      children: const [
                        Icon(Icons.refresh, color: Colors.white, size: 32),
                        SizedBox(width: 8),
                        Text(
                          "Click Here to Refresh Page",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📘 TIMETABLE LIST
          Positioned(
            top: 92, // 80 height + 12 spacing
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: Glb.View_todayTT_timetblid.length,
              itemBuilder: (context, index) {
                return _timeTableCard(
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

  // ====================== CARD ======================

  Widget _timeTableCard({
    required String subject,
    required String teacher,
    required String start,
    required String end,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, size: 28),
              const SizedBox(width: 8),
              Text(
                subject,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start :   $start",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text("End   :   $end",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              )
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              Text(
                teacher,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔘 BUTTON
          InkWell(
            onTap: _onViewMaterial,
            child: Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Color(0xFFFFE0B2)],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "VIEW STUDY MATERIAL",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ====================== CALENDAR ICON ======================

  Widget _calendarIcon(String day) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(height: 10, color: Colors.black),
          Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Data_Today_TT {
  String subject;
  String stime;
  String etime;
  String name;

  Data_Today_TT(String s, String s1, String s2, String s3)
      : subject = s,
        stime = s1,
        etime = s2,
        name = s3;
}
