import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/GlobalClasses/Url.dart';
import 'package:student_app/LoginPage/Dashboard/AcademicDetails.dart';
import 'package:student_app/LoginPage/Dashboard/AskMeAnything.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:student_app/LoginPage/Dashboard/Assisment.dart';
import 'package:student_app/LoginPage/Dashboard/Document.dart';
import 'package:student_app/LoginPage/Dashboard/Drawer.dart';
import 'package:student_app/LoginPage/Dashboard/Examination.dart';
import 'package:student_app/LoginPage/Dashboard/FeeDetails.dart';
import 'package:student_app/LoginPage/Dashboard/HomeScreen.dart';
import 'package:student_app/LoginPage/Dashboard/MySyllabus.dart';
import 'package:student_app/LoginPage/Dashboard/Notification.dart';
import 'package:student_app/LoginPage/Dashboard/OnlineExam.dart';
import 'package:student_app/LoginPage/Dashboard/SyllabusCover.dart';
import 'package:student_app/LoginPage/Dashboard/TimeTable.dart';
import 'package:student_app/LoginPage/Dashboard/social_skill.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/LoginPage/login.dart';
import 'package:student_app/Services/SharedPreKey.dart';
import 'package:student_app/Services/shared_preffrences.dart';
import 'package:student_app/studentfeautures/Home_work.dart';
import 'package:student_app/studentfeautures/MySyllabus.dart';

SubjectObj? SubObj;

String Positions = "";
String selectedInstitute = "";
int i = 0;
bool clearance_intent = false;

class SubjectObj {
  List<String> psubid_lst = [];
  List<String> psubname_lst = [];
  List<String> psubtype_lst = [];

  SubjectObj(
      {this.psubid_lst = const [],
      this.psubname_lst = const [],
      this.psubtype_lst = const []});
}

List topic_lst = [];
List schtype_lst = [];
List sch_year_lst = [];
List sch_classname_lst = [];
List appdate_lst = [];
List sancdate_lst = [];
List sancamount_lst = [];
List dispamount_lst = [];
List sub_lst = [];
List subid_lst = [];
List jsubid_lst = [];
List j_usrname_lst = [];
List class_taken_subid_lst = [];
List tot_class_take_count_lst = [];
List attendence_subid_lst = [];
List attendece_count_lst = [];
List subjec_rem_subid = [];
List subject_remark = [];
List bookname_lst = [];
List author_lst = [];
List issuedate_lst = [];
List duedate_lst = [];
List fine_lst = [];
List rcid_lst = [];
List remarkcat_lst = [];
List rem_rcid_lst = [];
List rem_remark_lst = [];
List rem_dt_lst = [];
List remamount_lst = [];
List sancstatus_lst = [];
List dispersestatus_lst = [];

String notification_date = "";
String logo_url = "";
String cidCur = "";

bool isLoading = false;
bool notifi_stat = false;

int studid = 0, status = 0;

SocketService socketService = SocketService();
SharedPreferenceService pref = SharedPreferenceService();

class StudentDashboard1 extends StatefulWidget {
  const StudentDashboard1({super.key});

  @override
  State<StudentDashboard1> createState() => _StudentDashboard1State();
}

class _StudentDashboard1State extends State<StudentDashboard1> {
  int _notificationCount = 0;
  Timer? _timer;

  static String filepath = "";
  static String htmlPath = "";

  // 🎨 COLORS
  final Color lightGold = const Color(0xFFFFE082);
  final Color goldText = const Color(0xFF6D4C41);

  @override
  void initState() {
    super.initState();
    getvalues();
    SelectInstitutePopUp(i);
    _updateNotificationCount();
    handleCurrentEpoch();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateNotificationCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateNotificationCount() {
    setState(() {
      _notificationCount = Glb.nid_lst.length;
    });
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

  static Future<void> subscribeTopic(String topic) async {
    try {
      debugPrint("Subscribing to: $topic");
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint("$topic Subscription Success");
    } catch (e) {
      debugPrint("$topic Subscription Failed: $e");
    }
  }

  Future<void> handleCurrentEpoch() async {
    final DateTime now = DateTime.now();

    final int epochMillis = now.millisecondsSinceEpoch;
    final int epochSeconds = epochMillis ~/ 1000;

    final DateTime convertedDate =
        DateTime.fromMillisecondsSinceEpoch(epochMillis);

    debugPrint("Epoch (ms): $epochMillis");
    debugPrint("Epoch (sec): $epochSeconds");
    debugPrint("Converted DateTime: $convertedDate");

    Glb.server_epoch = epochSeconds.toString();
  }

  Future<String> get_next_ads_id(
    String inst_adtp_cur,
  ) async {
    String id = "";
    String ad_idx = "";
    String unit_sp = "";

    if (inst_adtp_cur == "1") {
      ad_idx = "FB_IDX";
      unit_sp = "FB_UNITS";
    } else if (inst_adtp_cur == "2") {
      ad_idx = "G_IDX";
      unit_sp = "G_UNITS";
    }

    final prefs = await SharedPreferences.getInstance();

    String? idx = prefs.getString(ad_idx);
    String? ids = prefs.getString(unit_sp);

    int index = 0;
    if (idx == null || idx.isEmpty) {
      index = 0;
    } else {
      index = int.tryParse(idx) ?? 0;
    }

    if (ids == null || ids.isEmpty) {
      return "0";
    }

    List<String> lst = ids.split(",");

    if (index >= lst.length) {
      index = 0;
    }

    id = lst[index];
    index++;

    await prefs.setString(ad_idx, index.toString());

    return id;
  }

  void getvalues() {
    setState(() {
      isLoading = true;
    });
    FirebaseCrashlytics.instance;
    Glb.userid = Glb.main_stud_usrid_lst[Glb.usr_ind].toString();
    Glb.student_name = Glb.main_stud_usrname_lst[Glb.usr_ind].toString();

    StudentLoginInfoObj? obj = studentLoginInfoMap["${Glb.userid}"];

    Glb.student_id = obj!.student_id_lst[Glb.prof_ind].toString();
    Glb.inst_id = obj.inst_id_lst[Glb.prof_ind].toString();
    Glb.Status = obj.Status_lst[Glb.prof_ind].toString();
    Glb.student_instname_cur = obj.instname_lst[Glb.prof_ind].toString();
    Glb.classid = obj.classid_lst[Glb.prof_ind].toString();
    Glb.sec_id = obj.sec_id_lst[Glb.prof_ind].toString();
    Glb.roll_no = obj.roll_no_lst[Glb.prof_ind].toString();
    Glb.division_cur = obj.subdiv_lst[Glb.prof_ind].toString();
    Glb.inst_expiry_cur = obj.inst_expiry_lst[Glb.prof_ind].toString();
    Glb.active_batchid = obj.batchid_lst[Glb.prof_ind].toString();
    Glb.ctype_cur = obj.ctype_lst[Glb.prof_ind].toString();
    Glb.attend_type = obj.atttype_lst[Glb.prof_ind].toString();
    Glb.batchid_cur = obj.year_lst[Glb.prof_ind].toString();
    Glb.inst_adtp_cur = obj.inst_adtp_lst[Glb.prof_ind].toString();
    Glb.up_info_flag = obj.update_info_lst[Glb.prof_ind].toString();
    Glb.custadvurl_cur = obj.custadvyrl_lst[Glb.prof_ind].toString();

    print("===== STUDENT PROFILE DATA =====");
    print("student_id : ${Glb.student_id}");
    print("inst_id : ${Glb.inst_id}");
    print("Status : ${Glb.Status}");
    print("Institute Name : ${Glb.student_instname_cur}");
    print("Class ID : ${Glb.classid}");
    print("Section ID : ${Glb.sec_id}");
    print("Roll No : ${Glb.roll_no}");
    print("Division : ${Glb.division_cur}");
    print("Expiry : ${Glb.inst_expiry_cur}");
    print("Active Batch : ${Glb.active_batchid}");
    print("Course Type : ${Glb.ctype_cur}");
    print("Attend Type : ${Glb.attend_type}");
    print("Batch Year : ${Glb.batchid_cur}");
    print("Ad Type : ${Glb.inst_adtp_cur}");
    print("Update Info Flag : ${Glb.up_info_flag}");
    print("Custom Adv URL : ${Glb.custadvurl_cur}");
    setState(() {
      isLoading = false;
    });
  }

  void SelectInstitutePopUp(int position) async {
    setState(() {
      isLoading = true;
    });
    StudentLoginInfoObj? obj = studentLoginInfoMap["${Glb.userid}"];

    if (obj == null) {
      print("Main Object is Null :");
      return;
    }
    if (position < 0 || position >= obj.inst_id_lst.length) {
      print(
          "❌ Invalid index: $position (List length: ${obj.inst_id_lst.length})");
      return;
    }
    String fix(value) {
      if (value == null) return "NA";
      String s = value.toString().trim();
      return s.isEmpty ? "NA" : s;
    }

    Glb.prof_ind = position;

    Glb.student_id = obj!.student_id_lst[position].toString();
    Glb.inst_id = obj.inst_id_lst[position].toString();
    Glb.Status = obj.Status_lst[position].toString();
    Glb.student_instname_cur = obj.instname_lst[position].toString();
    Glb.classid = obj.classid_lst[position].toString();
    Glb.sec_id = obj.sec_id_lst[position].toString();
    Glb.roll_no = obj.roll_no_lst[position].toString();
    Glb.division_cur = obj.subdiv_lst[position].toString();
    Glb.inst_expiry_cur = obj.inst_expiry_lst[position].toString();
    Glb.active_batchid = obj.batchid_lst[position].toString();
    Glb.ctype_cur = obj.ctype_lst[position].toString();
    Glb.attend_type = obj.atttype_lst[position].toString();
    Glb.batchid_cur = obj.year_lst[position].toString();
    Glb.inst_adtp_cur = obj.inst_adtp_lst[position].toString();
    Glb.up_info_flag = obj.update_info_lst[position].toString();
    Glb.custadvurl_cur = obj.custadvyrl_lst[position].toString();

    print("===== STUDENT PROFILE DATA =====");
    print("student_id : ${Glb.student_id}");
    print("inst_id : ${Glb.inst_id}");
    print("Status : ${Glb.Status}");
    print("Institute Name : ${Glb.student_instname_cur}");
    print("Class ID : ${Glb.classid}");
    print("Section ID : ${Glb.sec_id}");
    print("Roll No : ${Glb.roll_no}");
    print("Division : ${Glb.division_cur}");
    print("Expiry : ${Glb.inst_expiry_cur}");
    print("Active Batch : ${Glb.active_batchid}");
    print("Course Type : ${Glb.ctype_cur}");
    print("Attend Type : ${Glb.attend_type}");
    print("Batch Year : ${Glb.batchid_cur}");
    print("Ad Type : ${Glb.inst_adtp_cur}");
    print("Update Info Flag : ${Glb.up_info_flag}");
    print("Custom Adv URL : ${Glb.custadvurl_cur}");

    print("Selected Position: $position");
    Positions = position.toString();
    print("Institute ID: ${Glb.inst_id}");
    print("Institute Name: ${Glb.student_instname_cur}");

    selectedInstitute = Glb.student_instname_cur;

    if (Glb.inst_status_cur == "0") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "This institution has been blocked! \n Contact administrator")));
    }

    if (Glb.epoch_taken) {
      topic_lst.clear();

      if ((Glb.sec_id.toUpperCase() == "NA") == false) {
        final String cleanSecId =
            Glb.sec_id.replaceAll('(', '').replaceAll(')', '');

        topic_lst.addAll([
          "STUD-NOTI-${Glb.inst_id}-${Glb.classid}-$cleanSecId-${Glb.active_batchid}",
          "STUD-NOTI-${Glb.inst_id}-${Glb.active_batchid}",
          "STUD-LVCLS-${Glb.inst_id}-${Glb.classid}-$cleanSecId-${Glb.active_batchid}",
          "STUD-ONLEXM-${Glb.inst_id}-${Glb.classid}-$cleanSecId-${Glb.active_batchid}",
          "STUD-HW-${Glb.inst_id}-${Glb.classid}-$cleanSecId-${Glb.active_batchid}",
          "STUD-SYLDOC-${Glb.inst_id}-${Glb.classid}-$cleanSecId-${Glb.active_batchid}",
        ]);

        print("Insider List : $topic_lst");
      }
      topic_lst.addAll([
        "STUD-FEE-${Glb.inst_id}-${Glb.classid}-${Glb.active_batchid}",
        "STUD-NOTI-${Glb.inst_id}", // active and inactive students
        "STUDENTS",
      ]);
      print("List : $topic_lst");

      onpostE();
    } else {
      print("Glb.fbmsgdevid=== ${Glb.fbmsgdevid}");
      print("Glb.devid==: ${Glb.devid}");

      if ((Glb.noti_remind_later) == false) {
        if ((Glb.fbmsgdevid == Glb.devid)) {
          if (Glb.is_subscribed == false) {
            for (int k = 0; k < topic_lst.length; k++) {
              await subscribeTopic(topic_lst[k].toString());
            }
            Glb.is_subscribed = true;
          }
        } else {
          notifi_stat = true;
        }
      }

      if (Glb.up_info_flag.toUpperCase() == "1") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Your institution wants you to complete your profile details.")));
        return;
      }

      if (Glb.dltype.isEmpty) {
        onpost();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String> Async_get_dltype() async {
    String query = "select type from trueguide.pinsttbl where instid='" +
        Glb.inst_id +
        "' ";
    print("query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      print("aboars");
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("Nodata");
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      Glb.dltype = data['X^1_1']![0];
      print("Globla D LIST: ${Glb.dltype}");
    }
    return "SUCCESS";
  }

  void onpost() async {
    print("Enterd in Onpost Execute");
    setState(() {
      isLoading = true;
    });
    String check = await Async_get_dltype();
    if (check.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO DATA")));
      return;
    }
    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pls Check your connection. And try Again")));
      return;
    }
    if (check.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      print("Navigating To Statstic Screen");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StudentDashboard()));
    }
  }

  void showInstituteSelector() {
    StudentLoginInfoObj? obj = studentLoginInfoMap["${Glb.userid}"];

    if (obj == null || obj.inst_id_lst.isEmpty) {
      print("Main Object is Null :");
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: obj.inst_id_lst.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.school),
              title: Text(obj.instname_lst[index].toString()),
              subtitle: Text("Institute ID: ${obj.inst_id_lst[index]}"),
              onTap: () {
                Navigator.pop(context);

                // Run the selector logic once
                SelectInstitutePopUp(index);

                // Update UI only
                setState(() {
                  selectedInstitute = obj.instname_lst.toString();
                });
              },
            );
          },
        );
      },
    );
  }

  Future<String> AsyncTaskPrePop() async {
    await handleCurrentEpoch();
    Glb.epoch_taken = true;
    bool nodata = false;
    String query =
        "select spname,logolink from trueguide.splashtbl where instid='" +
            Glb.inst_id +
            "' and status='1'";
    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (response.startsWith("Err:")) {
      print("Connection Problem");
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      print("No data");
      nodata = true;
      await pref.saveString(Sharedprekey.Studlogolnk, "");
      await pref.saveString(Sharedprekey.Studsplash, "");
      return "NODATA";
    }

    if (response.startsWith("record#")) {
      nodata == false;
      Map<String, List<String>> data = processRecords(response);
      String splash = data['X^1_1']![0];
      String logo = data['X^2_2']![0];

      print("SplashScreen($splash)    logo($logo)");
      if (splash != null &&
          (splash.isEmpty) == false &&
          (splash.toUpperCase() == "NA") == false &&
          UrlUtils.isValidUrl(splash) == true) {
        await pref.saveString(Sharedprekey.Studsplash, splash);
      }
      if (logo != null &&
          (logo.toUpperCase() == "NA") == false &&
          (logo.isEmpty) == false &&
          UrlUtils.isValidUrl(logo)) {
        await pref.saveString(Sharedprekey.Studlogolnk, logo);
      }
    }

    String timeStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    notification_date = timeStamp;

    String query1 =
        "select count(*) from trueguide.tacademicnotificationtbl where instid='" +
            Glb.inst_id +
            "' and ndate='" +
            notification_date +
            "' and ((ntorole='allinststud' and ntouid='-1') or (ntorole='student' and ntouid='" +
            Glb.userid +
            "') or(ntorole='allstudent' and ntouid='-1' and classid='" +
            Glb.classid +
            "' and secdesc='" +
            Glb.sec_id +
            "'))";

    print("query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      print("aboars");
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("Nodata");
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      Glb.today_noti_count = data['X^1_1']![0];
      print("Notification count: ${Glb.today_noti_count}");
      setState(() {
        Glb.today_noti_count;
      });
    }

    return "SUCCESS";
  }

  void onpostE() async {
    setState(() {
      isLoading = true;
    });
    print("Enterd in OnpostE Execute");
    String result = await AsyncTaskPrePop();

    if (result.toUpperCase() == "SUCCESS") {
      logo_url = await pref.getStringList(Sharedprekey.Studlogolnk).toString();

      if (logo_url != null &&
          (logo_url.isEmpty) == false &&
          (logo_url.toUpperCase() == "NA") == false &&
          (UrlUtils.isValidUrl(logo_url)) == true) {
        print("First URl : $logo_url");
      }
      print("Glb.fbmsgdevid=== ${Glb.fbmsgdevid}");
      print("Glb.devid==: ${Glb.devid}");

      if ((Glb.fbmsgdevid == Glb.devid)) {
        if (Glb.is_subscribed == false) {
          for (int k = 0; k < topic_lst.length; k++) {
            await subscribeTopic(topic_lst[k].toString());
          }
          Glb.is_subscribed = true;
        }
      } else {
        notifi_stat = true;
      }

      if (Glb.up_info_flag.toUpperCase() == "1") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Your institution wants you to complete your profile details.")));
        return;
      }
    }

    if (result == "FeedBack") {
      setState(() {
        isLoading = false;
      });
      //Navigator.push(context,materialPageRoute(builder, (context)=>));
    }
  }

  Future<void> delete_create_student_marks_card_html() async {
    try {
      // same as SharedPreferenceUtils.getexternalbase(...)
      Directory? sppath = await getExternalStorageDirectory();
      if (sppath == null) return;

      String filepath = '${sppath.path}/TrueGuide/Reports/Clearance/';

      String htmlPath = '${filepath}Clearance_form.html';

      File file = File(htmlPath);

      if (await file.exists()) {
        print('deleting file exist');
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<String> create_student_clearance_html() async {
    // same as SharedPreferenceUtils.getexternalbase(...)
    Directory? sppath = await getExternalStorageDirectory();
    if (sppath == null) return '';

    filepath = '${sppath.path}/TrueGuide/Reports/Clearance/';
    htmlPath = '${filepath}Clearance_form.html';

    // ensure directory exists
    await Directory(filepath).create(recursive: true);

    File htmlFile = File(htmlPath);

    // ✅ SAME AS Java:
    // if html file exists → return path (do NOT rewrite)
    if (await htmlFile.exists()) {
      return htmlPath;
    }

    // create writer (PrintWriter equivalent)
    IOSink writer = htmlFile.openWrite(encoding: utf8);

    // generate html (same logic as Java)
    await generate_clearance_report(writer);

    await writer.flush();
    await writer.close();

    return htmlPath;
  }

  IOSink? get_writer_stream() {
    // same as: new File(filepath)
    Directory dir = Directory(filepath);

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    File htmlFile = File(htmlPath);

    print('filepath=$filepath  htmlPath=$htmlPath');

    // same logic: if html file exists → return null
    if (htmlFile.existsSync()) {
      return null;
    }

    IOSink? writer;
    try {
      // utf-8 encoding same as Java PrintWriter(htmlPath, "utf-8")
      writer = htmlFile.openWrite(encoding: utf8);
    } catch (e) {
      print(e);
    }

    return writer;
  }

  Future<void> generate_clearance_report(IOSink writer) async {
    String html = "<html><head>\n";

    html += """
<style>
table.outer {
 width: 100%;
 height: 100%;
 font-family : sans-serif;
 border-collapse: collapse;
 border: 2px solid black;
 border-radius: 25px 0px;
 padding-left: 10px;
 padding-right: 10px;
 padding-top: 10px;
 padding-bottom: 10px;
 table-layout: fixed;
}
table {
  border-collapse: collapse;
  table-layout: fixed;
}
p.one{
 font-family : sans-serif;
 font-size: 20px;
 font-weight: bold;
}
p.two{
 font-family : sans-serif;
 font-size: 20px;
}
.row {
  margin-left:-5px;
  margin-right:-5px;
}
.column {
  float: left;
  width: 30%;
  padding: 5px;
}
.column1 {
  float: left;
  width: 60%;
  padding: 5px;
}
.row::after {
  content: "";
  clear: both;
  display: table;
}
tr.sts{
 font-family: sans-serif;
 font-size: 20px;
}
tr {
 font-family : sans-serif;
 text-align: center;
}
td {
 padding:3px;
}
td.three {
 padding:0px;
}
.subtable, .subtable tr, .subtable td {
 table-layout: fixed;
 overflow: hidden;
 word-wrap: break-word;
}
</style>
""";

    html += "</head><body>\n";

    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td align=\"center\" style=\"padding:5px;\"><strong>STUDENT CLEARANCE REPORT</strong></td></tr>";
    html += "</tbody></table>";

    html += "<table border=\"0\" style=\"width: 100%;\"><tbody>";
    html += "<tr><td align=\"left\"><b>Date: ${DateTime.now()}</b></td>"
        "<td align=\"left\"><b>Name*: ${Glb.student_name}</b></td></tr>";
    html +=
        "<tr><td align=\"left\"><b>Class: ${Glb.sec_id}</b></td><td></td></tr>";
    html += "</tbody></table>";

    // ================= SCHOLARSHIP DETAILS =================
    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td align=\"center\" style=\"padding:5px;\"><strong>SCHOLARSHIP DETAILS</strong></td></tr>";
    html += "</tbody></table>";

    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td>Year</td><td>Class</td><td>Scholarship</td><td>Applied Date</td>"
        "<td>Sanctioned Date</td><td>Sanctioned Amount</td><td>Released Amount</td></tr>";

    if (schtype_lst == null) {
      html +=
          "<tr><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>";
    }

    for (int i = 0; schtype_lst != null && i < schtype_lst.length; i++) {
      html += "<tr>"
          "<td>${sch_year_lst[i]}</td>"
          "<td>${sch_classname_lst[i]}</td>"
          "<td>${schtype_lst[i]}</td>"
          "<td>${appdate_lst[i]}</td>"
          "<td>${sancdate_lst[i]}</td>"
          "<td>${sancamount_lst[i]}</td>"
          "<td>${dispamount_lst[i]}</td>"
          "</tr>";
    }

    html += "</tbody></table><br>";

    // ================= SUBJECT TEACHER REMARKS =================
    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td align=\"center\" style=\"padding:5px;\"><strong>SUBJECT TEACHER REMARKS</strong></td></tr>";
    html += "</tbody></table>";

    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td>Subject</td><td>Teacher</td><td>Remarks</td><td>Attendance</td><td>Prec(%)</td></tr>";

    int total_taken = 0;
    int total_attended = 0;
    String tot_per = "0";

    for (int i = 0; sub_lst != null && i < sub_lst.length; i++) {
      String sbj = sub_lst[i].toString();
      String subjid = subid_lst[i].toString();

      String name = "NA";
      if (jsubid_lst != null) {
        int ind = jsubid_lst.indexOf(subjid);
        if (ind > -1) name = j_usrname_lst[ind].toString();
      }

      String taken = "0";
      if (class_taken_subid_lst != null) {
        int ind = class_taken_subid_lst.indexOf(subjid);
        if (ind > -1) taken = tot_class_take_count_lst[ind].toString();
      }

      String attended = "0";
      if (attendence_subid_lst != null) {
        int ind = attendence_subid_lst.indexOf(subjid);
        if (ind > -1) attended = attendece_count_lst[ind].toString();
      }

      String perc = "0";
      if (taken != "0") {
        perc = ((double.parse(attended) / double.parse(taken)) * 100)
            .toStringAsFixed(1);
      }

      String remark = "-";
      if (subjec_rem_subid != null) {
        int ind = subjec_rem_subid.indexOf(subjid);
        if (ind > -1) remark = subject_remark[ind].toString();
      }

      html += "<tr>"
          "<td align=\"left\">$sbj</td>"
          "<td align=\"left\">$name</td>"
          "<td>$remark</td>"
          "<td>$attended/$taken</td>"
          "<td>$perc</td>"
          "</tr>";

      total_taken += int.parse(taken);
      total_attended += int.parse(attended);
    }

    if (total_taken > 0) {
      tot_per = ((total_attended / total_taken) * 100).toStringAsFixed(1);
    }

    html += "<tr><td>TOTAL</td><td></td><td></td>"
        "<td>$total_attended/$total_taken</td><td>$tot_per</td></tr>";

    html += "</tbody></table><br>";

    // ================= OTHER REMARKS =================
    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td align=\"center\" style=\"padding:5px;\"><strong>OTHER REMARKS</strong></td></tr>";
    html += "</tbody></table>";

    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html += "<tr><td>Remarks Category</td><td>Date</td><td>Remark</td></tr>";

    for (int i = 0; rcid_lst != null && i < rcid_lst.length; i++) {
      String rcid = rcid_lst[i].toString();
      String cat = remarkcat_lst[i].toString();

      String rem = "-";
      String dt = "-";

      if (rem_rcid_lst != null) {
        int ind = rem_rcid_lst.indexOf(rcid);
        if (ind > -1) {
          rem = rem_remark_lst[ind].toString();
          dt = rem_dt_lst[ind].toString();
        }
      }

      html += "<tr><td>$cat</td><td>$dt</td><td>$rem</td></tr>";
    }

    html += "</tbody></table><br>";

    // ================= LIBRARY BOOKS =================
    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td align=\"center\" style=\"padding:5px;\"><strong>LIBRARY BOOKS(NOT RETURNED)</strong></td></tr>";
    html += "</tbody></table>";

    html += "<table border=\"1\" style=\"width: 100%;\"><tbody>";
    html +=
        "<tr><td>Bookname</td><td>Author</td><td>Issues Date</td><td>Due Date</td><td>Fine</td></tr>";

    if (bookname_lst == null) {
      html += "<tr><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>";
    }

    for (int i = 0; bookname_lst != null && i < bookname_lst.length; i++) {
      html += "<tr>"
          "<td>${bookname_lst[i]}</td>"
          "<td>${author_lst[i]}</td>"
          "<td>${issuedate_lst[i]}</td>"
          "<td>${duedate_lst[i]}</td>"
          "<td>${fine_lst[i]}</td>"
          "</tr>";
    }

    html += "</tbody></table>";

    html += "<br><table border=\"0\" style=\"width:100%\"><tbody>";
    html +=
        "<tr><td></td><td></td><td align=\"right\"><b>Authorised Signatory</b></td></tr>";
    html += "</tbody></table>";

    html += "</body></html>";

    writer.writeln(html);
  }

  Future<String> get_not_returned_library_books() async {
    // same SQL, just renamed variable
    String query = "select bookname,author, fine,issuedate,duedate "
        "from trueguide.tbookborrowtbl,trueguide.tstudenttbl,trueguide.pinsttbl "
        "where tbookborrowtbl.userid='${Glb.userid}' "
        "and tbookborrowtbl.userid=tstudenttbl.usrid "
        "and pinsttbl.instid=tstudenttbl.instid "
        "and tstudenttbl.instid='${Glb.inst_id}' "
        "and returndate='Not Returned' "
        "group by bookname,author, fine,issuedate,duedate,borrowid";

    // assign query back (same flow as Java)
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      bookname_lst = data['X^1_1'] ?? [];
      author_lst = data['X^2_2'] ?? [];
      fine_lst = data['X^3_3'] ?? [];
      issuedate_lst = data['X^4_4'] ?? [];
      duedate_lst = data['X^5_5'] ?? [];

      print('bookname_lst  : $bookname_lst');
      print('author_lst    : $author_lst');
      print('fine_lst      : $fine_lst');
      print('issuedate_lst : $issuedate_lst');
      print('duedate_lst   : $duedate_lst');
    }
    return "SUCCESS";
  }

  Future<String> get_remarks() async {
    String query =
        "select cid from trueguide.pinsttbl where instid='${Glb.inst_id}'";
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      cidCur = data['X^1_1']![0].toString();
      print('cidCur: $cidCur');
    }

    query =
        "select rcid, remarkcat from trueguide.premarkcattbl where cid='$cidCur'";
    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      rcid_lst = data['X^1_1'] ?? [];
      remarkcat_lst = data['X^2_2'] ?? [];
      print('rcid_lst     : $rcid_lst');
      print('remarkcat_lst: $remarkcat_lst');
    }

    query =
        "select rcid, remark, dt from trueguide.tgeneralremarktbl where studid='${Glb.student_id}'";
    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);

      rem_rcid_lst = data['X^1_1'] ?? [];
      rem_remark_lst = data['X^2_2'] ?? [];
      rem_dt_lst = data['X^3_3'] ?? [];

      print('rem_rcid_lst   : $rem_rcid_lst');
      print('rem_remark_lst : $rem_remark_lst');
      print('rem_dt_lst     : $rem_dt_lst');
    }
    return "SUCCESS";
  }

  Future<String> get_subjects_teacher_and_attendence() async {
    // 1️⃣ Get subjects for the class
    String query = """
    select subname, tinstdcstbl.subid
    from trueguide.psubtbl, trueguide.tinstdcstbl
    where tinstdcstbl.subid = psubtbl.subid
      and psubtbl.classid = '${Glb.classid}'
      and instid = '${Glb.inst_id}'
      and psubtbl.subtype = '0'
    order by ord
  """;
    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    print('Subjects Response: $response');
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      sub_lst = data['X^1_1'] ?? [];
      subid_lst = data['X^2_2'] ?? [];
      print('sub_lst   : $sub_lst');
      print('subid_lst : $subid_lst');
    }

    // 2️⃣ Get teachers for subjects
    query = """
    select tteacherdcsstbl.subid, usrname
    from trueguide.tteacherdcsstbl, trueguide.tusertbl
    where tteacherdcsstbl.usrid = tusertbl.usrid
      and instid = '${Glb.inst_id}'
      and tteacherdcsstbl.classid = '${Glb.classid}'
      and tteacherdcsstbl.subtype = '0'
      and ctype = '0'
      and batchid = '${Glb.active_batchid}'
      and secdesc = '${Glb.sec_id}'
  """;
    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    print('Teachers Response: $response');
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      jsubid_lst = data['X^1_1'] ?? [];
      j_usrname_lst = data['X^2_2'] ?? [];
      print('jsubid_lst  : $jsubid_lst');
      print('j_usrname_lst: $j_usrname_lst');
    }

    // 3️⃣ Get total classes taken per subject
    query = """
    select count(*), subid
    from trueguide.tattendstat
    where instid='${Glb.inst_id}'
      and batchid='${Glb.active_batchid}'
      and secdesc='${Glb.sec_id}'
      and classid='${Glb.classid}'
    group by subid
  """;
    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    print('Total Classes Response: $response');
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      tot_class_take_count_lst = data['X^1_1'] ?? [];
      class_taken_subid_lst = data['X^2_2'] ?? [];
    }

    // 4️⃣ Get attended classes for the student
    query = """
    select tattendencetbl.subid, count(*)
    from trueguide.tattendencetbl
    where tattendencetbl.studid='${Glb.student_id}'
      and tattendencetbl.classid='${Glb.classid}'
      and tattendencetbl.instid='${Glb.inst_id}'
      and tattendencetbl.secdesc='${Glb.sec_id}'
      and tattendencetbl.status='1'
      and tattendencetbl.batchid='${Glb.active_batchid}'
    group by tattendencetbl.subid
  """;
    print('Attendance Response: $response');
    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      attendence_subid_lst = data['X^1_1'] ?? [];
      attendece_count_lst = data['X^2_2'] ?? [];
    }

    // 5️⃣ Get subject remarks for the student
    query = """
    select remark, subid
    from trueguide.tteachigsubjectremarktbl
    where instid='${Glb.inst_id}'
      and studid='${Glb.student_id}'
  """;
    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    print('Subject Remarks Response: $response');
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      subject_remark = data['X^1_1'] ?? [];
      subjec_rem_subid = data['X^2_2'] ?? [];
    }
    return "ERROR";
  }

  Future<String> get_scholarship_details() async {
    String query = """
    select schtype, appdate, sancstatus, sancdate, sancamount, dispersestatus, dispamount, remamount, classname, year 
    from trueguide.tscholarshiptbl, trueguide.pclasstbl, trueguide.tbatchtbl 
    where tscholarshiptbl.usrid='${Glb.userid}' 
      and tscholarshiptbl.classid=pclasstbl.classid  
      and tscholarshiptbl.batchid=tbatchtbl.batchid 
      and tscholarshiptbl.instid='${Glb.inst_id}'
  """;

    // Send query via socket
    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (response.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Internet Connection Pls Check Your Connection")));
      return "ERROR";
    }
    if (response.startsWith("ErrorCode#2")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data")));
      return "NODATA";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(response);
      schtype_lst = data['X^1_1'] ?? [];
      appdate_lst = data['X^2_2'] ?? [];
      sancstatus_lst = data['X^3_3'] ?? [];
      sancdate_lst = data['X^4_4'] ?? [];
      sancamount_lst = data['X^5_5'] ?? [];
      dispersestatus_lst = data['X^6_6'] ?? [];
      dispamount_lst = data['X^7_7'] ?? [];
      remamount_lst = data['X^8_8'] ?? [];
      sch_classname_lst = data['X^9_9'] ?? [];
      sch_year_lst = data['X^10_10'] ?? [];

      print('schtype_lst: $schtype_lst');
      print('appdate_lst: $appdate_lst');
      print('sancstatus_lst: $sancstatus_lst');
      print('sancdate_lst: $sancdate_lst');
      print('sancamount_lst: $sancamount_lst');
      print('dispersestatus_lst: $dispersestatus_lst');
      print('dispamount_lst: $dispamount_lst');
      print('remamount_lst: $remamount_lst');
      print('sch_classname_lst: $sch_classname_lst');
      print('sch_year_lst: $sch_year_lst');
    }

    print('Scholarship Types: $schtype_lst');
    print('Applied Dates: $appdate_lst');
    return "SUCCESS";
  }

  Future<String> AsyncTasClearance() async {
    String a = await get_scholarship_details();
    String b = await get_subjects_teacher_and_attendence();
    String d = await get_remarks();
    String e = await get_not_returned_library_books();

    if ((a.contains("ERROR") == true) ||
        (b.contains("ERROR") == true) ||
        (d.contains("ERROR") == true) ||
        (e.contains("ERROR") == true)) {
      return "ERROR";
    } else {
      return "SUCCESS";
    }
    return "SUCCESS";
  }

  void postExecute() async {
    String result = await AsyncTasClearance();

    if (result == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ERROR pls check your connection")));
      return;
    }
    if (result == "SUCCESS") {
      await delete_create_student_marks_card_html();
      await create_student_clearance_html();
      clearance_intent = true;
      //Navigator.push(context, MaterialPageRoute(builder ,(conetxt)=>));
    }
  }

  String checkStatus() {
    studid = int.parse(Glb.student_id);
    status = int.parse(Glb.Status);
    String ret = "";

    if (studid > 0 && status == 0) {
      ret = "Show";
    } else if (studid > 0 && status == 1) {
      ret = "Success";
    }

    return ret;
  }

  Future<void> AsyncTaskperf(BuildContext context) async {
    try {
      // Show loader
      showLoading(context, "Fetching data please wait...");

      // Set the query (same as Glb.tlvStr2)
      String query = """
      select tinstdcstbl.subid, psubtbl.subname, psubtbl.subtype
      from trueguide.tinstdcstbl, trueguide.psubtbl
      where instid='${Glb.inst_id}'
        and tinstdcstbl.classid='${Glb.classid}'
        and tinstdcstbl.subid = psubtbl.subid
    """;

      // Execute query via socketService
      String response =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      print('Subjects Response: $response');

      // Check for error (replace with your actual error parsing logic)
      if (response.startsWith("Err:")) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No Internet Connection Pls Check Your Connection")));
        return;
      }
      if (response.startsWith("ErrorCode#2")) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No Data")));
        return;
      }
      if (response.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        Glb.sub_ind = 0;
        List<String> psubid_lst = data['X^1_1'] ?? [];
        List<String> psubname_lst = data['X^2_2'] ?? [];
        List<String> psubtype_lst = data['X^3_3'] ?? [];

        // Save to SubObj and global map
        SubjectObj subObj = SubjectObj(
          psubid_lst: psubid_lst,
          psubname_lst: psubname_lst,
          psubtype_lst: psubtype_lst,
        );

        Glb.SubMap?.putIfAbsent(
          Glb.student_id,
          () => subObj,
        );

        print("Sub Map${Glb.SubMap}");
      }

      // hideLoading(context);// // Hide loader

      // Navigate based on main_feature
      switch (Glb.main_feature) {
        case "attd_perf":
          Glb.subwise_att = false;
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (_) => NewAttendancePerformance()),
          //   (route) => false,
          // );
          break;
        case "exm":
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OfflineExamScreen()));
          break;
        case "syl_cvr":
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Mysyllabus()));
          break;
        case "onlineexam":
        case "assessments":
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => OnlineExamScreen()),
            (route) => false,
          );
          break;
        case "scholar":
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (_) => NewScholarsCorner()),
          //   (route) => false,
          // );
          break;
        case "TimeTable":
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewTimeTable()));
          break;
        case "chart_gpt":
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => NewChatGpt()),
          // );
          break;
        default:
          print("Unknown main_feature: ${Glb.main_feature}");
      }
    } catch (e) {
      hideLoading(context);
      showToast(context, "An error occurred: $e");
    }
  }

// Example loader & toast functions
  void showLoading(BuildContext context, String msg) {
    // You can use showDialog or any loader package
    print("Loader: $msg");
  }

  void hideLoading(BuildContext context) {
    print("Hide loader");
  }

  void showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StudentDrawer(),
      backgroundColor: Colors.white, // ✅ LIGHT YELLOW REMOVED

      // ===== APP BAR =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: lightGold,
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black),
                          padding: EdgeInsets.zero,
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "STUDENT APP",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyTodayNotifications(),
                                ),
                              );
                              _updateNotificationCount();
                            },
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${Glb.today_noti_count}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () => _showSelectStudentPopup(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== BODY =====
      body: Stack(
        children: [
          Column(
            children: [
              // ===== HEADER =====
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: 165,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(45),
                      ),
                    ),
                    child: Text(
                      "Hello,\n${Glb.student_name}",
                      style: const TextStyle(
                        color: Color(0xFF121212),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // ===== INSTITUTE CARD =====
                  Positioned(
                    top: 100,
                    left: 18,
                    right: 18,
                    child: GestureDetector(
                      onTap: () => showInstituteSelector(),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$selectedInstitute",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Click here to Switch Institute"),
                                CachedNetworkImage(
                                  imageUrl: logo_url, // your institute logo URL
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      const Icon(Icons.account_balance),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.account_balance),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // ===== BIG WHITE FRAME =====
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        menuTile(
                            image: 'assets/images/timetable.png',
                            title: "Time Table",
                            onTap: () async {
                              print("Came In Menu Tile");
                              Glb.main_feature = "TimeTable";
                              String ret = await checkStatus();
                              if (ret == "Success") {
                                if (Glb.SubMap == null) {
                                  Glb.SubMap = <String, SubjectObj>{};
                                }
                                SubObj = Glb.SubMap?[Glb.student_id];
                                print("thta Sub Obj is =========: $SubObj");
                                if (SubObj == null) {
                                  SubObj = SubjectObj();
                                  AsyncTaskperf(context);
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewTimeTable()));
                                }
                              } else {
                                print("ShowDilog");
                              }
                            }),
                        menuTile(
                          image: 'assets/images/exam_8750666.png',
                          title: "Examination",
                          onTap: () async {
                            Glb.main_feature = "exm";

                            String ret = await checkStatus();

                            if (ret.toUpperCase() == "SUCCESS") {
                              Glb.SubMap ??= {};

                              SubObj = Glb.SubMap![Glb.student_id];

                              if (SubObj == null) {
                                SubObj = SubjectObj();
                                AsyncTaskperf(context);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OfflineExamScreen(),
                                  ),
                                );
                              }
                            } else {
                              print("ShowDialog");
                            }
                          },
                        ),
                        menuTile(
                          image: 'assets/images/homework-icon-21.jpg',
                          title: "Homework",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeworkScreen())),
                        ),
                        menuTile(
                          image: 'assets/images/online-exam.webp',
                          title: "Online Exam",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OnlineExamScreen())),
                        ),
                        menuTile(
                            image: 'assets/images/library_mgmt.png',
                            title: "Digital Library",
                            onTap: () {}),
                        menuTile(
                            image: 'assets/images/scoler.png',
                            title: "Scholar",
                            onTap: () {}),
                        menuTile(
                            image: 'assets/images/assessmnt.png',
                            title: "Assessmnt ",
                            onTap: () {}),
                        menuTile(
                            image: 'assets/images/placement.png',
                            title: "Placement",
                            onTap: () {}),
                        menuTile(
                            image: 'assets/images/syllabus-icon-14.jpg',
                            title: "Syllabus Cover",
                            onTap: () {}),
                        menuTile(
                            image: 'assets/images/BUS.png',
                            title: "Bus Stand",
                            onTap: () {}),
                        menuTile(
                          image: 'assets/images/fee-detail.png',
                          title: "Fees Details",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FeesDetailsScreen())),
                        ),
                        menuTile(
                          image: 'assets/images/document-management.jpg',
                          title: "Document-Management",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StudentDocumentPage())),
                        ),
                        menuTile(
                          image: 'assets/images/ask-question.png',
                          title: "Ask Me Anything",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AIIntegratedPage())),
                        ),
                        menuTile(
                            image: 'assets/images/syllabus.jpg',
                            title: "My Syllabus",
                            onTap: () async {
                              Glb.main_feature = "syl_cvr";
                              String ret = await checkStatus();
                              if (ret == "Success") {
                                if (Glb.SubMap == null) {
                                  Glb.SubMap = <String, SubjectObj>{};
                                }
                                SubObj = Glb.SubMap?[Glb.student_id];
                                print("thta Sub Obj is =========: $SubObj");
                                if (SubObj == null) {
                                  SubObj = SubjectObj();
                                  AsyncTaskperf(context);
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Mysyllabus()));
                                }
                              } else {
                                print("ShowDilog");
                              }
                            }),
                        menuTile(
                          image: 'assets/images/statastic.png',
                          title: "Statistics",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StudentDashboard())),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) Glb.showLoadingIndicator(context),
        ],
      ),
    );
  }

  Widget menuTile({
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showInstitutePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Institute"),
        content: const Text("LATEST DEMO INSTITUTE\nClass: 1 (A)"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  void _showSelectStudentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Student"),
        content: Text(Glb.student_name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }
}
