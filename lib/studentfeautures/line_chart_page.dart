import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

SocketService socketService = SocketService();

List<String> subname_lst = [];
List<String> obtained_marks_lst = [];
List<String> examname_lst = [];
List<String> totmarks_lst = [];
List<String> subid_lst = [];
List<String> subid_lst_new = [];

List<LineChartBarData> lineBarsData = [];

class LineChartPage extends StatefulWidget {
  const LineChartPage({super.key});

  @override
  State<LineChartPage> createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    String result = await onpost();
    if (result.toUpperCase() == "SUCCESS") {
      setData(obtained_marks_lst.length);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  Future<String> onpost() async {
    String check = await AsyncTaskPreload();

    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Lost From Server Pls Try Again")));
      return "NODATA";
    }

    if (check.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NODATA")));
      return "NODATA";
    }

    if (check == "NotAllowed") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sorry you are not allowed to view marks")));
      return "ERROR";
    }

    if (check.toUpperCase() == "SUCCESS") {
      if (obtained_marks_lst != null) {
        int count = obtained_marks_lst.length;
      }
    }

    return "SUCCESS";
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

  Future<String> AsyncTaskPreload() async {
    try {
      String query =
          "select count(*) from trueguide.tstudentmarksviewtbl where instid='${Glb.inst_id}'";

      String responce =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (responce.startsWith("Err:")) return "ERROR";
      if (responce.startsWith("ErrorCode#2")) return "NODATA";

      if (responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(responce);
        String cnts = data['X^1_1']![0];
        print("cnts: $cnts");
        if (cnts.toUpperCase() == "1") return "NotAllowed";
      }

      // Fetch marks based on feature
      String marksQuery = "";
      if (Glb.main_feature.toLowerCase() == "onlineexam" ||
          Glb.main_feature.toLowerCase() == "assessments") {
        String onlineVal =
            Glb.main_feature.toLowerCase() == "onlineexam" ? "1" : "2";
        marksQuery =
            "select sum(marks), texamtbl.examname, texamtbl.totmarks from trueguide.onlineexamanstbl, trueguide.texamtbl "
            "where texamtbl.examid = onlineexamanstbl.examid and studid='${Glb.student_id}' "
            "and texamtbl.subid='${Glb.sub_id_cur}' and texamtbl.online='$onlineVal' "
            "group by texamtbl.examname, texamtbl.totmarks";
      } else if (Glb.main_feature.toLowerCase() == "exm") {
        marksQuery =
            "select sum(marksobt), sum(tstudmarkstbl.totmarks), psubtbl.subname, texamtbl.examname "
            "from trueguide.tstudmarkstbl, trueguide.texamtbl, trueguide.psubtbl "
            "where texamtbl.examid = tstudmarkstbl.examid and studid='${Glb.student_id}' "
            "and texamtbl.online='-1' and texamtbl.subid = psubtbl.subid "
            "and psubtbl.subid='${Glb.sub_id_cur}' "
            "group by texamtbl.examid, psubtbl.subname, texamtbl.examname "
            "order by texamtbl.examid";
      }

      if (marksQuery.isEmpty) return "NODATA";

      String marksRes =
          await socketService.sendMessage(Glb.ip, Glb.port, marksQuery, 709);

      if (marksRes.startsWith("Err:")) return "ERROR";
      if (marksRes.startsWith("ErrorCode#2")) return "NODATA";

      if (marksRes.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(marksRes);
        obtained_marks_lst = data['X^1_1'] ?? [];
        totmarks_lst = data['X^2_2'] ?? [];
        examname_lst = data['X^3_3'] ?? [];
        subname_lst = data['X^4_4'] ?? [];

        print("obtained_marks_lst: $obtained_marks_lst");
        print("examname_lst: $examname_lst");
        print("totmarks_lst: $totmarks_lst");
        print("subname_lst: $subname_lst"); // in case EXM feature
      }

      return "SUCCESS";
    } catch (e) {
      return "ERROR: $e";
    }
  }

  void setData(int count) {
    List<FlSpot> values = [];
    for (int i = 0; i < count; i++) {
      double o = double.tryParse(obtained_marks_lst[i]) ?? 0;
      double t = double.tryParse(totmarks_lst[i]) ?? 100;
      double p = (o / t) * 100;
      values.add(FlSpot(i.toDouble(), p));
    }

    setState(() {
      lineBarsData = [
        LineChartBarData(
          spots: values,
          isCurved: false,
          color: Colors.black,
          barWidth: 2,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.red.withOpacity(0.4), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ];
    });
  }

  void show_exam_marks_popup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            // 🔑 Limit dialog height
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "EXAM MARKS (${Glb.sub_name_cur})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // 🔑 Make only the list scrollable
                Expanded(
                  child: ListView.builder(
                    itemCount: subname_lst.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${subname_lst[index]}\n"
                          "Total Marks: ${totmarks_lst[index]}\n"
                          "Obtained: ${obtained_marks_lst[index]}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EXAM PERFORMANCE-(${Glb.sub_name_cur})"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // VIEW MARKS button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.orange,
              ),
              onPressed: show_exam_marks_popup,
              child: const Text(
                "VIEW MARKS",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Chart
            Expanded(
              child: lineBarsData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        minX: 0,
                        maxX: lineBarsData[0].spots.length - 1,
                        lineBarsData: lineBarsData,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < subname_lst.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      subname_lst[index],
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData:
                            FlGridData(show: true, horizontalInterval: 20),
                        borderData: FlBorderData(show: true),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            tooltipPadding: const EdgeInsets.all(6),
                            tooltipMargin: 8,
                            getTooltipItems: (spots) {
                              return spots.map((spot) {
                                int i = spot.x.toInt();
                                String examName =
                                    (i >= 0 && i < subname_lst.length)
                                        ? subname_lst[i]
                                        : '';
                                return LineTooltipItem(
                                  "$examName\n${spot.y.toStringAsFixed(1)}%",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    backgroundColor: Colors.black87,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(
                            y: 100,
                            color: Colors.red,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              labelResolver: (line) => 'Upper Limit',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          HorizontalLine(
                            y: 0,
                            color: Colors.red,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.bottomRight,
                              labelResolver: (line) => 'Lower Limit',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
