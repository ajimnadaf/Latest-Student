import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/login.dart';
import 'package:student_app/Services/shared_preffrences.dart';
//import 'package:tg_staffapp1/Dashboard/Networking_IO.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
//import 'package:tg_staffapp1/ManagementDarts/StaffClassWiseReport.dart';
import 'package:student_app/Services/SharedPreKey.dart';
import 'package:student_app/Services/shared_preffrences.dart';
//..import 'package:student_app/login/login%20-%20Copy%20(2).dart';
import 'package:student_app/loginPage/splash_screen.dart';

String ip = "";
String instid = "";
String userid = "", status = "", Student_name = "";

class InstitutionLoginScreen extends StatefulWidget {
  const InstitutionLoginScreen({Key? key}) : super(key: key);

  @override
  State<InstitutionLoginScreen> createState() => _InstitutionLoginScreenState();
}

class _InstitutionLoginScreenState extends State<InstitutionLoginScreen> {
  final SharedPreferenceService pref = SharedPreferenceService();

  final SocketService socketService = SocketService();
  final TextEditingController _institutionIdController =
      TextEditingController();

  void delete_conf() async {
    await pref.removeData(Sharedprekey.LoginIdKey);
    await pref.removeData(Sharedprekey.Paasswdkey);
    //await pref.removeData(Sharedprekey.LoginFuture);
    await pref.removeData(Sharedprekey.HostIDkey);
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

  Future<void> asyncGetIPbyInstid(BuildContext context, String instid) async {
    // ===== onPreExecute =====
    showLoading(context, "Fetching data, please wait...");

    String check = "";

    try {
      Glb.restart = false;

      // ===== doInBackground =====
      check = await insert_ip_by_instid(instid);
    } catch (e) {
      check = "Error";
    }

    // ===== onPostExecute =====
    hideLoading(context);

    if (check.toUpperCase() == "ERROR") {
      delete_conf();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ErrorCode: 101")),
      );
    } else if (check.toUpperCase() == "NODATA") {
      //  deleteConf();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter Institution ID provided by Class Teacher",
          ),
        ),
      );
    } else if (check.toUpperCase() == "LEAVE") {
      delete_conf();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are not registered in this Institution ID"),
        ),
      );
    } else if (check.toUpperCase() == "RESTART" && Glb.restart == true) {
      // disconnect & restart
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SplashScreen()), (route) => false);

      // Full app restart (Flutter-safe)
      Phoenix.rebirth(context);
    } else if (check.toUpperCase() == "LOGIN") {
      Glb.dont_disconnect = true;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void restart1(BuildContext context, int delay) {
    Glb.dont_disconnect = true;

    Future.delayed(Duration(milliseconds: delay), () {
      Phoenix.rebirth(context);
    });
  }

  Future<String> insert_ip_by_instid(String instid) async {
    instid = _institutionIdController.text;
    String query = "select ip1 from trueguide.pinsttbl where instid='" +
        instid +
        "' and status='1'";

    print('query: $query');
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      print(" Internet Error ");
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("NODAT");
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> proccessedData = processRecords(responce);
      ip = proccessedData['X^1_1']![0];
      print("Ip Is : $ip");
    }
    if (ip == "None" || ip.toUpperCase() == "NA") {
      return "LEAVE";
    }
    if (Glb.ips_fetched == false) {
      if (Glb.fileOp == true) {
        String tmp = ip;
        List<String> split = tmp.split(',');

        if (split.length == 2) {
          ip = '${split[1]},${split[0]}';
        }

        if (split.length == 3) {
          ip = '${split[2]},${split[1]},${split[0]}';
        }

        List<String> ips = ip.split(',');
        Glb.Hostnames = ips.toString();

        String query =
            "select usrid,status,usrname from trueguide.tusertbl where mobno='" +
                Glb.mobno +
                "' and password='" +
                Glb.cnfrmpass +
                "'";

        print('query: $query');
        String responce =
            await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

        if (responce.startsWith("Err:")) {
          print(" Internet Error ");
          return "ERROR";
        }
        if (responce.startsWith("ErrorCode#2")) {
          print("NODATA");
          return "LOGIN";
        }
        if (responce.startsWith("record#")) {
          Map<String, List<String>> proccessedData = processRecords(responce);
          userid = proccessedData['X^1_1']![0];
          status = proccessedData['X^2_2']![0];
          Student_name = proccessedData['X^3_3']![0];
          print("USERID: IS: $userid");

          if (Glb.fileOp == true) {
            await pref.saveString(Sharedprekey.LoginIdKey, Glb.mobno);
            await pref.saveString(Sharedprekey.Paasswdkey, Glb.cnfrmpass);
            await pref.saveString(
                Sharedprekey.HostIDkey, Glb.Hostnames.toString());
          }
          await socketService.updateHostFromHostnames();
        }
        Glb.restart = true;

        return "RESTART";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                /// 🏛 Institution Icon
                const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: Colors.black,
                ),

                const SizedBox(height: 20),

                /// ℹ️ Note Text
                const Text(
                  "Note: Please enter your Institution Id to Login.\n"
                  "If you don't know please contact Admin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                /// 📝 Institution ID Label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Institution-ID:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔤 TextField
                TextField(
                  controller: _institutionIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔵 Submit Button
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // TODO: Handle submit

                      String id = _institutionIdController.text.trim();
                      if (id.length == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Pls Enter the Institute ID.")));
                        return;
                      } else {
                        instid = _institutionIdController.text;
                        asyncGetIPbyInstid(context, instid);
                      }
                    },
                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔴 Red Dot Indicator
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
