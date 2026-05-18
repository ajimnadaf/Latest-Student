// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/Avg_marks.dart';
import 'package:student_app/LoginPage/Dashboard/MarksRep.dart';
import 'package:student_app/LoginPage/Dashboard/Dashboard.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/studentfeautures/GenerateFullMatrixPerfrm%20.dart';
import 'package:student_app/studentfeautures/GenrateFullMatricsPerf.dart';
import 'package:student_app/studentfeautures/HorizonatralChart.dart';
import 'package:student_app/studentfeautures/line_chart_page.dart';

SocketService socketService = SocketService();
List data = [];
String subject_name = "";
String cnts = "";

class Subject {
  final String name;
  final IconData icon;
  final Color color;
  final Color headerColor;

  const Subject(this.name, this.icon, this.color, this.headerColor);
}

class OfflineExamScreen extends StatefulWidget {
  const OfflineExamScreen({super.key});

  @override
  State<OfflineExamScreen> createState() => _OfflineExamScreenState();
}

class _OfflineExamScreenState extends State<OfflineExamScreen> {
  @override
  void initState() {
    super.initState();
    getvalues();
    loaddates();
    AsyncTaskloaddata();
  }

  DateTime? stime;
  DateTime? etime;

  Subject _mapSubjectFromName(String name) {
    for (final s in availableSubjects) {
      if (s.name.toUpperCase() == name.toUpperCase()) {
        return s;
      }
    }

    print("⚠️ Unknown subject from server: $name");
    return availableSubjects.first;
  }

  List<Data_Exam_TT> data = [];

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

  final List<Subject> availableSubjects = const [
    Subject("ENGLISH", Icons.menu_book_rounded, Color(0xFF1976D2),
        Color(0xFF42A5F5)),
    Subject("MATHEMATICS", Icons.calculate_rounded, Color(0xFFD32F2F),
        Color(0xFFFF7043)),
    Subject(
        "SCIENCE", Icons.science_rounded, Color(0xFF2E7D32), Color(0xFF66BB6A)),
    Subject(
        "HISTORY", Icons.museum_rounded, Color(0xFF6A1B9A), Color(0xFFAB47BC)),
    Subject("GEOGRAPHY", Icons.public_rounded, Color(0xFF0288D1),
        Color(0xFF26C6DA)),
    Subject("COMPUTER SCIENCE", Icons.computer_rounded, Color(0xFF512DA8),
        Color(0xFF7E57C2)),
  ];

  void getvalues() {
    Glb.upcmng_perf_SubId_cur = Glb.syl_coverage_subid_cur = Glb.sub_id_cur =
        Glb.SubMap![Glb.student_id]!.psubid_lst[Glb.sub_ind].toString();

    Glb.sub_name_cur =
        Glb.SubMap![Glb.student_id]!.psubname_lst[Glb.sub_ind].toString();

    Glb.subtypelst_cur =
        Glb.SubMap![Glb.student_id]!.psubtype_lst[Glb.sub_ind].toString();

    Glb.ex_sub_name_cur = Glb.sub_name_cur;

    print("upcmng_perf_SubId_cur: ${Glb.upcmng_perf_SubId_cur}");
    print("sub_name_cur : ${Glb.sub_name_cur}");
    print("subtypelst_cur: ${Glb.subtypelst_cur}");
    print("ex_sub_name_cur: ${Glb.ex_sub_name_cur}");
  }

  Future<void> AsyncTaskloaddata() async {
    String c = await loaddata();

    if (c.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No Internet Pls Check Your Connection")));
    }
    if (c.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO DATA")));
    }

    if (c.toUpperCase() == "SUCCESS") {
      subject_name = Glb.sub_name_cur;

      List<Data_Exam_TT> data = fill_with_data();
    }
  }

  List<Data_Exam_TT> fill_with_data() {
    final displayFormat = DateFormat('hh:mm a');
    for (int i = 0; i < Glb.upcmng_perf_ExmId.length; i++) {
      Glb.upcoming_exid_cur = Glb.upcmng_perf_ExmId[i].toString();

      DateTime? stime;
      DateTime? etime;

      try {
        stime = DateFormat("HH:mm:ss")
            .parse(Glb.upcmng_perf_startime[i].toString());
      } catch (e) {
        print(e);
      }

      try {
        etime =
            DateFormat("HH:mm:ss").parse(Glb.upcmng_perf_endtime[i].toString());
      } catch (e) {
        print(e);
      }

      data.add(
        Data_Exam_TT(
          Glb.upcmng_perf_Exmname[i].toString(),
          Glb.upcmng_perf_ExmDate[i].toString(),
          displayFormat.format(stime!),
          displayFormat.format(etime!),
          Glb.upcmng_Invigi_name[i].toString(),
        ),
      );

      print("DATA: $data");
    }

    return data;
  }

  void loaddates() {
    DateTime date = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    Glb.date = formatter.format(date);
  }

  Future<String> loaddata() async {
    String query = "";
    String responce = "";

    if (Glb.subtypelst_cur.toUpperCase() == "0") {
      query =
          "select examid,examname,exdate,stime,etime,subid,invgname from trueguide.texamtbl  where instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and exdate>='" +
              Glb.date +
              "' and secdesc='" +
              Glb.sec_id +
              "' and subid='" +
              Glb.sub_id_cur +
              "' and batchid='" +
              Glb.active_batchid +
              "' and online='-1'";
      print("QUery: $query");
    }
    if (Glb.subtypelst_cur.toUpperCase() == "1") {
      query =
          "select examid,examname,exdate,stime,etime,subid,invgname from trueguide.texamtbl  where instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and exdate>='" +
              Glb.date +
              "' and subdiv='" +
              Glb.division_cur +
              "' and subid='" +
              Glb.sub_id_cur +
              "' and batchid='" +
              Glb.active_batchid +
              "' and online='-1'";
      print("query: $query");
    }

    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      Glb.upcmng_perf_ExmId = data['X^1_1'] ?? [];
      Glb.upcmng_perf_Exmname = data['X^2_2'] ?? [];
      Glb.upcmng_perf_ExmDate = data['X^3_3'] ?? [];
      Glb.upcmng_perf_startime = data['X^4_4'] ?? [];
      Glb.upcmng_perf_endtime = data['X^5_5'] ?? [];
      Glb.upcmng_perf_SubId = data['X^6_6'] ?? [];
      Glb.upcmng_Invigi_name = data['X^7_7'] ?? [];

      print("upcmng_perf_ExmId : ${Glb.upcmng_perf_ExmId}");
      print("upcmng_perf_Exmname : ${Glb.upcmng_perf_Exmname}");
      print("upcmng_perf_ExmDate : ${Glb.upcmng_perf_ExmDate}");
      print("upcmng_perf_startime : ${Glb.upcmng_perf_startime}");
      print("upcmng_perf_endtime : ${Glb.upcmng_perf_endtime}");
      print("upcmng_perf_SubId : ${Glb.upcmng_perf_SubId}");
      print("upcmng_Invigi_name : ${Glb.upcmng_Invigi_name}");
    }
    return "SUCCESS";
  }

  Future<String> AsyncTasfullperfromancew() async {
    String query =
        "select count(*) from trueguide.tstudentmarksviewtbl where instid='" +
            Glb.inst_id +
            "'";
    print("Query : $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      cnts = data['X^1_1']![0];
      print("Count: $cnts");
    }

    if (cnts.toUpperCase() == "1") {
      return "NOTALLOWD";
    }

    query = "select distinct(examname) from trueguide.texamtbl where instid='" +
        Glb.inst_id +
        "' and classid='" +
        Glb.classid +
        "' and secdesc='" +
        Glb.sec_id +
        "' and status>='2' and batchid='" +
        Glb.active_batchid +
        "'";

    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      Glb.distinct_examname_lst = data['X^1_1'] ?? [];
      print("distinct_examname_lst: ${Glb.distinct_examname_lst}");
    }

    Glb.all_ex_sub_map.clear();
    Glb.all_ex_tot_map.clear();
    Glb.all_ex_obt_map.clear();

    for (int i = 0; i < Glb.distinct_examname_lst.length; i++) {
      Glb.examname = Glb.distinct_examname_lst[i].toString();
      query =
          "select subname,totmarks,marksobt from trueguide.tstudmarkstbl where examname='" +
              Glb.examname +
              "' and instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and secdesc='" +
              Glb.sec_id +
              "' and studid='" +
              Glb.student_id +
              "' and batchid='" +
              Glb.active_batchid +
              "'";

      print("Query : $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        Glb.subname_lst = data['X^1_1'] ?? [];
        Glb.marks_total_lst = data['X^2_2'] ?? [];
        Glb.marks_obtained_lst = data['X^3_3'] ?? [];
      }
    }

    if (Glb.subname_lst != null) {
      print("Came here");
      Glb.all_ex_sub_map.putIfAbsent(
        Glb.examname,
        () => Glb.subname_lst,
      );

      Glb.all_ex_tot_map.putIfAbsent(Glb.examname, () => Glb.marks_total_lst);

      Glb.all_ex_obt_map
          .putIfAbsent(Glb.examname, () => Glb.marks_obtained_lst);
    }

    print("all_ex_sub_map : ${Glb.all_ex_sub_map}");
    print("all_ex_tot_map: ${Glb.all_ex_tot_map}");
    print("all_ex_obt_map: ${Glb.all_ex_obt_map}");

    double total_marks_count = 0.0;
    double total_obt_marks = 0.0;

    if (Glb.marks_total_lst == null || Glb.marks_total_lst.isEmpty) {
      // return "NODATA";
    }

    for (int i = 0; i < Glb.marks_total_lst.length; i++) {
      double tm = double.parse(Glb.marks_total_lst[i].toString());
      double om = double.parse(Glb.marks_obtained_lst[i].toString());

      total_marks_count += tm;
      total_obt_marks += om;
    }

    Glb.tot_max_mark = total_marks_count.toString();
    Glb.tot_obt_mark = total_obt_marks.toString();

    print("tot_max_mark : ${Glb.tot_max_mark}");
    print("tot_obt_mark: ${Glb.tot_obt_mark}");

    return "SUCCESS";
  }

  void onpost() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Wait few seconds pls")));

    _showLoadingDialog(); // ⏳ show loader

    String response;
    try {
      response = await AsyncTasfullperfromancew();
    } finally {
      if (mounted) Navigator.of(context).pop(); // ✅ close loader ONLY
    }

    if (response.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Connection Lost from server pls Try Again")));
      return;
    } else if (response.toUpperCase() == "NOTALLOWD") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Sorry you are not allowed to view marks")));
      return;
    } else if (response.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("NO DATA FOUND")));
      return;
    } else if (response.toUpperCase() == "SUCCESS") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GenerateFullMatrixPerfrm()),
      );
    }
  }

  // --------------------- Subject Popup ---------------------
  void SelectSubjectPopUp(BuildContext context) {
    // ===== HARD NULL GUARD =====
    if (Glb.SubMap == null ||
        Glb.student_id == null ||
        !Glb.SubMap!.containsKey(Glb.student_id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subjects not loaded")),
      );
      return;
    }

    final subObj = Glb.SubMap![Glb.student_id];

    if (subObj == null || subObj.psubname_lst.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No subjects available")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subObj.psubname_lst.length + 1, // + ALL SUBJECTS
              itemBuilder: (context, position) {
                final isAll = position == subObj.psubname_lst.length;

                return InkWell(
                  onTap: () {
                    if (!isAll) {
                      Glb.sub_ind = position;
                      Glb.subwise_att = false;

                      Glb.upcmng_perf_SubId_cur = Glb.syl_coverage_subid_cur =
                          Glb.sub_id_cur =
                              subObj.psubid_lst[position].toString();

                      Glb.sub_name_cur =
                          subObj.psubname_lst[position].toString();

                      Glb.subtypelst_cur =
                          subObj.psubtype_lst[position].toString();

                      Glb.ex_sub_name_cur = Glb.sub_name_cur;
                    } else {
                      Glb.sub_ind = -1;
                      Glb.subwise_att = true;
                    }

                    make_setup();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Text(
                      isAll
                          ? "ALL SUBJECTS"
                          : subObj.psubname_lst[position].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void make_setup() {
    setState(() {
      if (Glb.attend_type == "0") {
        // NON CONSOLIDATED
        if (Glb.subwise_att == true) {
          Glb.subject_name = "All Subjects";
        } else {
          Glb.subject_name = Glb.sub_name_cur;
        }
      } else {
        // CONSOLIDATED
        if (Glb.subwise_att == true) {
          Glb.subject_name = "Consolidated Attendance - All Subjects";

          // onlinechk1 = true;
          // onlineEnabled = false;
          // offlineEnabled = false;
        } else {
          Glb.subject_name = "Consolidated Attendance";
        }
      }
    });
  }

// --------------------- Marks Options Popup ---------------------
  void _showMarksOptionsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SELECT SUBJECT TO GET MARKS",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              const SizedBox(height: 15),

              // --- 1️⃣ Subject-wise Chart ---
              GestureDetector(
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LineChartPage()));
                },
                child: Row(
                  children: [
                    Icon(Icons.menu_book,
                        color: Colors.blue.shade700, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${Glb.ex_sub_name_cur} Marks in all Exam",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- 2️⃣ Average Chart ---
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Horizonatralchart()));
                },
                child: Row(
                  children: [
                    Icon(Icons.stacked_bar_chart,
                        color: Colors.teal.shade700, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "AVG. % OF ALL SUBJECTS IN ALL EXAMS",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // ✅ correct
          },
        ),
        title: const Text(
          'OFFLINE EXAM',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black),
            onPressed: () async {
              onpost();
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart, color: Colors.black),
            onPressed: _showMarksOptionsPopup,
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: Column(
        children: [
          // -------- SUBJECT BAR --------
          GestureDetector(
            onTap: () async {
              SelectSubjectPopUp(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              color: const Color(0xFFFFB300), // exact yellow
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book,
                    color: Colors.blue,
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Glb.ex_sub_name_cur,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Click here to change subject",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // -------- BIG EMPTY BOX --------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: data.isEmpty
                    ? const Center(child: Text("No exams available"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];

                          return _timeTableCard(
                            subject: item.exname, // exam name
                            teacher: item.invigilator, // invigilator
                            start: item.stime, // start time
                            end: item.etime, // end time
                          );
                        },
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),
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

  Future<void> _onViewMaterial() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("This Feauture Will Come soon. pls Cooprate. ")));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ❌ user cannot dismiss
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class Data_Exam_TT {
  late String exname;
  late String stime;
  late String etime;
  late String date;
  late String faculty;
  late String invigilator;

  Data_Exam_TT(String s1, String s2, String s3, String s4, String s5) {
    exname = s1;
    date = s2;
    stime = s3;
    etime = s4;
    invigilator = s5;
  }
}
