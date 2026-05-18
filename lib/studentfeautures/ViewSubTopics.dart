import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/studentfeautures/Notes.dart';
import 'package:student_app/studentfeautures/UploadSyllabusDataRecycler.dart';

List subindxid_lst = [], count_lst = [];
List aList = [];
int pos = 0;

SocketService socketService = SocketService();

class ViewSubtopicsPage extends StatefulWidget {
  const ViewSubtopicsPage({Key? key}) : super(key: key);

  @override
  State<ViewSubtopicsPage> createState() => _ViewSubtopicsPageState();
}

class _ViewSubtopicsPageState extends State<ViewSubtopicsPage> {
  @override
  void initState() {
    super.initState();
    Onpost();
  }

  void dispose() {
    super.dispose();
    aList.clear();
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

  Future<String> Async_get_sub_index() async {
    String query =
        "select subindexid,subindexname from trueguide.tsubindextbl where indexid='" +
            Glb.index_id_cur +
            "' and visible='1' order by subindexid";
    print("Query : $query");

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

      Glb.sub_index_id_lst = data['X^1_1'] ?? [];
      Glb.sub_index_name_lst = data['X^2_2'] ?? [];

      print("sub_index_id_lst : ${Glb.sub_index_id_lst}");
      print("sub_index_name_lst: ${Glb.sub_index_name_lst}");
    }

    query = "select tsubindextbl.subindexid,count(syldatatbl.subindexid) from trueguide.tsubindextbl,trueguide.syldatatbl where tsubindextbl.indexid='" +
        Glb.index_id_cur +
        "' and tsubindextbl.subindexid=syldatatbl.subindexid and tsubindextbl.visible='1' group by  tsubindextbl.subindexid,tsubindextbl.subindexname,syldatatbl.subindexid";
    print("Query : $query");

    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }

    if (responce.startsWith("ErrorCode#2")) {
      //return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      subindxid_lst = data['X^1_1'] ?? [];
      count_lst = data['X^2_2'] ?? [];

      print("subindxid_lst : $subindxid_lst");
      print("count_lst : $count_lst");
    }

    return "SUCCESS";
  }

  void Onpost() async {
    String check = await Async_get_sub_index();

    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Lost From server pls try Again")));
      return;
    }

    if (check.toUpperCase() == "NODATA") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO SUB INDEX FOUND")));
      return;
    }

    if (check.toUpperCase() == "SUCCESS") {
      setState(() {
        aList.clear(); // VERY IMPORTANT

        for (int i = 0;
            Glb.sub_index_id_lst != null && i < Glb.sub_index_id_lst.length;
            i++) {
          String count = "0";

          // ✅ Use SUB INDEX ID
          String subId = Glb.sub_index_id_lst[i].toString();

          if (subindxid_lst != null) {
            int ind = subindxid_lst.indexOf(subId);

            if (ind != -1) {
              count = count_lst[ind].toString();
            }
          }

          // ✅ Use SUB INDEX NAME
          String subName = clearInputTxt(Glb.sub_index_name_lst[i].toString());

          Map<String, String> hm = {};

          // ✅ Store separately
          hm["sub_ch"] = subName;
          hm["docs"] = count;

          aList.add(hm);
        }
      });

      print("alist: $aList");
    }
  }

  String clearInputTxt(String txt) {
    txt = txt.replaceAll("-dot-", ".");
    txt = txt.replaceAll("-underscore-", "_");
    txt = txt.replaceAll("-amp-", "&");
    txt = txt.replaceAll("-at-", "@");
    txt = txt.replaceAll("-hash-", "#");
    txt = txt.replaceAll("-question-", "?");
    txt = txt.replaceAll("-apos-", "'");
    txt = txt.replaceAll("-dollar-", "\$"); // escape $
    txt = txt.replaceAll("-equals-", "=");
    txt = txt.replaceAll("-plus-", "+");
    txt = txt.replaceAll("recrd", "record");

    return txt;
  }

  void save(int positione) async {
    Glb.sub_index_id_cur = Glb.sub_index_id_lst[positione].toString();
    pos = positione;
    submit_popup(context);
  }

  void submit_popup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TITLE
                const Text(
                  "Select Option",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// STUDY MATERIAL BUTTON
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // close dialog

                    // ✅ SAME JAVA LOGIC
                    if (Glb.main_feature == "scholar" &&
                        Glb.study_sub_index == true) {
                      print("Tapped NewQBank");
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const NewQBank(),
                      //   ),
                      // );
                    } else if (Glb.main_feature == "scholar" &&
                        Glb.study_concept == true) {
                      print("Tapped NewSub Indext");
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const NewSubIndexToConcept(),
                      //   ),
                      // );
                    } else {
                      print("Tapped Syllabus data Recycle");

                      Glb.doc = "syllabusdata";

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyMaterialPage(),
                        ),
                      );
                    }
                  },
                  child: buildPopupButton(
                    icon: Icons.menu_book,
                    text: "Study Material",
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 15),

                /// NOTES BUTTON
                InkWell(
                  onTap: () {
                    print("TAPED View Notes");
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentNotesPage(),
                      ),
                    );
                  },
                  child: buildPopupButton(
                    icon: Icons.note_alt,
                    text: "Notes",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPopupButton({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APPBAR
      appBar: AppBar(
        title: const Text(
          "View Subtopics",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// INDEX TEXT
            Text(
              "INDEX : ${Glb.index_name_curr}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 LISTVIEW OF CARDS
            Expanded(
              child: ListView.builder(
                itemCount: aList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        //=======================//

                        save(index);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// SUB CH ROW
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "SUB CH: ${aList[index]['sub_ch']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// DOCS ROW
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "DOCS: ${aList[index]['docs']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// CLICK ROW
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "CLICK HERE TO GET THE DOCS.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
