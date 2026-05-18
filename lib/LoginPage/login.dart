// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/LoginPage/Dashboard/Dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/LoginPage/institutelogin.dart';
import 'package:student_app/Services/SharedPreKey.dart';
import 'package:student_app/Services/shared_preffrences.dart';

bool isLoading = false;
String LoginID = "", Passwd = "";
String response = "";
String ips_fetched = "", devid = "";
String newTokenStr = "";

SharedPreferenceService sharedPreferenceService = SharedPreferenceService();

List student_id_lst = [],
    inst_id_lst = [],
    classid_lst = [],
    sec_id_lst = [],
    roll_no_lst = [],
    Status_lst = [],
    batchid_lst = [],
    ctype_lst = [],
    year_lst = [],
    subdiv_lst = [],
    atttype_lst = [],
    update_info_lst = [];
Map<String, StudentLoginInfoObj> studentLoginInfoMap = {};

class StudentLoginInfoObj {
  List student_id_lst = [];
  List inst_id_lst = [];
  List classid_lst = [];
  List sec_id_lst = [];
  List roll_no_lst = [];
  List Status_lst = [];
  List batchid_lst = [];
  List ctype_lst = [];
  List year_lst = [];
  List subdiv_lst = [];
  List atttype_lst = [];
  List instname_lst = [];
  List inst_expiry_lst = [];
  List inst_status_lst = [];
  List inst_adtp_lst = [];
  List update_info_lst = [];
  List custadvyrl_lst = [];

  Map<String, StudentJoinsObj> instjoinMap = {};
}

class StudentJoinsObj {}

// --- Global Map to store login info ---

String ip1 = "";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void initState() {
    super.initState();
    loadAppVersion();
    onLoad();
  }

  bool _isPasswordSameAsLogin = false;
  bool _obscurePassword = true;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SocketService socketService = SocketService();
  String serverResponse = '';

  // Lists to hold institute names/details temporarily after fetching
  List<String> instname_lst = [];
  List<String> inst_expiry_lst = [];
  List<String> inst_status_lst = [];
  List<String> inst_adtp_lst = [];
  List<String> custadvurl_lst = [];

  // Lists to hold sibling data
  List<String> sbusrid_lst = [];
  List<String> subusrname_lst = [];

  // Lists to hold advertisement data
  List<String> adid_lst = [];
  List<String> adtp_lst = [];

  @override

  // --- Helper: Convert raw string to structured map ---
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

  Future<void> loadAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    String versionName = info.version; // "2.3.1"
    String buildNumber = info.buildNumber; // "23"

    int versionCode = int.parse(buildNumber); // SAFE

    print("VersionName: $versionName");
    print("VersionCode: $versionCode");

    Glb.version = buildNumber;
  }

  Future<void> AfterDoInBackground() async {
    setState(() {
      isLoading = true;
    });
    if (_loginController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Id Cannot be empty")));
      return;
    } else if (_passwordController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Password Cannot be empty")));
      return;
    } else {
      String result =
          await loginFuture(_loginController.text, _passwordController.text);

      if (result.toUpperCase() == "NOREG") {
        setState(() {
          isLoading = false;
        });
        print("No reg");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => InstitutionLoginScreen()));
      }
      if (result.toUpperCase() == "PASSWORD_ERROR") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Wrong Password. Please Contact Class Teacher/Office Admin")));
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (result.toUpperCase() == "REG") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Your are not registered as a student. Please Contact Class Teacher/Office Admin")));
        setState(() {
          isLoading = false;
        });
        return;
      } else if (result.toUpperCase() == "NOPASS") {
        //Hnadle Error;
        setState(() {
          isLoading = false;
        });

        return;
      } else if (result.toUpperCase() == "ERROR") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Pls Check your Connection And Try Again.")));
        setState(() {
          isLoading = false;
        });

        return;
      } else if (result.toUpperCase() == "DEVLIMIT") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Device Limit Reached!! Sorry Maximum 3 devices are allowed for login")));
        setState(() {
          isLoading = false;
        });
        return;
      } else if (result.toLowerCase() == "otp") {
        //ErrorAlertBoxOpen
        setState(() {
          isLoading = false;
        });
        return;
      } else if (result == "Inst_list") {
        setState(() {
          isLoading = false;
        });
        //print("555555555555555555");
        String app_db_version = Glb.app_version_in_db;

        if (app_db_version.length == 0) {
        } else {
          // print("Entert hee whats next");
          int db_app_v = int.parse(app_db_version);
          int lib_app_v = int.parse(Glb.version);

          if (db_app_v > lib_app_v) {
            Glb.link = Glb.app_link;

            //UpgardeAlertBoxOpen
          }
          if (Glb.fileOp == true) {
            await sharedPreferenceService.saveString(
                Sharedprekey.LoginIdKey, _loginController.text);
            await sharedPreferenceService.saveString(
                Sharedprekey.Paasswdkey, _passwordController.text);
          }

          if (Glb.ips_fetched == false &&
              (ip1 == "None") == false &&
              (ip1.toUpperCase() == "NA") == false &&
              ip1.length > 0) {
            if (Glb.error_code == 0) {
              await sharedPreferenceService.saveString(
                  Sharedprekey.HostIDkey, ip1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Unable to connect to your institution, please restart the app and try again login.")));
            }
          } else {
            await sharedPreferenceService.saveString(
                Sharedprekey.HostIDkey, Glb.Hostnames);
          }

          String vals = Glb.main_stud_usrid_lst[0].toString() +
              "," +
              Glb.main_stud_usrname_lst[0].toString() +
              "-";

          for (int z = 0; z < student_id_lst.length; z++) {
            if (z == 0) {
              vals += student_id_lst[z].toString() +
                  "," +
                  inst_id_lst[z].toString() +
                  "," +
                  classid_lst[z].toString() +
                  "," +
                  sec_id_lst[z].toString() +
                  "," +
                  roll_no_lst[z].toString() +
                  "," +
                  batchid_lst[z].toString() +
                  "," +
                  subdiv_lst[z].toString() +
                  "," +
                  atttype_lst[z].toString() +
                  "," +
                  instname_lst[z].toString();
            }

            if (z > 0) {
              vals += "#" +
                  student_id_lst[z].toString() +
                  "," +
                  inst_id_lst[z].toString() +
                  "," +
                  classid_lst[z].toString() +
                  "," +
                  sec_id_lst[z].toString() +
                  "," +
                  roll_no_lst[z].toString() +
                  "," +
                  batchid_lst[z].toString() +
                  "," +
                  subdiv_lst[z].toString() +
                  "," +
                  atttype_lst[z].toString() +
                  "," +
                  instname_lst[z].toString();
            }
          }

          await updateToken(context);

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => StudentDashboard1()));
        }
      }
    }
  }

  // --- Fetch institute details (Now accumulates all results) ---
  Future<String> handleLoginGetInstituteNames() async {
    print("Came inside handle Institute k");
    // Clear previous results before fetching new ones
    instname_lst.clear();
    inst_expiry_lst.clear();
    inst_status_lst.clear();
    inst_adtp_lst.clear();
    custadvurl_lst.clear();

    for (int i = 0;
        Glb.inst_id_lst != null && i < Glb.inst_id_lst.length;
        i++) {
      String instid_for_det = Glb.inst_id_lst[i];
      String query =
          "select instname,expiry,status,ip1,adtp,custadurl from trueguide.pinsttbl where instid='$instid_for_det' and status='1'";
      print("query===================================== $query");

      response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
      print("response in handleLoginGetInstituteNames: $response");
      if (response.startsWith("ErrorCode#2")) {
        return "NODATA";
      }

      if (response.startsWith("record#")) {
        Map<String, List<String>> processedData = processRecords(response);

        instname_lst = processedData['X^1_1'] ?? [];
        inst_expiry_lst = processedData['X^2_2'] ?? [];
        inst_status_lst = processedData['X^3_3'] ?? [];
        ip1 = processedData['X^4_4']![0];
        inst_adtp_lst = processedData['X^5_5'] ?? [];
        custadvurl_lst = processedData['X^6_6'] ?? [];
      }
    }

    if (ip1 == "None" || ip1.toUpperCase() == "NA") {
      //sharedpref
    } else if (Glb.ips_fetched == false &&
        (ip1.toUpperCase() == "NA") == false &&
        (ip1 == "None") == false &&
        ip1.length > 0) {
      if (Glb.fileOp == true) {
        String tmp = ip1;
        List<String> split = tmp.split(',');

        if (split.length == 2) {
          ip1 = '${split[1]},${split[0]}';
        }

        if (split.length == 3) {
          ip1 = '${split[2]},${split[1]},${split[0]}';
        }

        List<String> ips = ip1.split(',');
        Glb.Hostnames = ips.toString();
        await socketService.updateHostFromHostnames();
      }
    }
    return "Success";
  }

  // --- Main login function ---
  Future<String> loginFuture(String loginController, String password) async {
    String query =
        "select usrid,usrname,password,devid,fbmsgdevid,fbmsgtkn,devid2,fbmsgdevid2,fbmsgtkn2,devid3,fbmsgdevid3,fbmsgtkn3,userphotolink from trueguide.tusertbl where mobno='$loginController' and status='1'";
    print("Query is :$query");

    response = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    print("response in loginFuture async (User validation): $response");

    serverResponse = response;

    if (response.startsWith("ErrorCode#2")) {
      return "NOREG";
    }
    if (response.startsWith("Err:")) {
      return "ERROR";
    }
    if (response.startsWith("record#")) {
      Map<String, List<String>> processedData = processRecords(response);

      // Store fetched user details into Glb
      Glb.userid = processedData['X^1_1']![0];
      Glb.student_name = processedData['X^2_2']![0];
      Glb.rcv_password = processedData['X^3_3']![0];
      Glb.devid = processedData['X^4_4']![0];
      Glb.fbmsgdevid = processedData['X^5_5']![0];
      Glb.fbmsgtkn = processedData['X^6_6']![0];
      Glb.batchid_lst = processedData['X^7_7'] ?? [0];
      Glb.ctype_lst = processedData['X^8_8'] ?? [0];
      Glb.year_lst = processedData['X^9_9'] ?? [0];
      Glb.subdiv_lst = processedData['X^10_10'] ?? [0];
      Glb.atttype_lst = processedData['X^11_11']! ?? [0];
      Glb.update_info_lst = processedData['X^12_12'] ?? [];
      Glb.dplink = processedData['X^13_13']![0];
    }

    if (Glb.rcv_password != password) {
      return "PASSWORD_ERROR";
    }

    String query1 =
        "select version,link from trueguide.tversionctrltbl where module='${Glb.Module_ID}' and role='${Glb.Role_id}'";
    print("2nd Query: $query1");

    String response2 =
        await socketService.sendMessage(Glb.ip, Glb.port, query1, 709);
    print("response in loginFuture async (Version control): $response2");

    // if (response2.startsWith("ErrorCode#2")) {
    //   return "REG";
    // }
    // if (response2.startsWith("Err:")) {
    //   return "ERROR";
    // }
    if (response2.startsWith("record#")) {
      Map<String, List<String>> processedData = processRecords(response2);
      Glb.app_version_in_db = processedData['X^1_1']![0];
      Glb.app_link = processedData['X^2_2']![0];

      print("App Version : ${Glb.app_version_in_db}");
      print("App Link: ${Glb.app_link}");
    }

    if (int.parse(Glb.userid) > 0) {
      String query3 =
          "select studid,tstudenttbl.instid,tstudenttbl.classid,secdesc,rollno,tstudenttbl.status,tstudenttbl.batchid,tstudenttbl.ctype,year,subdiv,atttype,updt from trueguide.tstudenttbl,trueguide.tinstclasstbl where usrid='${Glb.userid}' and tinstclasstbl.classid=tstudenttbl.classid and tstudenttbl.ctype='0' and tstudenttbl.instid=tinstclasstbl.instid and tstudenttbl.ctype=tinstclasstbl.ctype and tstudenttbl.batchid=tinstclasstbl.batchid and (status='1' or status='100')";
      print("Query3 is: $query3");

      String response3 =
          await socketService.sendMessage(Glb.ip, Glb.port, query3, 709);
      print("response3 (Student Info): $response3");

      if (response3.startsWith("ErrorCode#2")) {
        return "REG";
      }

      if (response3.startsWith("record#")) {
        Map<String, List<String>> processedData = processRecords(response3);

        Glb.student_id_lst = processedData['X^1_1'] ?? [];
        Glb.inst_id_lst = processedData['X^2_2'] ?? [0];
        Glb.classid_lst = processedData['X^3_3'] ?? [0];
        Glb.sec_id_lst = processedData['X^4_4'] ?? [0];
        Glb.roll_no_lst = processedData['X^5_5'] ?? [];
        Glb.Status_lst = processedData['X^6_6'] ?? [];
        Glb.batchid_lst = processedData['X^7_7'] ?? [];
        Glb.ctype_lst = processedData['X^8_8'] ?? [];
        Glb.year_lst = processedData['X^9_9'] ?? [];
        Glb.subdiv_lst = processedData['X^10_10'] ?? [];
        Glb.atttype_lst = processedData['X^11_11'] ?? [];
        Glb.update_info_lst = processedData['X^12_12'] ?? [];
      }

      if (Glb.inst_id_lst.isNotEmpty) {
        String instResponse = await handleLoginGetInstituteNames();
        if (instResponse != "Success") {
          print("Error Get Inst Names");
          return "INST_ERROR";
        }
      }

      Glb.main_stud_usrid_lst.add(Glb.userid);
      Glb.main_stud_usrname_lst.add(Glb.student_name);
      StudentLoginInfoObj? obj = null;

      if (studentLoginInfoMap != null) {
        obj = studentLoginInfoMap[Glb.userid];
      }

      if (obj == null) {
        obj = StudentLoginInfoObj();
      }

      obj.student_id_lst = Glb.student_id_lst;
      obj.inst_id_lst = Glb.inst_id_lst;
      obj.classid_lst = Glb.classid_lst;
      obj.sec_id_lst = Glb.sec_id_lst;
      obj.roll_no_lst = Glb.roll_no_lst;
      obj.Status_lst = Glb.Status_lst;
      obj.batchid_lst = Glb.batchid_lst;
      obj.ctype_lst = Glb.ctype_lst;
      obj.year_lst = Glb.year_lst;
      obj.subdiv_lst = Glb.subdiv_lst;
      obj.atttype_lst = Glb.atttype_lst;
      obj.instname_lst = instname_lst;
      obj.inst_expiry_lst = inst_expiry_lst;
      obj.inst_status_lst = inst_status_lst;
      obj.inst_adtp_lst = inst_adtp_lst;
      obj.update_info_lst = Glb.update_info_lst;
      obj.custadvyrl_lst = custadvurl_lst;

      studentLoginInfoMap[Glb.userid] = obj;

      String query4 =
          "select sbusrid,usrname from trueguide.tsiblingtbl,trueguide.tusertbl where tsiblingtbl.usrid='${Glb.userid}' and sbusrid=tusertbl.usrid and tusertbl.status='1'";
      String response4 =
          await socketService.sendMessage(Glb.ip, Glb.port, query4, 709);

      print("Query is : $query4");

      print("response4 (Sibling IDs): $response4");

      if (response4.startsWith("ErrorCode#2")) {
        // return "NODATA";
      }
      if (response4.startsWith("record#")) {
        Map<String, List<String>> siblingData = processRecords(response4);
        sbusrid_lst = siblingData['X^1_1'] ?? [];
        subusrname_lst = siblingData['X^2_2'] ?? [];
      }

      if (sbusrid_lst.isNotEmpty) {
        String cond = "";
        for (int z = 0; z < sbusrid_lst.length; z++) {
          if (z == 0) {
            cond += " (tusertbl.usrid='" + sbusrid_lst[z].toString() + "'";
          } else {
            cond += " or tusertbl.usrid='" + sbusrid_lst[z].toString() + "'";
          }
        }
        cond += ") and tusertbl.usrid=tstudenttbl.usrid";

        print(
            "==============================COND $cond========================");

        String query5 =
            "select studid,tstudenttbl.instid,tstudenttbl.classid,secdesc,rollno,tstudenttbl.status,tstudenttbl.batchid,tstudenttbl.ctype,year,subdiv,atttype,updt from trueguide.tstudenttbl,trueguide.tinstclasstbl where usrid IN ($cond) and tinstclasstbl.classid=tstudenttbl.classid and tstudenttbl.ctype='0' and tstudenttbl.instid=tinstclasstbl.instid and tstudenttbl.ctype=tinstclasstbl.ctype and tstudenttbl.batchid=tinstclasstbl.batchid and (status='1' or status='100')";

        String response5 =
            await socketService.sendMessage(Glb.ip, Glb.port, query5, 709);
        print("response5 (Sibling Details): $response5");
        if (response5.startsWith("ErrorCode#2")) {
          return "NODATA";
        }
        if (response5.startsWith("Err:")) {
          return "ERROR";
        }
        if (response5.startsWith("record#")) {
          Map<String, List<String>> processedData = processRecords(response5);
          List student_id_lst = processedData['X^1_1'] ?? [];
          List inst_id_lst = processedData['X^2_2'] ?? [];
          List classid_lst = processedData['X^3_3'] ?? [];
          List sec_id_lst = processedData['X^4_4'] ?? [];
          List roll_no_lst = processedData['X^5_5'] ?? [];
          List Status_lst = processedData['X^6_6'] ?? [];
          List batchid_lst = processedData['X^7_7'] ?? [];
          List ctype_lst = processedData['X^8_8'] ?? [];
          List year_lst = processedData['X^9_9'] ?? [];
          List subdiv_lst = processedData['X^10_10'] ?? [];
          List atttype_lst = processedData['X^11_11'] ?? [];
          List rec_usrid = processedData['X^12_12'] ?? [];
          List instname_lst = processedData['X^13_13'] ?? [];
          List inst_expiry_lst = processedData['X^14_14'] ?? [];
          List inst_status_lst = processedData['X^15_15'] ?? [];
          List inst_adtp_lst = processedData['X^16_16'] ?? [];
          List update_info_lst = processedData['X^17_17'] ?? [];
          List custadvurl_lst = processedData['X^18_18'] ?? [];

          print('student_id_lst: $student_id_lst');
          print('inst_id_lst: $inst_id_lst');
          print('classid_lst: $classid_lst');
          print('sec_id_lst: $sec_id_lst');
          print('roll_no_lst: $roll_no_lst');
          print('Status_lst: $Status_lst');
          print('batchid_lst: $batchid_lst');
          print('ctype_lst: $ctype_lst');
          print('year_lst: $year_lst');
          print('subdiv_lst: $subdiv_lst');
          print('atttype_lst: $atttype_lst');
          print('rec_usrid: $rec_usrid');
          print('instname_lst: $instname_lst');
          print('inst_expiry_lst: $inst_expiry_lst');
          print('inst_status_lst: $inst_status_lst');
          print('inst_adtp_lst: $inst_adtp_lst');
          print('update_info_lst: $update_info_lst');
          print('custadvurl_lst: $custadvurl_lst');

          for (int z = 0; sbusrid_lst != null && z < sbusrid_lst.length; z++) {
            String usrid_cur = sbusrid_lst[z].toString();
            String usrname_cur = subusrname_lst[z].toString();

            StudentLoginInfoObj? obj1 = studentLoginInfoMap[Glb.userid];

            if (obj1 == null) {
              obj1 = StudentLoginInfoObj();

              obj1.student_id_lst = [];
              obj1.inst_id_lst = [];
              obj1.classid_lst = [];
              obj1.sec_id_lst = [];
              obj1.roll_no_lst = [];
              obj1.Status_lst = [];
              obj1.batchid_lst = [];
              obj1.ctype_lst = [];
              obj1.year_lst = [];
              obj1.subdiv_lst = [];
              obj1.atttype_lst = [];
              obj1.instname_lst = [];
              obj1.inst_expiry_lst = [];
              obj1.inst_status_lst = [];
              obj1.inst_adtp_lst = [];
              obj1.update_info_lst = [];
              obj1.custadvyrl_lst = [];
            }

            for (int z1 = 0; z1 < rec_usrid.length; z1++) {
              String itr_usrid = rec_usrid[z1].toString();
              if (usrid_cur == itr_usrid) {
                obj1.student_id_lst.add(Glb.student_id_lst[z1].toString());
                obj1.inst_id_lst.add(Glb.inst_id_lst[z1].toString());
                obj1.classid_lst.add(Glb.classid_lst[z1].toString());
                obj1.sec_id_lst.add(Glb.sec_id_lst[z1].toString());
                obj1.roll_no_lst.add(Glb.roll_no_lst[z1].toString());
                obj1.Status_lst.add(Glb.Status_lst[z1].toString());
                obj1.batchid_lst.add(Glb.batchid_lst[z1].toString());
                obj1.ctype_lst.add(Glb.ctype_lst[z1].toString());
                obj1.year_lst.add(Glb.year_lst[z1].toString());
                obj1.subdiv_lst.add(Glb.subdiv_lst[z1].toString());
                obj1.atttype_lst.add(Glb.atttype_lst[z1].toString());
                obj1.instname_lst.add(instname_lst[z1].toString());
                obj1.inst_expiry_lst.add(inst_expiry_lst[z1].toString());
                obj1.inst_status_lst.add(inst_status_lst[z1].toString());
                obj1.inst_adtp_lst.add(inst_adtp_lst[z1].toString());
                obj1.update_info_lst.add(Glb.update_info_lst[z1].toString());
                obj1.custadvyrl_lst.add(custadvurl_lst[z1].toString());
              }
            }

            if (obj1.student_id_lst.length > 0) {
              Glb.main_stud_usrid_lst.add(usrid_cur);
              Glb.main_stud_usrname_lst.add(usrname_cur);
              studentLoginInfoMap[Glb.userid] = obj;
            }
          }
        }
      }

      String query6 =
          "select adid,adtp from trueguide.tadidtbl where role='student'";
      String response6 =
          await socketService.sendMessage(Glb.ip, Glb.port, query6, 709);

      print("response6 (Ads): $response6");
      if (response6.startsWith("ErrorCode#2#")) {
        print("No DATA");
      }

      if (response6.startsWith("record#")) {
        print("Enterd Here in this loo[p]");
        Map<String, List<String>> adData = processRecords(response6);
        adid_lst = adData['X^1_1'] ?? [];
        adtp_lst = adData['X^2_2'] ?? [];
      }
    }
    if (Glb.enable_devid == true) {
      print("Came Here");
      String ret = await do_work();
    }

    return "Inst_list";
  }

  Future<String> do_work() async {
    print("Enterd in Do work");
    String fdevid_cur = await getDeviceID();
    if (fdevid_cur == null || fdevid_cur.length == 0) {
      return "Inst_list";
    }
    Glb.devinf = "";
    if ((devid.toUpperCase() == "NA") == false) {
      String query = "update trueguide.tusertbl set devid='" +
          fdevid_cur +
          "',fbmsgdevid='NA',fbmsgtkn='NA' where usrid='" +
          Glb.userid +
          "'";
      print("Query: $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
      if (responce.startsWith("ErrorCode#8") ||
          responce.startsWith("ErrorCode#9")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#0")) {
        print("Successfully Updated to DB Unique ID");
      }

      Glb.devid = fdevid_cur;
      Glb.fbmsgdevid = "NA";
      Glb.fbmsgtkn = "NA";

      return "Inst_list";
    } else if ((Glb.devid.toUpperCase() == "NA") == false &&
        (Glb.devid.toUpperCase() == fdevid_cur) == false) {
      String query = "update trueguide.tusertbl set devid='" +
          fdevid_cur +
          "',fbmsgdevid='NA',fbmsgtkn='NA' where usrid='" +
          Glb.userid +
          "'";

      print("Query : $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
      if (responce.startsWith("ErrorCode#8") ||
          responce.startsWith("ErrorCode#9")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#0")) {
        print("Successfully Updated to DB Unique ID");
      }

      Glb.devid = fdevid_cur;
      Glb.fbmsgdevid = "NA";
      Glb.fbmsgtkn = "NA";
    } else if ((Glb.devid == fdevid_cur) == true) {
      Glb.devid = fdevid_cur;
      if ((Glb.fbmsgtkn.toUpperCase() == "NA") == false) {
        getUUID(context, Glb.fbmsgtkn);
      }
    }
    return "";
  }

  Future<void> getUUID(BuildContext context, String? oldToken) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      User? currentUser = auth.currentUser;
      if (currentUser == null) {
        debugPrint("User not logged in");
        return;
      }

      String? newToken = await FirebaseMessaging.instance.getToken();

      debugPrint("New Token === $newToken");

      if (newToken != null &&
          newToken.isNotEmpty &&
          oldToken != null &&
          oldToken.isNotEmpty) {
        if (oldToken.toLowerCase() != newToken.toLowerCase()) {
          debugPrint("token changed");

          String query = "update trueguide.tusertbl set fbmsgtkn='" +
              newToken +
              "' where usrid='" +
              Glb.userid +
              "' and devid='" +
              Glb.devid +
              "'";

          String responce =
              await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
          setState(() {
            serverResponse = responce;
          });
          if (responce.startsWith("ErrorCode#0")) {
            print("Successfull");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "FCM Token updated to DB: $newToken",
                  style: const TextStyle(fontSize: 12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint("Token didnt change");
        }
      }
    } catch (e) {
      debugPrint("getUUID error: $e");
    }
  }

  Future<void> updateToken(BuildContext context) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        newTokenStr = "NA";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Firebase Token Generation Failed")),
        );
      } else {
        newTokenStr = token;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "FCM Token updated to DB: $newTokenStr",
              style: const TextStyle(fontSize: 12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await AsyncTaskupdate_token();
        debugPrint("FCM Token: $newTokenStr");
      }
    } catch (e) {
      newTokenStr = "NA";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Firebase Token Generation Failed")),
      );
    }
  }

  Future<String> AsyncTaskupdate_token() async {
    String query = "update trueguide.tusertbl set fmctoken='" +
        newTokenStr +
        "' where usrid='" +
        Glb.userid +
        "'";
    print("Query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
    if (responce.startsWith("ErrorCode#8") ||
        responce.startsWith("ErrorCode#9")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#0")) {
      print("Successfully Updated to DB Unique ID");
    }

    return "";
  }

  static const platform = MethodChannel('device_id_channel');

  static Future<String> getDeviceID() async {
    try {
      final String id = await platform.invokeMethod('getDeviceUniqueId');
      print("DEVICE ID FROM KOTLIN: $id");
      return id;
    } catch (e) {
      print("Error getting device ID: $e");
      return "ERROR";
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.green,
                height: MediaQuery.of(context).padding.top,
              ),
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'STUDENT',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // --- Login UI ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/logo1.png',
                                height: 100,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Log into your account',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Login ID Field
                          TextFormField(
                            controller: _loginController,
                            decoration: const InputDecoration(
                              labelText: 'Login ID:',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              if (_isPasswordSameAsLogin) {
                                _passwordController.text = value;
                              }
                            },
                          ),
                          const SizedBox(height: 8),

                          // Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _isPasswordSameAsLogin,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPasswordSameAsLogin = value ?? false;
                                    if (_isPasswordSameAsLogin) {
                                      _passwordController.text =
                                          _loginController.text;
                                      _obscurePassword = true;
                                    } else {
                                      _passwordController.clear();
                                    }
                                  });
                                },
                                activeColor: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  'Keep Password Same As Login ID',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password:',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(255, 121, 68, 1),
                                  Color.fromARGB(255, 245, 189, 58)
                                ],
                              ),
                            ),
                            child: TextButton(
                              onPressed: AfterDoInBackground,
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // QR Note
                          const Column(
                            children: [
                              Icon(Icons.qr_code_scanner,
                                  size: 60, color: Colors.black),
                              SizedBox(height: 10),
                              Text(
                                'Click scan icon to register if guided by institution,\notherwise enter Login-ID and Password',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  onLoad() async {
    LoginID =
        await SharedPreferenceService.getString(Sharedprekey.LoginIdKey) ??
            'NA';
    Passwd = await SharedPreferenceService.getString(Sharedprekey.Paasswdkey) ??
        'NA';

    print(
        "Login Id Password is=======  $LoginID  and Paassword is========= $Passwd");

    if (LoginID != 'NA' && Passwd != 'NA') {
      print("Auto login triggered");

      // Auto-fill fields
      _loginController.text = LoginID!;
      _passwordController.text = Passwd!;

      // Wait for UI load
      Future.delayed(Duration(milliseconds: 300), () {
        AfterDoInBackground(); // Trigger full login logic
      });
    }
  }

  // void
}
