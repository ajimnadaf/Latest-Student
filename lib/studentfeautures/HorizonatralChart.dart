import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/HomeScreen.dart';

List subname_lst = [],
    obtained_marks_lst = [],
    examname_lst = [],
    totmarks_lst = [],
    subid_lst = [],
    subid_lst_new = [],
    absent_cls_lst = [],
    absent_sub_lst = [],
    present_sub_lst = [],
    present_cls_lst = [],
    tot_cls_sub_lst = [],
    tot_cls_lst = [],
    present_cls_sub_lst = [];

List<BarChartGroupData> barChartGroups = [];

SocketService socketService = SocketService();

class Horizonatralchart extends StatefulWidget {
  const Horizonatralchart({super.key});

  @override
  State<Horizonatralchart> createState() => _HorizonatralchartState();
}

class _HorizonatralchartState extends State<Horizonatralchart> {
  @override
  void initState() {
    super.initState();
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

  void show_exam_marks_attendence_popup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        List<Map<String, String>> aList = [];
        Map<String, String>? hm;

        String descText;

        if (Glb.subwise_att == true) {
          descText = " AVG.  ATTENDANCE % -ALL SUBJECT";
        } else {
          descText = "AVG. % ALL SUBJECTS IN ALL EXAMS";
        }

        // ===== SAME LOGIC AS JAVA =====
        if (Glb.main_feature == "attd_perf") {
          for (int i = 0;
              tot_cls_sub_lst != null && i < tot_cls_sub_lst.length;
              i++) {
            String subname = tot_cls_sub_lst[i].toString();

            double t = double.tryParse(tot_cls_lst[i].toString()) ?? 0;
            double o = 0;

            if (present_cls_sub_lst != null) {
              int pind = present_cls_sub_lst.indexOf(subname);
              if (pind != -1) {
                o = double.tryParse(present_cls_lst[pind].toString()) ?? 0;
              }
            }

            double p = t == 0 ? 0 : (o / t) * 100;

            hm = {
              "Marks":
                  "$subname\nTotal Classes:$t\nPRESENT:$o\n${p.toStringAsFixed(1)}%"
            };
            aList.add(hm);
          }
        } else {
          for (int i = 0; subid_lst != null && i < subid_lst.length; i++) {
            String subid_cur = subid_lst[i].toString();

            double o = double.tryParse(obtained_marks_lst[i].toString()) ?? 0;

            double t = 0;
            String subname = "";

            if (Glb.main_feature == "onlineexam") {
              int subind = subid_lst_new.indexOf(subid_cur);
              subname = subname_lst[subind].toString();
              t = double.tryParse(totmarks_lst[subind].toString()) ?? 0;
            } else {
              t = double.tryParse(totmarks_lst[i].toString()) ?? 0;
              subname = subname_lst[i].toString();
            }

            double p = t == 0 ? 0 : (o / t) * 100;

            hm = {"Marks": "$subname\n${p.toStringAsFixed(1)}%"};
            aList.add(hm);
          }
        }

        // ===== UI SAME AS POPUP =====
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.7, // ✅ limit height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  descText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // 👇 THIS FIXES OVERFLOW
                Expanded(
                  child: ListView.builder(
                    itemCount: aList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          aList[index]["Marks"] ?? "",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> AsyncTaskPreload() async {
    if (Glb.main_feature.toLowerCase() == "onlineexam" ||
        Glb.main_feature.toLowerCase() == "assessments") {
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
        //return "NODATA";
      }
      if (responce.startsWith("record")) {
        Map<String, List<String>> data = processRecords(responce);
        String cnts = data['X^1_1_']![0];

        print("cnts: $cnts");
      }

      if (cnts.toUpperCase() == "1") {
        return "NOTALLOWD";
      }
    }

    if (Glb.main_feature.toLowerCase() == "onlineexam" ||
        Glb.main_feature.toLowerCase() == "assessments") {
      String query = "";
      if (Glb.main_feature.toLowerCase() == "onlineexam") {
        query = "select sum(marks),texamtbl.subid from trueguide.onlineexamanstbl,trueguide.texamtbl where texamtbl.examid=onlineexamanstbl.examid and studid='" +
            Glb.student_id +
            "'  and texamtbl.online='1'  group by texamtbl.subid order by subid";
      }

      if (Glb.main_feature.toLowerCase() == "assessments") {
        query = "select sum(marks),texamtbl.subid from trueguide.onlineexamanstbl,trueguide.texamtbl where texamtbl.examid=onlineexamanstbl.examid and studid='" +
            Glb.student_id +
            "'  and texamtbl.online='2'  group by texamtbl.subid order by subid";
      }

      print("Query: $query");

      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (responce.startsWith("Err:")) {
        return "ERROR";
      }

      if (responce.startsWith("ErrorCode#2")) {
        return "NODATA";
      }

      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);

        totmarks_lst = data['X^1_1'] ?? [];
        subid_lst_new = data['X^2_2'] ?? [];
        subname_lst = data['X^3_3'] ?? [];

        print("totmarks_lst: $totmarks_lst");
        print("subid_lst_new: $subid_lst_new");
        print("subname_lst: $subname_lst");
      }
    }

    if (Glb.main_feature.toLowerCase() == "exm") {
      String query = "";
      query = "select sum(marksobt),texamtbl.subid,sum(tstudmarkstbl.totmarks),psubtbl.subname from trueguide.tstudmarkstbl,trueguide.texamtbl,trueguide.psubtbl where texamtbl.examid=tstudmarkstbl.examid and studid='" +
          Glb.student_id +
          "'  and texamtbl.online='-1' and texamtbl.subid=psubtbl.subid group by texamtbl.subid,psubtbl.subname order by subid";

      print("Query: $query");
      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (responce.startsWith("Err:")) {
        return "ERROR";
      }

      if (responce.startsWith("ErrorCode#2")) {
        return "NODATA";
      }

      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);

        obtained_marks_lst = data['X^1_1'] ?? [];
        subid_lst = data['X^2_2'] ?? [];
        totmarks_lst = data['X^3_3'] ?? [];
        subname_lst = data['X^4_4'] ?? [];

        print("obtained_marks_lst: $obtained_marks_lst");
        print("subid_lst: $subid_lst");
        print("totmarks_lst: $totmarks_lst");
        print("subname_lst: $subname_lst");
      }
    }

    if (Glb.main_feature.toLowerCase() == "attd_perf") {
      String query = "";
      print("In Class Wise Attendance");
      if (Glb.online_att == true) {
        print("In Class Wise Attendance Online");

        query =
            "select count(*),subname from trueguide.tliveconflinktbl,trueguide.psubtbl where  instid='" +
                Glb.inst_id +
                "' and tliveconflinktbl.classid='" +
                Glb.classid +
                "' and secdesc='" +
                Glb.sec_id +
                "'  and sbdate>='" +
                Glb.att_from_date +
                "' and sbdate<='" +
                Glb.att_to_date +
                "' and tliveconflinktbl.subid=psubtbl.subid group by subname";

        print("Query: $query");

        String responce1 =
            await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

        if (responce1.startsWith("Err:")) {
          return "ERROR";
        }

        if (responce1.startsWith("ErrorCode#2")) {
          return "NODATA";
        }

        if (responce1.startsWith("record#")) {
          Map<String, List<String>> data = processRecords(responce1);

          tot_cls_lst = data['X^1_1'] ?? [];
          tot_cls_sub_lst = data['X^2_2'] ?? [];

          query = "select count(*),subname from trueguide.tliveconfstudattendtbl,trueguide.psubtbl where studid='" +
              Glb.student_id +
              "'and sbdate>='" +
              Glb.att_from_date +
              "' and sbdate<='" +
              Glb.att_to_date +
              "' and tliveconfstudattendtbl.subid=psubtbl.subid group by subname";

          print("Query: $query");

          String responce =
              await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

          if (responce.startsWith("Err:")) {
            return "ERROR";
          }

          if (responce.startsWith("ErrorCode#2")) {
            return "NODATA";
          }

          if (responce.startsWith("record#")) {
            Map<String, List<String>> data = processRecords(responce);

            present_cls_lst = data['X^1_1'] ?? [];
            present_cls_sub_lst = data['X^2_2'] ?? [];

            print("present_cls_lst: $present_cls_lst");
            print("present_cls_sub_lst: $present_cls_sub_lst");
          }
        }
      } else {
        print("In Class Wise Attendance Offline");
        query =
            "select count(*),subname from trueguide.tattendencetbl,trueguide.psubtbl where studid='" +
                Glb.student_id +
                "' and status='1' and attdate>='" +
                Glb.att_from_date +
                "' and attdate<='" +
                Glb.att_to_date +
                "' and tattendencetbl.subid=psubtbl.subid group by subname";
        print("Query: $query");

        String responce2 =
            await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

        if (responce2.startsWith("Err:")) {
          return "ERROR";
        }

        if (responce2.startsWith("ErrorCode#2")) {
          return "NODATA";
        }

        if (responce2.startsWith("record#")) {
          Map<String, List<String>> data = processRecords(responce2);

          present_cls_lst = data['X^1_1'] ?? [];
          present_cls_sub_lst = data['X^2_2'] ?? [];

          print("present_cls_lst: $present_cls_lst");
          print("present_cls_sub_lst: $present_cls_sub_lst");

          query =
              "select count(*),subname from trueguide.tattendencetbl,trueguide.psubtbl where studid='" +
                  Glb.student_id +
                  "' and status='0' and attdate>='" +
                  Glb.att_from_date +
                  "' and attdate<='" +
                  Glb.att_to_date +
                  "' and tattendencetbl.subid=psubtbl.subid group by subname";

          print("Query: $query");

          String responce =
              await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

          if (responce.startsWith("Err:")) {
            return "ERROR";
          }

          if (responce.startsWith("ErrorCode#2")) {
            return "NODATA";
          }

          if (responce.startsWith("record#")) {
            Map<String, List<String>> data = processRecords(responce);

            absent_cls_lst = data['X^1_1'] ?? [];
            absent_sub_lst = data['X^2_2'] ?? [];

            print("absent_cls_lst: $absent_cls_lst");
            print("absent_sub_lst: $absent_sub_lst");
          }

          tot_cls_lst = [];
          tot_cls_sub_lst = [];

          for (int x = 0;
              Glb.sub_name != null && x < Glb.sub_name.length;
              x++) {
            String sub_name = Glb.sub_name[x].toString();

            int pind = present_cls_sub_lst.indexOf(sub_name);

            int present_count = 0;
            int abscent_count = 0;

            if (pind == -1) {
              present_count = 0;
            } else {
              present_count =
                  int.tryParse(present_cls_lst[pind].toString()) ?? 0;
            }

            int aind = absent_sub_lst.indexOf(sub_name);

            if (aind == -1) {
              abscent_count = 0;
            } else {
              abscent_count =
                  int.tryParse(absent_cls_lst[aind].toString()) ?? 0;
            }

            tot_cls_lst.add(present_count + abscent_count);
            tot_cls_sub_lst.add(sub_name);
          }

          print("tot_cls_lst====$tot_cls_lst");
          print("tot_cls_sub_lst===$tot_cls_sub_lst");
        }
      }
    }
    return "SUCCESS";
  }

  void onpost() async {
    String check = await AsyncTaskPreload();

    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection Lost From Server Pls Try Again"),
        ),
      );
      return;
    }

    if (check.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NODATA")),
      );
      return;
    }

    if (check == "NOTALLOWD") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sorry you are not allowed to view marks"),
        ),
      );
      return;
    }

    // ✅ SUCCESS FLOW (THIS WAS NEVER EXECUTED BEFORE)
    if (check.toUpperCase() == "SUCCESS") {
      if (Glb.main_feature == "attd_perf") {
        int count = tot_cls_sub_lst.length;
        setData(count, 0);
      } else {
        int count = obtained_marks_lst.length;
        setData(count, 0);
      }
    }
  }

  void setData(int count, double range) {
    double barWidth = 9;
    double spaceForBar = 10; // kept (not used now, but not removed)

    List<BarChartGroupData> values = [];

    if (Glb.main_feature == "attd_perf") {
      for (int i = 0; i < count; i++) {
        String subname = tot_cls_sub_lst[i].toString();

        double t = double.parse(tot_cls_lst[i].toString());
        double o = 0;

        if (present_cls_sub_lst != null) {
          int pind = present_cls_sub_lst.indexOf(subname);
          if (pind != -1) {
            o = double.parse(present_cls_lst[pind].toString());
          }
        }

        double p = t == 0 ? 0 : (o / t) * 100;

        values.add(
          BarChartGroupData(
            x: i, // ✅ FIXED
            barRods: [
              BarChartRodData(
                toY: p,
                width: barWidth,
                color: Colors.black,
                borderRadius: BorderRadius.circular(0),
              ),
            ],
          ),
        );
      }
    } else {
      for (int i = 0; i < count; i++) {
        String subid_cur = subid_lst[i].toString();

        double o = double.parse(obtained_marks_lst[i].toString());
        double t = 0;

        if (Glb.main_feature == "onlineexam") {
          int subind = subid_lst_new.indexOf(subid_cur);
          t = double.parse(totmarks_lst[subind].toString());
        } else {
          t = double.parse(totmarks_lst[i].toString());
        }

        double p = t == 0 ? 0 : (o / t) * 100;

        values.add(
          BarChartGroupData(
            x: i, // ✅ FIXED
            barRods: [
              BarChartRodData(
                toY: p,
                width: barWidth,
                color: Colors.black,
                borderRadius: BorderRadius.circular(0),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      barChartGroups = values;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                "AVG. % ALL SUBJECTS IN ALL EXAMS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: show_exam_marks_attendence_popup,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF7A00),
                        Color(0xFFFFE0B2),
                      ],
                    ),
                  ),
                  child: const Text(
                    "AVG %",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: RotatedBox(
                  quarterTurns: 1, // Rotates 90 degrees clockwise
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      minY: 0,
                      alignment: BarChartAlignment.spaceBetween,
                      barGroups: barChartGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String label = "";
                            if (Glb.main_feature == "attd_perf" &&
                                groupIndex < tot_cls_sub_lst.length) {
                              label = tot_cls_sub_lst[groupIndex].toString();
                            } else if (groupIndex < subname_lst.length) {
                              label = subname_lst[groupIndex].toString();
                            }
                            return BarTooltipItem(
                              "$label\n${rod.toY.toStringAsFixed(1)}%",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                "${value.toInt()}%",
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              String label = "";
                              if (Glb.main_feature == "attd_perf" &&
                                  index < tot_cls_sub_lst.length) {
                                label = tot_cls_sub_lst[index].toString();
                              } else if (index < subname_lst.length) {
                                label = subname_lst[index].toString();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    color: const Color(0xFF9BEAFF),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Subject Percentage",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
