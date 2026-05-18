import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/Dashboard.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

class MyTodayNotifications extends StatefulWidget {
  const MyTodayNotifications({super.key});

  @override
  State<MyTodayNotifications> createState() => _MyTodayNotificationsState();
}

class _MyTodayNotificationsState extends State<MyTodayNotifications> {
  final SocketService socketService = SocketService();

  String serverResponse = '';
  late String currentDate;
  late String currentDay;
  String stDate = "", endDate = "";
  bool isLoading = false;
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
    _updateDateAndDayLocal();
    stDate = getMonthStart();
    endDate = getMonthEnd();
    _logGlbValues();
    _initData();
  }

  void _logGlbValues() {
    debugPrint("Glb.inst_id: ${Glb.inst_id}");
    debugPrint("Glb.notification_date: ${Glb.notification_date}");
    debugPrint("Glb.userid: ${Glb.userid}");
    debugPrint("Glb.classid: ${Glb.classid}");
    debugPrint("Glb.sec_id: ${Glb.sec_id}");
  }

  Future<void> _initData() async {
    await Async_get_distinct_dates();
    await _loadNotificationsForDate(Glb.notification_date);
  }

  String getMonthStart() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return DateFormat('yyyy-MM-dd').format(start);
  }

  String getMonthEnd() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month + 1, 0);
    return DateFormat('yyyy-MM-dd').format(end);
  }

  void _updateDateAndDayLocal() {
    DateTime now = DateTime.now();
    currentDate = DateFormat('yyyy-MM-dd').format(now);
    currentDay = DateFormat('EEEE').format(now);
    Glb.notification_date = currentDate;
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

  Future<String> AsyncTasksendnotification() async {
    String query =
        "select nid,ntype,info,nfrom,type,nfromname,nfromuid from trueguide.tacademicnotificationtbl where instid='" +
            Glb.inst_id +
            "' and ndate='" +
            Glb.notification_date +
            "' and ((ntorole='allinststud' and ntouid='-1') or (ntorole='student' and ntouid='" +
            Glb.userid +
            "') or(ntorole='allstudent' and ntouid='-1' and classid='" +
            Glb.classid +
            "' and secdesc='" +
            Glb.sec_id +
            "')) order by epoch";

    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    serverResponse = response;
    if (serverResponse == "101" ||
        serverResponse == "2" ||
        serverResponse.toLowerCase().contains("errorcode")) {
      return serverResponse;
    }

    Map<String, List<String>> processed = processRecords(serverResponse);
    Glb.nid_lst = processed['X^1_1'] ?? [];
    Glb.ntype_lst = processed['X^2_2'] ?? [];
    Glb.info_lst = processed['X^3_3'] ?? [];
    Glb.nfrom_lst = processed['X^4_4'] ?? [];
    Glb.noti_type_lst = processed['X^5_5'] ?? [];
    Glb.nfrome_name_lst = processed['X^6_6'] ?? [];
    Glb.nfrom_uid_lst = processed['X^7_7'] ?? [];

    // fetch doc counts
    String query1 = "select tacademicnotificationtbl.nid,count(notidoctbl.nid) from trueguide.tacademicnotificationtbl,trueguide.notidoctbl where  tacademicnotificationtbl.instid='" +
        Glb.inst_id +
        "' and tacademicnotificationtbl.ndate='" +
        Glb.notification_date +
        "' and ((tacademicnotificationtbl.ntorole='allinststud' and tacademicnotificationtbl.ntouid='-1') or (tacademicnotificationtbl.ntorole='student' and tacademicnotificationtbl.ntouid='" +
        Glb.userid +
        "') or(tacademicnotificationtbl.ntorole='allstudent' and tacademicnotificationtbl.ntouid='-1' and tacademicnotificationtbl.classid='" +
        Glb.classid +
        "' and tacademicnotificationtbl.secdesc='" +
        Glb.sec_id +
        "')) and  tacademicnotificationtbl.nid=notidoctbl.nid group by tacademicnotificationtbl.nid";

    String response1 =
        await socketService.sendMessage(Glb.ip, Glb.port, query1, 709);

    serverResponse = response1;
    if (serverResponse == "101" ||
        serverResponse == "2" ||
        serverResponse.toLowerCase().contains("errorcode")) {
      Glb.noti_nid_lst = [];
      Glb.noti_count_lst = [];
      return "SUCCESS";
    }

    Map<String, List<String>> processed2 = processRecords(serverResponse);
    Glb.noti_nid_lst = processed2['X^1_1'] ?? [];
    Glb.noti_count_lst = processed2['X^2_2'] ?? [];

    return "SUCCESS";
  }

  Future<String> Async_get_distinct_dates() async {
    String query =
        "select distinct(ndate) from trueguide.tacademicnotificationtbl where instid='" +
            Glb.inst_id +
            "' and ((ntorole='allinststud' and ntouid='-1') or (ntorole='student' and ntouid='" +
            Glb.userid +
            "') or (ntorole='allstudent' and ntouid='-1' and classid='" +
            Glb.classid +
            "' and secdesc='" +
            Glb.sec_id +
            "')) and (ndate>='" +
            stDate +
            "' and ndate<='" +
            endDate +
            "') order by ndate DESC";

    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    serverResponse = response;
    if (serverResponse == "101" ||
        serverResponse == "2" ||
        serverResponse.toLowerCase().contains("errorcode")) {
      Glb.distinct_date_noti = [];
      return "NODATA";
    }

    Map<String, List<String>> proccessedData = processRecords(serverResponse);
    Glb.distinct_date_noti = proccessedData['X^1_1'] ?? [];
    return "SUCCESS";
  }

  void _convertApiToNotifications() {
    notifications.clear();

    for (int i = 0; i < Glb.nid_lst.length; i++) {
      String nid = Glb.nid_lst[i].toString();
      String subject =
          (i < Glb.ntype_lst.length) ? Glb.ntype_lst[i].toString() : "";
      String info = (i < Glb.info_lst.length) ? Glb.info_lst[i].toString() : "";
      String from = (i < Glb.nfrome_name_lst.length)
          ? Glb.nfrome_name_lst[i].toString()
          : "";
      String typeOfNoti =
          (i < Glb.noti_type_lst.length) ? Glb.noti_type_lst[i].toString() : "";
      String docCount = "0";

      if (Glb.noti_nid_lst != null && Glb.noti_nid_lst.isNotEmpty) {
        int di = Glb.noti_nid_lst.indexOf(nid);
        if (di != -1 && di < Glb.noti_count_lst.length) {
          docCount = Glb.noti_count_lst[di].toString();
        }
      }

      String typeLabel = typeOfNoti == "1"
          ? "CIRCULAR"
          : (typeOfNoti == "2" ? "OTHER (Replyable)" : "GENERAL");

      subject =
          subject.replaceAll("--apos--", "'").replaceAll("recrd", "record");
      info = info.replaceAll("--apos--", "'").replaceAll("recrd", "record");

      String desc = info;
      if (docCount != "0") desc = "$desc\n\nCLICK TO VIEW DOCS ($docCount)";

      notifications.add({
        "nid": nid,
        "title": subject,
        "message": desc,
        "from": from,
        "type": typeLabel,
        "date": Glb.notification_date ?? currentDate,
        "docCount": docCount,
      });
    }
  }

  Future<void> _loadNotificationsForDate(String dateToLoad) async {
    setState(() {
      isLoading = true;
      notifications = [];
    });

    Glb.notification_date = dateToLoad;
    String resp = await AsyncTasksendnotification();

    if (resp == "101") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Check your Internet connection")));
      setState(() => isLoading = false);
      return;
    }
    if (resp == "2" || resp.toLowerCase().contains("errorcode")) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No notifications found for selected date")));
      setState(() {
        isLoading = false;
        notifications = [];
      });
      return;
    }

    _convertApiToNotifications();
    setState(() => isLoading = false);
  }

  void _goToHomePage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const StudentDashboard1()));
  }

  void _openPdf(String pdfFileName) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Open PDF: $pdfFileName")));
  }

  void _showMonthNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white70,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Glb.distinct_date_noti.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(22.0),
                    child: Text(
                      "No dates available for this month",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: Glb.distinct_date_noti.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: ListTile(
                          title: Text(
                            Glb.distinct_date_noti[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 16),
                          onTap: () {
                            Glb.notification_date =
                                Glb.distinct_date_noti[index];
                            Navigator.pop(context);
                            _loadNotificationsForDate(Glb.notification_date);
                          },
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  // ---------------------------
  // Build UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 2,
        title: const Text(
          "Notifications",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              onPressed: _goToHomePage),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showMonthNotifications(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${Glb.notification_date ?? currentDate} (${currentDay})",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          const Text("Tap to view monthly notifications",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(8),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? const Center(
                            child: Text("No notifications today",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          )
                        : ListView.builder(
                            itemCount: notifications.length,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (context, index) {
                              final n = notifications[index];
                              final type = n["type"] ?? "GENERAL";

                              final gradientColors = (type == "CIRCULAR")
                                  ? [
                                      const Color(0xFF6A1B9A),
                                      const Color(0xFFAB47BC)
                                    ]
                                  : (type.contains("Replyable"))
                                      ? [
                                          const Color(0xFF0277BD),
                                          const Color(0xFF26C6DA)
                                        ]
                                      : [
                                          const Color(0xFF3949AB),
                                          const Color(0xFF5C6BC0)
                                        ];

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6))
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(14),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.notifications,
                                        color: Colors.white, size: 26),
                                  ),
                                  title: Text(n["title"] ?? "",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      n["message"] ?? "",
                                      style: const TextStyle(
                                          color: Colors.white70, height: 1.35),
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(n["date"] ?? "",
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text(type,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11)),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if ((n["docCount"] ?? "0") != "0") {
                                      _openPdf("docs for nid ${n["nid"]}");
                                    } else {
                                      // Custom purple gradient detail dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF6A1B9A),
                                                    Color(0xFFAB47BC)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      n["title"] ?? "",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      n["message"] ?? "",
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      "From: ${n["from"] ?? "-"}",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white70),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      "Date: ${n["date"] ?? "-"}",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white70),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
