import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/studentfeautures/HomeWorkPics.dart';

bool isLoading = false;
String hwdt = "";
String hwid_cur = "";

List hwdesc_lst = [],
    teacherid_lst = [],
    hw_fname_lst = [],
    stud_hwid_lst = [],
    hwid_lst = [],
    count_lst = [],
    subid_lst = [],
    subname_lst = [],
    teachername_lst = [];

List aList = [];

SocketService socketService = SocketService();

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  late String todayDate;

  @override
  void initState() {
    super.initState();
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Glb.notification_date = todayDate;
    onpost();
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

  Future<String> Async_get_distinct_dates() async {
    String query =
        "select distinct(hwdt) from trueguide.thwtbl where instid='" +
            Glb.inst_id +
            "' and classid='" +
            Glb.classid +
            "'  and secdesc='" +
            Glb.sec_id +
            "' and batchid='" +
            Glb.active_batchid +
            "' order by hwdt desc";
    print("query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("ErrorCode#2")) {
      print("Error");
    }
    if (responce.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pls Check your connection and try again")));
      return "ERROR";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      Glb.distinct_date = data['X^1_1'] ?? [];
      print("Distinct dates: ${Glb.distinct_date}");
    }
    return "SUCCESS";
  }

  void onpost() async {
    setState(() {
      isLoading = true;
    });
    String result = await Async_get_distinct_dates();
    if (result == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Busy pls Try After some Time")));
    }
    if (result == "SUCCESS") {
      if (Glb.distinct_date != null) {
        int dt_ind = Glb.distinct_date.indexOf(Glb.notification_date);
        if (dt_ind == -1) {
          Glb.distinct_date.join(Glb.notification_date);
        }
      } else {
        Glb.distinct_date = [];
        Glb.distinct_date.join(Glb.notification_date);
      }
      Glb.notification_date = Glb.distinct_date[Glb.dt_ind].toString();

      print("Notification date ${Glb.notification_date}");
      hwdt = Glb.notification_date;
      setState(() {
        isLoading = false;
      });

      if (isLoading) Glb.showLoadingIndicator(context);

      onPostExecute();
    }
  }

  Future<String> Async_get_all_home_works() async {
    String query =
        "select hwdesc,fname,hwid,thwtbl.subid,subname,usrname,teacherid from trueguide.thwtbl,trueguide.psubtbl,trueguide.tusertbl where thwtbl.usrid=tusertbl.usrid and instid='" +
            Glb.inst_id +
            "' and thwtbl.classid='" +
            Glb.classid +
            "'  and secdesc='" +
            Glb.sec_id +
            "' and hwdt='" +
            Glb.notification_date +
            "' and  thwtbl.subid=psubtbl.subid";
    print("query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("ErrorCode#2")) {
      print("Home Work didn't given");
      return "NODATA";
    }
    if (responce.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pls Check your connection and try again")));
      return "ERROR";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      hwdesc_lst = data['X^1_1'] ?? [];
      hw_fname_lst = data['X^2_2'] ?? [];
      hwid_lst = data['X^3_3'] ?? [];
      subid_lst = data['X^4_4'] ?? [];
      subname_lst = data['X^5_5'] ?? [];
      teachername_lst = data['X^6_6'] ?? [];
      teacherid_lst = data['X^7_7'] ?? [];
    }

    query =
        "select tstudhwtbl.hwid,count(shwid) from trueguide.thwtbl,trueguide.tstudhwtbl where thwtbl.instid='" +
            Glb.inst_id +
            "' and tstudhwtbl.studid='" +
            Glb.student_id +
            "'   and thwtbl.hwdt='" +
            Glb.notification_date +
            "'   and thwtbl.hwid=tstudhwtbl.hwid group by tstudhwtbl.hwid";
    print("query: $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("ErrorCode#2")) {
      print("Home Work didn't given");
    }
    if (responce.startsWith("Err:")) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pls Check your connection and try again")));
      return "ERROR";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      stud_hwid_lst = data['X^1_1'] ?? [];
      count_lst = data['X^2_2'] ?? [];
    }

    return "SUCCESS";
  }

  void onPostExecute() async {
    setState(() {
      isLoading = true;
    });
    String check = await Async_get_all_home_works();

    if (check.toUpperCase() == "NODATA") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Home Work Not found")));
      return;
    }
    if (check.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Connection Lost. Try Again")));
    }
    if (check.toUpperCase() == "SUCCESS") {
      aList.clear();
      for (int i = 0; i < hwid_lst.length; i++) {
        String Click_here = "";
        String count = "";

        hwid_cur = hwid_lst[i].toString();

        if (stud_hwid_lst != null) {
          int ind = stud_hwid_lst.indexOf(hwid_cur);

          if (ind == -1) {
            count = "-";
            Click_here = "CLICK HERE TO MARK HOME WORK AS COMPLETED";
          } else {
            count = "COMPLETED";
            Click_here = "";
          }
        } else {
          count = "0";
        }

        Map<String, String> hm = {};

        hm["first"] = "\"${clear_input_txt(hwdesc_lst[i].toString())}\""
            "\nSUBJECT: ${subname_lst[i]}"
            "\nTEACHER: ${teachername_lst[i]}"
            "\nHOME STATUS: $count"
            "\n$Click_here";

        aList.add(hm);

        // Updating Glb values
        Glb.hwid_cur = hwid_cur;
        Glb.hw_fname = hw_fname_lst.toString();
        Glb.hw_desc = hwdesc_lst.toString();
        Glb.hw_subid = subid_lst.toString();
        Glb.hw_teacherid_cur = teacherid_lst.toString();
      }
      setState(() {
        isLoading = false;
      });
      // Refresh UI
    }
    if (isLoading) Glb.showLoadingIndicator(context);
  }

  String clear_input_txt(String txt) {
    txt = txt.replaceAll("-dot-", ".");
    txt = txt.replaceAll("-underscore-", "_");
    txt = txt.replaceAll("-amp-", "&");
    txt = txt.replaceAll("-at-", "@");
    txt = txt.replaceAll("-hash-", "#");
    txt = txt.replaceAll("-question-", "?");
    txt = txt.replaceAll("-apos-", "'");
    txt = txt.replaceAll("-dollar-", "\$");
    txt = txt.replaceAll("-equals-", "=");
    txt = txt.replaceAll("-plus-", "+");
    txt = txt.replaceAll("recrd", "record");
    return txt;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topBarHeight = 80 + 14 + 14; // date bar + padding + title approx

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= TOP TITLE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Text(
                "Home-Work",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ================= ORANGE DATE BAR =================
            InkWell(
              onTap: () {
                _showDatePopup(context);
              },
              child: Container(
                height: 80,
                width: double.infinity,
                color: const Color(0xFFFFB300),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 42, color: Colors.black),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayDate,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Click here to check past HW",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= DYNAMIC CARD CONTAINER =================
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: aList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pencil icon only for dynamic card
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 28, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            // Homework text
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Glb.hwid_cur = hwid_cur;
                                  Glb.hw_fname = hw_fname_lst.toString();
                                  Glb.hw_desc = hwdesc_lst.toString();
                                  Glb.hw_subid = subid_lst.toString();
                                  Glb.hw_teacherid_cur =
                                      teacherid_lst.toString();

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeworkPicsScreen()));
                                },
                                child: Expanded(
                                  child: Text(
                                    aList[index]["first"] ?? "",
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePopup(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Select Homework Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: Glb.distinct_date.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.date_range),
                      title: Text(Glb.distinct_date[index]),
                      onTap: () {
                        Glb.notification_date = Glb.distinct_date[index];
                        Navigator.pop(context);
                        setState(() {
                          isLoading = false;
                        });
                        onPostExecute();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (isLoading) Glb.showLoadingIndicator(context);
  }

  
}
