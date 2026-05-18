import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/studentfeautures/ViewSubTopics.dart';

List indxid_lst = [], count_lst = [];
List aList = [];

int pos = 0;

SocketService socketService = SocketService();

class Mysyllabus extends StatefulWidget {
  const Mysyllabus({super.key});

  @override
  State<Mysyllabus> createState() => _MysyllabusState();
}

class _MysyllabusState extends State<Mysyllabus> {
  @override
  void initState() {
    super.initState();
    getvalues();
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

  void getvalues() async {
    Glb.sub_id_cur =
        Glb.SubMap![Glb.student_id]!.psubid_lst[Glb.sub_ind].toString();
    Glb.sub_name_cur =
        Glb.SubMap![Glb.student_id]!.psubname_lst[Glb.sub_ind].toString();
    Glb.syl_coverage_subid_cur =
        Glb.SubMap![Glb.student_id]!.psubid_lst[Glb.sub_ind].toString();

    Glb.subtypelst_cur =
        Glb.SubMap![Glb.student_id]!.psubtype_lst[Glb.sub_ind].toString();

    Glb.ex_sub_name_cur = Glb.sub_name_cur;
    Glb.upcmng_perf_SubId_cur = Glb.sub_id_cur;

    print("sub_id_cur = ${Glb.sub_id_cur}");
    print("sub_name_cur = ${Glb.sub_name_cur}");
    print("syl_coverage_subid_cur = ${Glb.syl_coverage_subid_cur}");
    print("subtypelst_cur = ${Glb.subtypelst_cur}");
    print("ex_sub_name_cur = ${Glb.ex_sub_name_cur}");
    print("upcmng_perf_SubId_cur = ${Glb.upcmng_perf_SubId_cur}");

    onpost();
  }

  Future<String> Async_get_index() async {
    String query =
        "select indexid,indexname from trueguide.tindextbl where instid='" +
            Glb.inst_id +
            "' and classid='" +
            Glb.classid +
            "' and subid='" +
            Glb.sub_id_cur +
            "' and visible='1' group by  indexid,indexname order by indexid";

    print("Query: $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("Errpr");
      return "NODATA";
    }

    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      Glb.index_id_lst = data['X^1_1'] ?? [];
      Glb.index_name_lst = data['X^2_2'] ?? [];

      print("index_id_lst : ${Glb.index_id_lst}");
      print("index_name_lst: ${Glb.index_name_lst}");
    }

    query = "select indexid,indexname,count(syldatatbl.indx) from trueguide.tindextbl,trueguide.syldatatbl where tindextbl.instid='" +
        Glb.inst_id +
        "' and tindextbl.classid='" +
        Glb.classid +
        "' and tindextbl.subid='" +
        Glb.sub_id_cur +
        "'  and tindextbl.indexid=syldatatbl.indx and tindextbl.visible='1' group by (indexid,indexname,syldatatbl.indx)";

    print("Query: $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("Errpr");
      // return "NODATA";
    }

    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      indxid_lst = data['X^1_1'] ?? [];
      count_lst = data['X^2_2'] ?? [];

      print("indxid_lst : $indxid_lst");
      print("count_lst: $count_lst");
    }
    return "SUCCESS";
  }

  Future<void> onpost() async {
    print("Came Inside On[post]");
    String check = await Async_get_index();

    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Lost From Server Pls Try again")));
      return;
    }

    if (check.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data Found")));
      return;
    }

    if (check.toUpperCase() == "SUCCESS") {
      setState(() {
        aList.clear();

        for (int i = 0;
            Glb.index_id_lst != null && i < Glb.index_id_lst.length;
            i++) {
          String count = "";
          String indx = Glb.index_id_lst[i].toString();

          if (indxid_lst != null) {
            int ind = indxid_lst.indexOf(indx);
            if (ind == -1) {
              count = "0";
            } else {
              count = count_lst[ind].toString();
            }
          } else {
            count = "0";
          }

          Map<String, String> hm = {};

          hm["first"] = "CH: ${Glb.index_name_lst[i]}\n"
              "DOCS: $count\n"
              "Click here to get sub-chapters";

          aList.add(hm);
        }
      });

      print("ALIST : $aList");
    }
  }

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
                  onTap: () async {
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

                    await onpost();

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

  void SaveValue(int position) async {
    Glb.index_id_cur = Glb.index_id_lst[position].toString();
    Glb.index_name_curr = Glb.index_name_lst[position].toString();
    pos = position;

    if (Glb.main_feature.toLowerCase() == "scholar" &&
        Glb.study_index == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("For this Role The Screen will come soon")));
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ViewSubtopicsPage(),
      //     ));
    }

    if (Glb.main_feature.toLowerCase() == "scholar" &&
        Glb.study_concept == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("For this Role The Screen will come soon")));
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ViewSubtopicsPage(),
      //     ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSubtopicsPage(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "View Topics",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          /// FULL ORANGE FRAME (UNCHANGED)
          InkWell(
            onTap: () {
              SelectSubjectPopUp(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA000),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFFA000),
                  width: 3,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${Glb.ex_sub_name_cur}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Click here to change subject",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 LISTVIEW INSIDE SAME BORDER BOX
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: ListView.builder(
                itemCount: aList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      SaveValue(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder,
                              color: Colors.blue, size: 42),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              aList[index]["first"] ?? "",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
