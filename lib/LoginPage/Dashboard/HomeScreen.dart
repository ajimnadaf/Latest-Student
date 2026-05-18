import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: library_prefixes
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/MarksRep.dart';
import 'package:student_app/LoginPage/Dashboard/social_skill.dart';
import 'package:student_app/LoginPage/login.dart';
import 'package:student_app/studentfeautures/GenerateFullMatrixPerfrm%20.dart';
import 'package:student_app/studentfeautures/Home_work.dart';
import 'package:student_app/studentfeautures/SocialSkills.dart';

SocketService socketService = SocketService();

String flag = "", bnr_msg = "", bnr_Usrname = "", dob = "";
String cur_date = "";
String tot_HW_given1 = "";
String cons_today_att = "";
String seven_days_text = "";
String tilldate_text = "";
String remark_cond = "";
String remark_cond_1 = "", tmp = "";
String demand = "";
String credit = "";
String debit = "";
String libid = "";
String fine = "";
String lib = "";
String finetxt = "";
String feeContent = "";
String tot_fine = "";
String cnts = "";
String Positions = "";
String selectStudent = "";

String InstituteName = "";
String Secid = "";

bool isLoading = false;

// DUMMY
String todayAttendance = "";
String sevenDaysText = "";
String tillDateText = "";
String homeworkText = "";
String examText = "";
String busLocation = "";

int tot_HW_given = 0;
int tot_hw_done = 0;

List non_cons_tot__today_lst = [],
    non_cons_tot_today_attended_lst = [],
    non_cons_tot_7days_lst = [],
    non_cons_tot_7days_attended_lst = [],
    non_cons_tot_till_lst = [],
    non_cons_tot_till_attended_lst = [],
    cons_today_display_lst = [],
    cons_last_7_days_lst = [],
    cons_till_date_lst = [],
    cons_till_date_att_lst = [];

List wishid_lst = [], occasion_lst = [], link_lst = [], dt_lst = [];
List noticeid_Lst = [], notice_Lst = [], notice_link_Lst = [];
List cons_attended_7_days_lst = [];
List heads_1 = [], heads_2 = [];
List cons_7days_display_lst = [], cons_till_date_display_lst = [];
List new_heads = [];
List accno_Lst = [],
    bname_Lst = [],
    author_Lst = [],
    edition_Lst = [],
    issuedate_Lst = [],
    duedate_Lst = [];

class CountObj {
  int tot_classis = 0;
  int att_classis = 0;
}

SplayTreeMap<String, CountObj> countMap = SplayTreeMap<String, CountObj>();

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
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

class _StudentDashboardState extends State<StudentDashboard> {
  void initState() {
    super.initState();
    get();
    date();
    onpost();
  }

  void get() {
    setState(() {
      isLoading = true;
    });
    InstituteName = Glb.student_instname_cur;
    selectStudent = Glb.student_name;
    Secid = Glb.sec_id;
    setState(() {
      isLoading = false;
    });
  }

  void date() {
    setState(() {
      isLoading = true;
    });
    DateTime now = DateTime.now(); // Current date & time
    cur_date = DateFormat('yyyy-MM-dd').format(now); // Format as "2025-12-26"

    print(cur_date);
    setState(() {
      isLoading = false;
    }); // Example output: 2025-12-26
  }

  Future<String> get_Data_spcl() async {
    if (flag == "non_cons_today") {
      String query =
          "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate = CURRENT_DATE and " + //and = CURRENT_DATE and
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and  " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot__today_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot__today_lst = data['X^1_1'] ?? [];
        print("non_cons_tot__today_lst: $non_cons_tot__today_lst");
      }

      query =
          "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate = CURRENT_DATE  and " + //
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and tattendencetbl.status='1' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid" +
              " and studid= '" +
              Glb.student_id +
              "'";
      print("Query: $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_today_attended_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot_today_attended_lst = data['X^1_1'] ?? [];
        print(
            "non_cons_tot_today_attended_lst: $non_cons_tot_today_attended_lst");
      }
    }

    if (flag == "non_cons_7_days") {
      String query =
          "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and " +
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_7days_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot_7days_lst = data['X^1_1'] ?? [];
        print("non_cons_tot_7days_lst: $non_cons_tot_7days_lst");
      }

      query = "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
          "instid='" +
          Glb.inst_id +
          "' and attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and " +
          "tattendencetbl.classid ='" +
          Glb.classid +
          "' and tattendencetbl.status='1' and " +
          "secdesc = '" +
          Glb.sec_id +
          "' and psubtbl.subid= tattendencetbl.subid " +
          "and studid= '" +
          Glb.student_id +
          "'";
      print("Query: $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_7days_attended_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot_7days_attended_lst = data['X^1_1'] ?? [];
        print(
            "non_cons_tot_7days_attended_lst: $non_cons_tot_7days_attended_lst");
      }
    }

    if (flag == "non_cons_till_date") {
      String query =
          "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate <= CURRENT_DATE and " +
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and  batchid='" +
              Glb.active_batchid +
              "' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_till_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot_till_lst = data['X^1_1'] ?? [];
        print("non_cons_tot_till_lst: $non_cons_tot_till_lst");
      }

      query =
          "select distinct(attendid,subname) from trueguide.psubtbl,trueguide.tattendencetbl where " +
              "psubtbl.subid = tattendencetbl.subid and tattendencetbl.studid='" +
              Glb.student_id +
              "'  and " +
              "tattendencetbl.classid='" +
              Glb.classid +
              "' and tattendencetbl.instid='" +
              Glb.inst_id +
              "' " +
              "and tattendencetbl.secdesc='" +
              Glb.sec_id +
              "'and tattendencetbl.status='1' and " +
              "tattendencetbl.batchid='" +
              Glb.active_batchid +
              "' group  by attendid,subname";
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_till_attended_lst = [];
        return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);
        non_cons_tot_till_attended_lst = data['X^1_1'] ?? [];
        print(
            "non_cons_tot_today_attended_lst: $non_cons_tot_till_attended_lst");
      }
    }
    return "SUCCESS";
  }

  void onpostExecute() async {
    setState(() {
      isLoading = true;
    });
    String result = await get_Data_spcl();
    if (result.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No Internet Pls Check your Connection")));
    }
    if (result.toUpperCase() == "SUCCESS") {
      countMap.clear();
      cons_today_display_lst.clear();
      if (flag.toLowerCase() == "non_cons_today") {
        if (non_cons_tot__today_lst != null) {
          for (int i = 0; i < non_cons_tot__today_lst.length; i++) {
            String data = non_cons_tot__today_lst[i].toString();
            List<String> split = data.split(",");

            if (non_cons_tot_today_attended_lst != null) {
              int index = non_cons_tot_today_attended_lst.indexOf(data);

              if (index != -1) {
                cons_today_display_lst
                    .add('${split[1].replaceAll("\"", "")} : Present');
              } else {
                cons_today_display_lst
                    .add('${split[1].replaceAll("\"", "")} : Absent');
              }
            }
          }

          if (cons_today_display_lst != null &&
              cons_today_display_lst.isNotEmpty) {
            print("cons_today_display_lst: $cons_today_display_lst");
            //showPopup(cons_today_display_lst);
          }
        }
      }
      if (flag.toLowerCase() == "non_cons_7_days") {
        if (non_cons_tot_7days_lst != null) {
          for (int i = 0; i < non_cons_tot_7days_lst.length; i++) {
            String data = non_cons_tot_7days_lst[i].toString();
            List<String> split = data.split(",");

            CountObj? obj = countMap[split[1]];
            if (obj == null) {
              obj = CountObj();
            }

            obj.tot_classis = obj.tot_classis + 1;

            if (non_cons_tot_7days_attended_lst != null) {
              int index = non_cons_tot_7days_attended_lst.indexOf(data);
              if (index != -1) {
                obj.att_classis = obj.att_classis + 1;
              } else {
                obj.att_classis = obj.att_classis;
              }
            } else {
              obj.att_classis = obj.att_classis;
            }

            countMap[split[1]] = obj;
          }

          for (final entry in countMap.entries) {
            String Subject = entry.key;
            CountObj obj = entry.value;

            cons_today_display_lst.add(
              '${Subject.replaceAll(")", "").replaceAll("\"", "")} - ${obj.att_classis}  / ${obj.tot_classis}',
            );
          }

          if (cons_today_display_lst != null &&
              cons_today_display_lst.isNotEmpty) {
            print("cons_today_display_lst: $cons_today_display_lst");
            //showPopup(cons_today_display_lst);
          }
        }
      }

      if (flag.toLowerCase() == "non_cons_till_date") {
        if (non_cons_tot_till_lst != null) {
          for (int i = 0; i < non_cons_tot_till_lst.length; i++) {
            String data = non_cons_tot_till_lst[i].toString();
            List<String> split = data.split(",");

            CountObj? obj = countMap[split[1]];
            if (obj == null) {
              obj = CountObj();
            }

            obj.tot_classis = obj.tot_classis + 1;

            if (non_cons_tot_till_attended_lst != null) {
              int index = non_cons_tot_till_attended_lst.indexOf(data);
              if (index != -1) {
                obj.att_classis = obj.att_classis + 1;
              } else {
                obj.att_classis = obj.att_classis;
              }
            } else {
              obj.att_classis = obj.att_classis;
            }

            countMap[split[1]] = obj;
          }

          for (final entry in countMap.entries) {
            String Subject = entry.key;
            CountObj obj = entry.value;

            cons_today_display_lst.add(
              '${Subject.replaceAll(")", "").replaceAll("\"", "")} - ${obj.att_classis}  / ${obj.tot_classis}',
            );
          }

          if (cons_today_display_lst != null &&
              cons_today_display_lst.isNotEmpty) {
            print("cons_today_display_lst: $cons_today_display_lst");
            // showPopup(cons_today_display_lst);
          }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String> get_Data() async {
    String query =
        "select msg,usrname from trueguide.tusertbl,trueguide.tbannertbl where " +
            "tusertbl.usrid=tbannertbl.usrid and instid='" +
            Glb.inst_id +
            "' and classid='" +
            Glb.classid +
            "' ";
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
      bnr_msg = data['X^1_1']![0];
      bnr_Usrname = data['X^1_1']![0];
      print("bnr_msg: $bnr_msg  bnr_Usrname: $bnr_Usrname");
    }

    query = "select dob from trueguide.tusertbl where usrid = '" +
        Glb.userid +
        "' ";
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
      dob = data['X^1_1']![0];
      print("dob: $dob");
    }

    query = "select wishid,occasion,link,dt from trueguide.twishtbl ";
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
      wishid_lst = data['X^1_1'] ?? [];
      occasion_lst = data['X^2_2'] ?? [];
      link_lst = data['X^3_3'] ?? [];
      dt_lst = data['X^4_4'] ?? [];

      print("wishid_lst: $wishid_lst");
      print("occasion_lst: $occasion_lst");
      print("link_lst: $link_lst");
      print("dt_lst: $dt_lst");
    }

    query = "select noticeid,notice,link from trueguide.tinstnoticetbl where " +
        "instid ='" +
        Glb.inst_id +
        "' and status='1'";
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
      noticeid_Lst = data['X^1_1'] ?? [];
      notice_Lst = data['X^2_2'] ?? [];
      notice_link_Lst = data['X^3_3'] ?? [];

      print("noticeid_Lst: $noticeid_Lst");
      print("notice_Lst: $notice_Lst");
      print("notice_link_Lst: $notice_link_Lst");
    }

    query = "select hwid from trueguide.thwtbl where " +
        "hwdt='" +
        cur_date +
        "' and instid = '" +
        Glb.inst_id +
        "' and classid = '" +
        Glb.classid +
        "' and secdesc='" +
        Glb.sec_id +
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
      tot_HW_given1 = data['X^1_1']![0];
      tot_HW_given = int.parse(tot_HW_given1);

      print("notice_link_Lst: $tot_HW_given");
    }

    if (tot_HW_given > 0) {
      query = "select distinct(hwid) from trueguide.tstudhwtbl where " +
          "hwid in(select hwid from trueguide.thwtbl where " +
          "hwdt='" +
          cur_date +
          "' and instid = '" +
          Glb.inst_id +
          "' and " +
          "classid = '" +
          Glb.classid +
          "'  and secdesc='" +
          Glb.sec_id +
          "') and " +
          "studid='" +
          Glb.student_id +
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
        String tot_hw_done1 = data['X^1_1']![0];
        tot_hw_done = int.parse(tot_hw_done1);

        print("notice_link_Lst: $tot_hw_done");
      }
    }

    if (Glb.attend_type.toUpperCase() == "1") {
      query = "select status from trueguide.tconsoleattendencetbl where  " +
          "attdate=CURRENT_DATE and studid='" +
          Glb.student_id +
          "' and " +
          "instid = '" +
          Glb.inst_id +
          "' and classid = '" +
          Glb.classid +
          "'  and secdesc='" +
          Glb.sec_id +
          "'";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        cons_today_att = "Not Taken";
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        String status = data['X^1_1']![0];
        if (status.toUpperCase == "0") {
          cons_today_att = "Absent";
        }
        if (status.toUpperCase() == "1") {
          cons_today_att = "Present";
        }

        print("notice_link_Lst: $cons_today_att");
      }

      cons_last_7_days_lst = [];

      query =
          "select distinct(attdate) from trueguide.tconsoleattendencetbl where " +
              "attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and " +
              "instid = '" +
              Glb.inst_id +
              "' and classid = '" +
              Glb.classid +
              "'  and secdesc='" +
              Glb.sec_id +
              "' ";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        seven_days_text = "Last 7 Days' Attendance : Not Taken";
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        cons_last_7_days_lst = data['X^1_1'] ?? [];
        seven_days_text =
            "Last 7 Days' Attendance : 0 / ${cons_last_7_days_lst.length}";
      }
      cons_attended_7_days_lst = [];

      query = " select distinct(attdate) from trueguide.tconsoleattendencetbl where  " +
          "attdate in (select distinct(attdate) from trueguide.tconsoleattendencetbl where " +
          "attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and  batchid='" +
          Glb.active_batchid +
          "' and " +
          "instid = '" +
          Glb.inst_id +
          "' and classid = '" +
          Glb.classid +
          "'  and secdesc='" +
          Glb.sec_id +
          "' ) " +
          "and studid='" +
          Glb.student_id +
          "'  and status = '1'";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        if (cons_last_7_days_lst != null) {
          seven_days_text =
              "Last 7 Days' Attendance : 0 / ${cons_last_7_days_lst.length}";
        } else {
          seven_days_text = "Last 7 Days' Attendance : Not Taken";
        }
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        cons_attended_7_days_lst = data['X^1_1'] ?? [];
        seven_days_text =
            "Last 7 Days' Attendance : ${cons_attended_7_days_lst.length} / ${cons_last_7_days_lst.length}";
      }

      cons_till_date_lst = [];
      query =
          " select distinct(attdate) from trueguide.tconsoleattendencetbl where " +
              " attdate <= CURRENT_DATE and  batchid='" +
              Glb.active_batchid +
              "' and " +
              "instid = '" +
              Glb.inst_id +
              "' and classid = '" +
              Glb.classid +
              "'and secdesc='" +
              Glb.sec_id +
              "'" +
              " group by attdate order by attdate";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        tilldate_text = "Till Date Attendance : Not Taken";
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        cons_till_date_lst = data['X^1_1'] ?? [];
        print("cons_till_date_lst: $cons_till_date_lst");
      }

      query = " select attdate from trueguide.tconsoleattendencetbl where  " +
          "attdate in (select distinct(attdate) from trueguide.tconsoleattendencetbl where " +
          " attdate <= CURRENT_DATE and  batchid='" +
          Glb.active_batchid +
          "' and " +
          "instid = '" +
          Glb.inst_id +
          "' and classid = '" +
          Glb.classid +
          "'and secdesc='" +
          Glb.sec_id +
          "') " +
          "and studid='" +
          Glb.student_id +
          "' and status = '1' group by attdate order by attdate";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        if (cons_till_date_lst != null) {
          tilldate_text =
              "Till Date Attendance : 0/ ${cons_till_date_lst.length}";
        } else {
          tilldate_text = "Till Date Attendance : Not Taken";
        }
        //return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        cons_till_date_att_lst = data['X^1_1'] ?? [];
        tilldate_text =
            "Till Date Attendance : ${cons_till_date_att_lst.length} / ${cons_till_date_lst.length}";

        print("cons_till_date_lst: $tilldate_text");
      }
    } else {
      String query =
          "select count(distinct(attendid,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate = CURRENT_DATE and " + //and = CURRENT_DATE and
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot__today_lst = [];
        //   return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        cons_till_date_att_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot__today_lst");
      }

      query =
          "select count(distinct(attendid,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate = CURRENT_DATE  and " + //
              "tattendencetbl.classid ='" +
              Glb.classid +
              "'  and tattendencetbl.status='1'  and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid" +
              " and studid= '" +
              Glb.student_id +
              "'";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_today_attended_lst = [];
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        non_cons_tot_today_attended_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot_today_attended_lst");
      }

      query = "select count(distinct(attendid,attdate,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
          "instid='" +
          Glb.inst_id +
          "' and attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and " +
          "tattendencetbl.classid ='" +
          Glb.classid +
          "' and " +
          "secdesc = '" +
          Glb.sec_id +
          "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_7days_lst = [];
        //  return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        non_cons_tot_7days_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot_7days_lst");
      }
      query = "select count(distinct(attendid,attdate,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
          "instid='" +
          Glb.inst_id +
          "' and attdate >= CURRENT_DATE - 7 and attdate <= CURRENT_DATE and " +
          "tattendencetbl.classid ='" +
          Glb.classid +
          "'  and tattendencetbl.status='1'  and " +
          "secdesc = '" +
          Glb.sec_id +
          "' and psubtbl.subid= tattendencetbl.subid " +
          "and studid= '" +
          Glb.student_id +
          "'";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_7days_attended_lst = [];
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        non_cons_tot_7days_attended_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot_7days_attended_lst");
      }
      query =
          "select count(distinct(attendid,attdate,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate <= CURRENT_DATE and  batchid='" +
              Glb.active_batchid +
              "' and " +
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_till_lst = [];
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        non_cons_tot_till_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot_till_lst");
      }
      query =
          "select count(distinct(attendid,attdate,subname)) from trueguide.psubtbl,trueguide.tattendencetbl  where   " +
              "instid='" +
              Glb.inst_id +
              "' and attdate <= CURRENT_DATE and  batchid='" +
              Glb.active_batchid +
              "' and " +
              "tattendencetbl.classid ='" +
              Glb.classid +
              "' and tattendencetbl.status='1' and " +
              "secdesc = '" +
              Glb.sec_id +
              "' and psubtbl.subid= tattendencetbl.subid " +
              "and studid= '" +
              Glb.student_id +
              "'";
      print("Query : $query");
      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        non_cons_tot_till_attended_lst = [];
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        non_cons_tot_till_attended_lst = data['X^1_1'] ?? [];

        print("cons_till_date_lst: $non_cons_tot_till_attended_lst");
      }
    }

    query =
        "select  particulars from trueguide.pfeesreceiptparticularstbl where instid='" +
            Glb.inst_id +
            "' and showinstudapp='1'";
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      //return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      heads_1 = data['X^1_1'] ?? [];

      print("heads_1: $heads_1");
    }

    query =
        "select  particulars from trueguide.pfeesreceiptparticularstbl where instid='" +
            Glb.inst_id +
            "' and showinstudapp='1'";
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      //return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      heads_2 = data['X^1_1'] ?? [];

      print("heads_2: $heads_2");
    }

    for (int i = 0; heads_1 != null && i < heads_1.length; i++) {
      new_heads.add(heads_1[i].toString());
    }
    for (int i = 0; heads_2 != null && i < heads_2.length; i++) {
      new_heads.add(heads_2[i].toString());
    }

    for (int i = 0; new_heads != null && i < new_heads.length; i++) {
      if (i == 0) {
        remark_cond = "'" + new_heads[i].toString() + "'";
      } else {
        remark_cond += ",'" + new_heads[i].toString() + "'";
      }
    }
    if (remark_cond.length == 0) {
      remark_cond = "";
      remark_cond_1 = "";
    } else {
      String tmp = remark_cond;
      remark_cond = " and remark in (" + remark_cond + ")";
      remark_cond_1 =
          " and (particular in (" + tmp + ") or head in(" + tmp + "))";
    }

    demand = "0";
    query =
        "select sum(feespaid) from trueguide.tstudfeestranstbl where studid='" +
            Glb.student_id +
            "' and enttype>='2' and del='0' " +
            remark_cond;
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      demand = data['X^1_1']![0];

      print("demand: $demand");
    }

    credit = "0";
    query =
        "select sum(amount) from trueguide.tinstincmliabilitytbl where studid='" +
            Glb.student_id +
            "' and enttype='1' and del='0' " +
            remark_cond_1;
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      credit = data['X^1_1']![0];

      print("credit: $credit");
    }

    debit = "0";
    query =
        "select sum(amount) from trueguide.tinstincmliabilitytbl where studid='" +
            Glb.student_id +
            "' and enttype='0' and del='0' " +
            remark_cond_1;
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      //return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      debit = data['X^1_1']![0];

      print("debit: $debit");
    }

    query = "select accno,bname,tuniquebooktbl.author,edition,issuedate,duedate,tbookborrowtbl.libid from " +
        "trueguide.tuniquebooktbl,trueguide.tbookborrowtbl,trueguide.plibrarytbl,trueguide.pinsttbl where " +
        "pinsttbl.instid = plibrarytbl.maininstid and plibrarytbl.libid=tbookborrowtbl.libid and " +
        "tuniquebooktbl.ubookid=tbookborrowtbl.ubookid  and returndate='Not Returned' and  " +
        "userid = '" +
        Glb.userid +
        "' and cid in (select cid from trueguide.pinsttbl where instid = '" +
        Glb.inst_id +
        "')";
    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //non_cons_tot_till_attended_lst = [];
      // return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      accno_Lst = data['X^1_1'] ?? [];
      bname_Lst = data['X^2_2'] ?? [];
      author_Lst = data['X^3_3'] ?? [];
      edition_Lst = data['X^4_4'] ?? [];
      issuedate_Lst = data['X^5_5'] ?? [];
      duedate_Lst = data['X^6_6'] ?? [];
      libid = data['X^7_7']![0];
      print("accno_Lst => $accno_Lst");
      print("bname_Lst => $bname_Lst");
      print("author_Lst => $author_Lst");
      print("edition_Lst => $edition_Lst");
      print("issuedate_Lst => $issuedate_Lst");
      print("duedate_Lst => $duedate_Lst");
      print("libid => $libid");

      //print("debit: $debit");
    }

    if (!libid.isEmpty) {
      String query =
          "select fine from trueguide.plibrarytbl where libid='" + libid + "'";
      print("String Query: $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        //non_cons_tot_till_attended_lst = [];
        fine = "0";
        // return "NODATA";
      }
      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        fine = data['X^1_1']![0];
        print("fine => $fine");
      }
    }
    return "SUCCESS";
  }

  void onpost() async {
    setState(() {
      isLoading = true;
    });

    String result = await get_Data();

    if (result.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Connection Lost. Pls Check your connection and try again"),
        ),
      );
    }

    if (result.toUpperCase() == "SUCCESS") {
      // ================= HOMEWORK =================
      if (tot_HW_given == 0 && tot_hw_done == 0) {
        homeworkText = "Home Work Not Given";
      } else {
        homeworkText =
            "Home Work Given = $tot_HW_given\nHome Work Done By Student = $tot_hw_done";
      }

      // ================= ATTENDANCE =================
      cons_7days_display_lst.clear();
      cons_till_date_display_lst.clear();

      if (Glb.attend_type.toUpperCase() == "1") {
        todayAttendance = cons_today_att;
        sevenDaysText = seven_days_text;
        tillDateText = tilldate_text;

        print("Today Attendance : $todayAttendance");
        print("Seven days Attendance: $sevenDaysText");
        print("Till Date Attendance: $tillDateText");

        if (cons_last_7_days_lst != null) {
          for (int i = 0; i < cons_last_7_days_lst.length; i++) {
            String date = cons_last_7_days_lst[i];
            if (cons_attended_7_days_lst != null) {
              int index = cons_attended_7_days_lst.indexOf(date);
              if (index != -1) {
                cons_7days_display_lst.add("$date : Present");
              } else {
                cons_7days_display_lst.add("$date : Absent");
              }
            }
          }
          print("cons_7days_display_lst: $cons_7days_display_lst");
        }

        if (cons_till_date_lst != null) {
          for (int i = 0; i < cons_till_date_lst.length; i++) {
            String date = cons_till_date_lst[i];
            if (cons_till_date_att_lst != null) {
              int index = cons_till_date_att_lst.indexOf(date);
              if (index != -1) {
                cons_till_date_display_lst.add("$date : Present");
              } else {
                cons_till_date_display_lst.add("$date : Absent");
              }
            }
          }
          print("cons_till_date_display_lst: $cons_till_date_display_lst");
        }
      } else {
        if (non_cons_tot__today_lst != null &&
            non_cons_tot__today_lst.isNotEmpty) {
          if (non_cons_tot_today_attended_lst != null &&
              non_cons_tot_today_attended_lst.isNotEmpty) {
            todayAttendance =
                "Today's Attendance: ${non_cons_tot_today_attended_lst[0]} / ${non_cons_tot__today_lst[0]}";
          } else {
            todayAttendance =
                "Today's Attendance: 0 / ${non_cons_tot__today_lst[0]}";
          }
        } else {
          todayAttendance = "Today's Attendance: not taken";
        }
        print("todayaatendance: $todayAttendance");

        if (non_cons_tot_7days_lst != null &&
            non_cons_tot_7days_lst.isNotEmpty) {
          if (non_cons_tot_7days_attended_lst != null &&
              non_cons_tot_7days_attended_lst.isNotEmpty) {
            sevenDaysText =
                "Last 7 Days' Attendance: ${non_cons_tot_7days_attended_lst[0]} / ${non_cons_tot_7days_lst[0]}";
          } else {
            sevenDaysText =
                "Last 7 Days' Attendance: 0 / ${non_cons_tot_7days_lst[0]}";
          }
        } else {
          sevenDaysText = "Last 7 Days' Attendance: -";
        }
        print("sevenDaysText: $sevenDaysText");
        if (non_cons_tot_till_lst != null && non_cons_tot_till_lst.isNotEmpty) {
          if (non_cons_tot_till_attended_lst != null &&
              non_cons_tot_till_attended_lst.isNotEmpty) {
            tillDateText =
                "Till Date Attendance: ${non_cons_tot_till_attended_lst[0]} / ${non_cons_tot_till_lst[0]}";
          } else {
            tillDateText =
                "Till Date Attendance: 0 / ${non_cons_tot_till_lst[0]}";
          }
        } else {
          tillDateText = "Till Date Attendance: -";
        }
        print("tillDateText: $tillDateText");
      }

      // ================= FEES =================
      double demandAmt = safeDouble(demand);
      double creditAmt = safeDouble(credit);
      double debitAmt = safeDouble(debit);

      double paidAmt = creditAmt - debitAmt;
      double remainingAmt = demandAmt - paidAmt;

      String demandTxt = demandAmt == 0 ? "-" : demandAmt.toStringAsFixed(2);
      String paidTxt = paidAmt == 0 ? "-" : paidAmt.toStringAsFixed(2);
      String remainingTxt =
          remainingAmt == 0 ? "-" : remainingAmt.toStringAsFixed(2);

      feeContent =
          "Total Fee: $demandTxt\nPaid: $paidTxt\nRemaining: $remainingTxt";

      // ================= LIBRARY =================
      lib = "Total Borrowed Books : ${accno_Lst.length}";
      finetxt = "Per Days: $fine";

      double finfl = safeDouble(fine);
      double tot = accno_Lst.length * finfl;

      tot_fine = get_exceded_days();
    }

    setState(() {
      isLoading = false;
    });
  }

  double safeDouble(String? value) {
    if (value == null ||
        value.isEmpty ||
        value == "None" ||
        value == "none" ||
        value == "-") {
      return 0.0;
    }
    return double.tryParse(value) ?? 0.0;
  }

  String get_exceded_days() {
    // ===== SAFETY CHECK =====
    if (fine == null ||
        fine.isEmpty ||
        fine.toLowerCase() == "none" ||
        fine == "-" ||
        fine == "0" ||
        fine == "0.0") {
      return "Total Fine : 0";
    }

    int days = 0;
    int daysExceeded = 0;

    DateTime todayDate = DateTime.now();

    for (int i = 0; i < duedate_Lst.length; i++) {
      try {
        String dueDateStr = duedate_Lst[i].toString();

        // Parse yyyy-MM-dd safely
        DateTime dueDate = DateTime.parse(dueDateStr);

        Duration difference = todayDate.difference(dueDate);
        daysExceeded = difference.inDays;

        if (daysExceeded > 0) {
          days += daysExceeded;
        }
      } catch (e) {
        print("Invalid date format in duedate_Lst: ${duedate_Lst[i]}");
      }
    }

    // ===== SAFE DOUBLE PARSE =====
    double finePerDay = 0.0;
    try {
      finePerDay = double.parse(fine);
    } catch (e) {
      finePerDay = 0.0;
    }

    double totalFine = days * finePerDay;

    String fineTxt = totalFine.toStringAsFixed(2);

    return "Total Fine : $fineTxt";
  }

  Future<String> AsyncTasfullperfromancew() async {
    String query =
        "select count(*) from trueguide.tstudentmarksviewtbl where instid='" +
            Glb.inst_id +
            "'";
    print("String Query: $query");

    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }

    if (responce.startsWith("ErrorCode#2")) {
      print("nodata");
    }

    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      cnts = data['X^1_1']![0];
      print("COUNTS TOTAL: $cnts");
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

    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }

    if (responce.startsWith("ErrorCode#2")) {
      print("nodata");
      return "ERROR";
    }

    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      // ✅ FIX 1: store exam names correctly
      Glb.distinct_examname_lst = data['X^1_1'] ?? [];

      // ✅ FIX 2: clear maps (DO NOT ASSIGN STRING TO MAP)
      Glb.all_ex_sub_map.clear();
      Glb.all_ex_tot_map.clear();
      Glb.all_ex_obt_map.clear();

      print("distinct_examname_lst : ${Glb.distinct_examname_lst}");
    }

    for (int i = 0; i < Glb.distinct_examname_lst.length; i++) {
      Glb.examname = Glb.distinct_examname_lst[i].toString();

      String query =
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

      print("query : $query");

      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (responce.startsWith("Err:")) {
        return "ERROR";
      }

      if (responce.startsWith("ErrorCode#2")) {
        print("nodata");
      }

      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);

        Glb.subname_lst = data['X^1_1'] ?? [];
        Glb.marks_total_lst = data['X^2_2'] ?? [];
        Glb.marks_obtained_lst = data['X^3_3'] ?? [];

        print(" Glb.subname_lst : ${Glb.subname_lst}");
        print(" Glb.marks_total_lst : ${Glb.marks_total_lst}");
        print(" Glb.marks_obtained_lst: ${Glb.marks_obtained_lst}");

        // ✅ FIX 3: correct condition
        if (Glb.subname_lst.isNotEmpty) {
          Glb.all_ex_sub_map[Glb.examname] = Glb.subname_lst;
          Glb.all_ex_tot_map[Glb.examname] = Glb.marks_total_lst;
          Glb.all_ex_obt_map[Glb.examname] = Glb.marks_obtained_lst;

          print("all_ex_sub_map: ${Glb.all_ex_sub_map}");
          print("all_ex_tot_map: ${Glb.all_ex_tot_map}");
          print("all_ex_obt_map: ${Glb.all_ex_obt_map}");
        }
      }
    }

    int total_marks_count = 0;
    int total_obt_marks = 0;

    if (Glb.marks_total_lst.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No Data Found")));
    }

    for (int i = 0; i < Glb.marks_total_lst.length; i++) {
      double tm = double.parse(Glb.marks_total_lst[i].toString());
      double om = double.parse(Glb.marks_obtained_lst[i].toString());

      total_marks_count += tm.toInt();
      total_obt_marks += om.toInt();
    }

    Glb.tot_max_mark = total_marks_count.toString();
    Glb.tot_obt_mark = total_obt_marks.toString();

    return "SUCCESS";
  }

  void onpost1() async {
    setState(() {
      isLoading = true;
    });
    String result = await AsyncTasfullperfromancew();

    if (result.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ErrorCode#2")));
      setState(() {
        isLoading = false;
      });
      return;
    } else if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => GenerateFullMatrixPerfrm()));
    } else if (result.toUpperCase() == "NotAllowed") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sorry you are not allowed to view marks")));
    }
    setState(() {
      isLoading = false;
    });
    if (isLoading) Glb.showLoadingIndicator(context);
  }

  void SelectStudentPopUp(int position) async {
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

    if (Glb.main_stud_usrid_lst.length > 0) {
      for (int i = 0; i < Glb.main_stud_usrid_lst.length; i++) {
        selectStudent = Glb.main_stud_usrname_lst[i];
      }
    }

    print("Selected Position: $position");
    Positions = position.toString();
    print("Student ID ID: ${Glb.main_stud_usrid_lst}");
    print("Student  Name: ${Glb.main_stud_usrname_lst}");
    selectStudent;

    if (Glb.inst_status_cur == "0") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "This institution has been blocked! \n Contact administrator")));
    }

    onpost();
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
          itemCount: Glb.main_stud_usrid_lst.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.school),
              title: Text(Glb.main_stud_usrname_lst[index].toString()),
              subtitle: Text("StudentID: ${Glb.main_stud_usrid_lst[index]}"),
              onTap: () {
                Navigator.pop(context);

                // Run the selector logic once
                SelectStudentPopUp(index);

                // Update UI only
                setState(() {
                  selectStudent = Glb.main_stud_usrname_lst.toString();
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double orangeHeight = 150;
    const double overlap = 70;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text(
          "STUDENT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // ================= BODY =================
      body: Stack(
        children: [
          // ================= ORANGE HEADER =================
          Container(
            height: orangeHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB300),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // ================= SCROLLABLE CONTENT =================
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              orangeHeight - overlap,
              20,
              30,
            ),
            child: Column(
              children: [
                // ================= STUDENT INFO CARD =================
                Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$InstituteName",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${selectStudent}\n${Secid}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== PROFILE AVATAR (SAME) =====
                        GestureDetector(
                          onTap: () async {
                            showInstituteSelector();
                            debugPrint("Profile avatar clicked");
                          },
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= BUS LOCATION =================
                _clickableCard(
                  onTap: () async {
                    debugPrint("Bus Location clicked");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/school_bus.png",
                    title: "Bus Location",
                    subtitle: "Current Location: Not Available",
                  ),
                ),

                const SizedBox(height: 14),

                // ================= ATTENDANCE =================
                _attendanceCard(),

                const SizedBox(height: 14),

                // ================= EXAM =================
                _clickableCard(
                  onTap: () async {
                    onpost1();
                    debugPrint("Exam Performance clicked");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/exam_erformance.png",
                    title: "Exam Performance",
                    subtitle: "Click here to view exam summary",
                  ),
                ),

                const SizedBox(height: 14),

                // ================= HOMEWORK =================
                _clickableCard(
                  onTap: () async {
                    if (tot_HW_given == 0 && tot_hw_done == 0) {
                      return;
                    } else {
                      Glb.main_feature = "Home_screen";

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeworkScreen()));
                    }
                    // Navigator.push(
                    //     context,s
                    //     MaterialPageRoute(
                    //         builder: (context) => HomeworkScreen()));

                    debugPrint("Homework clicked");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/home_works.png",
                    title: "Homework",
                    subtitle: "$homeworkText",
                  ),
                ),
                const SizedBox(height: 14),

                _clickableCard(
                  onTap: () async {
                    debugPrint("Fee Details");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/fee-detail.png",
                    title: "Fee Details",
                    subtitle: "$feeContent",
                  ),
                ),
                const SizedBox(height: 14),

                _clickableCard(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SocialSkill()));
                    debugPrint("Social Skills");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/social_skills.png",
                    title: "Social Skills",
                    subtitle: "Home Work Not Given",
                  ),
                ),
                if (accno_Lst != null) const SizedBox(height: 14),

                _clickableCard(
                  onTap: () async {
                    debugPrint("Social Skills");
                  },
                  child: _normalCard(
                    imagePath: "assets/images/libb.png",
                    title: "Borrowed Books From Library:",
                    subtitle: "$lib \n $finetxt \n $tot_fine",
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) Glb.showLoadingIndicator(context),
        ],
      ),
    );
  }

  // ================= CLICKABLE CARD =================
  Widget _clickableCard({
    required Widget child,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await onTap();
      },
      child: child,
    );
  }

  // ================= NORMAL CARD (ASSET IMAGE) =================
  Widget _normalCard({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 65,
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ATTENDANCE CARD =================
  Widget _attendanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/att_logo.png",
                  width: 65,
                  height: 65,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Attendance Performance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _attendanceRow(
              value: "$todayAttendance",
              onTap: () async {
                if (Glb.attend_type.toUpperCase() == "1") {
                } else {
                  if (non_cons_tot__today_lst != null) {
                    flag = "non_cons_today";
                    onpostExecute();
                  }
                }
                debugPrint("Today's Attendance clicked");
              },
            ),
            _attendanceRow(
              value: "$sevenDaysText",
              onTap: () async {
                if (Glb.attend_type.toUpperCase() == "1") {
                  if (cons_7days_display_lst != null &&
                      cons_7days_display_lst.length > 0) {
                    showDataDialog(context, cons_7days_display_lst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Data Not Found")));
                  }
                } else {
                  if (non_cons_tot_7days_lst != null) {
                    flag = "non_cons_7_days";
                    onpostExecute();
                  }
                }
                debugPrint("Last 7 Days Attendance clicked");
              },
            ),
            _attendanceRow(
              value: "$tillDateText",
              onTap: () async {
                if (Glb.attend_type.toUpperCase() == "1") {
                  if (cons_till_date_display_lst != null &&
                      cons_till_date_display_lst.length > 0) {
                    showDataDialog(context, cons_till_date_display_lst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Data Not Found")));
                  }
                } else {
                  if (non_cons_tot_till_lst != null) {
                    flag = "non_cons_till_date";
                    onpostExecute();
                  }
                }
                debugPrint("Till Date Attendance clicked");
              },
            ),
          ],
        ),
      ),
    );
  }

  void showDataDialog(
    BuildContext context,
    List<dynamic> dataList,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: dataList.isEmpty
                ? const Text("No data available")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          dataList[index].toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ================= ATTENDANCE ROW =================
  Widget _attendanceRow({
    // required String title,
    required String value,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        await onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Expanded(child: Text(title)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
