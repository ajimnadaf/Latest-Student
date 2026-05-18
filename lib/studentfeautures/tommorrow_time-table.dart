import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

List ak = [];
bool isLoading = false;
SocketService socketService = SocketService();

class TommorrowTimePage extends StatefulWidget {
  const TommorrowTimePage({super.key});

  @override
  State<TommorrowTimePage> createState() => _TommorrowTimePage();
}

class _TommorrowTimePage extends State<TommorrowTimePage> {
  @override
  void initState() {
    super.initState();
    Glb.sysDate = Glb.tdy_date;
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
      List<Data_Tomorrow_TT> data = fill_with_data();
    }

    return "SUCCESS";
  }

  List<Data_Tomorrow_TT> fill_with_data() {
    DateTime? stime;
    DateTime? etime;

    final DateFormat displayFormat = DateFormat("hh:mm a");
    final DateFormat parseFormat = DateFormat("HH:mm:ss");

    List<Data_Tomorrow_TT> data = [];

    for (int i = 0;
        Glb.View_tomTimeTblId != null && i < Glb.View_tomTimeTblId.length;
        i++) {
      String class_stat = Glb.View_tomTimeTblStatus[i].toString();

      if (class_stat == "1") {
        class_stat = "";
      }
      if (class_stat == "0") {
        class_stat = " (E)";
      }

      try {
        stime = parseFormat.parse(Glb.View_tomTimeTblStartTime[i].toString());
      } catch (e) {
        stime = null;
      }

      try {
        etime = parseFormat.parse(Glb.View_tomTimeTblEndTime[i].toString());
      } catch (e) {
        etime = null;
      }

      data.add(
        Data_Tomorrow_TT(
          Glb.sub_name[i].toString() + class_stat,
          stime != null ? displayFormat.format(stime) : "",
          etime != null ? displayFormat.format(etime) : "",
          Glb.View_tomTT_Username[i].toString(),
        ),
      );
    }

    return data;
  }

  Future<String> loaddata() async {
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
      "select timetblid,ttimetbl.teacherid,stime,etime,ttimetbl.subid,ttimetbl.status,tteachertbl.usrid,usrname,psubtbl.subname,psubtbl.subtype from trueguide.ttimetbl,trueguide.tteachertbl,trueguide.psubtbl,trueguide.tusertbl where ttimetbl.instid='" +
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
      Glb.View_tomTimeTblId = data['X^1_1'] ?? [];
      Glb.View_tomTimeTblTeacherId = data['X^2_2'] ?? [];
      Glb.View_tomTimeTblStartTime = data['X^3_3'] ?? [];
      Glb.View_tomTimeTblEndTime = data['X^4_4'] ?? [];
      Glb.View_tomTimeTblSubids = data['X^5_5'] ?? [];
      Glb.View_tomTimeTblStatus = data['X^6_6'] ?? [];
      Glb.View_tomTT_userid = data['X^7_7'] ?? [];
      Glb.sub_name = data['X^8_8'] ?? [];
      Glb.View_tomTT_Username = data['X^9_9'] ?? [];
      Glb.subtype_lst = data['X^10_10'] ?? [];

      print("timetblid      : ${Glb.View_tomTimeTblId}");
      print("teacherID      : ${Glb.View_tomTimeTblTeacherId}");
      print("starttime      : ${Glb.View_tomTimeTblStartTime}");
      print("endtime        : ${Glb.View_tomTimeTblEndTime}");
      print("subid          : ${Glb.View_tomTimeTblSubids}");
      print("status         : ${Glb.View_tomTimeTblStatus}");
      print("userid         : ${Glb.View_tomTT_userid}");
      print("Username       : ${Glb.View_tomTT_Username}");
      print("sub_name       : ${Glb.sub_name}");
      print("subtype_lst    : ${Glb.subtype_lst}");
    }

    return "SUCCESS";
  }

  Future<void> _onViewMaterial() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("This Feauture Will Come soon. pls Cooprate. ")));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _onRefresh() async {
    await AsyncTaskloaddata();
    // await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tommorrows's Time Table"),
        elevation: 0,
      ),
      body: Stack(
        children: [
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
                  _calendarIcon("${Glb.tommorow}"),
                  const Spacer(),
                  InkWell(
                    onTap: _onRefresh,
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Click Here to Refresh Page",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          //Time Table List

          Positioned(
            top: 92,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: Glb.View_tomTimeTblId.length,
              itemBuilder: (context, index) {
                return _timeTableCard(
                  subject: "${Glb.sub_name[index].toString()}",
                  teacher: "${Glb.View_tomTT_Username[index].toString()}",
                  start: "${Glb.View_tomTimeTblStartTime[index].toString()}",
                  end: "${Glb.View_tomTimeTblEndTime[index].toString()}",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start: $start",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text("End : $end",
                      style: TextStyle(fontWeight: FontWeight.w600)),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _onViewMaterial,
            child: Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Color(0xFFFFE0B2)],
                  )),
              alignment: Alignment.center,
              child: const Text(
                "VIEW STUDT MATERIAL",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

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

class Data_Tomorrow_TT {
  String subject;
  String stime;
  String etime;
  String name;

  Data_Tomorrow_TT(String s, String s1, String s2, String s3)
      : subject = s,
        stime = s1,
        etime = s2,
        name = s3;
}
