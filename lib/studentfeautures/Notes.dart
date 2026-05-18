import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';

SocketService socketService = SocketService();

String Load_type = "My_Notes";

List noteid_lst = [],
    ndesc_lst = [],
    question_lst = [],
    answer_lst = [],
    usertype_lst = [];

List aList = [];

class StudentNotesPage extends StatefulWidget {
  const StudentNotesPage({Key? key}) : super(key: key);

  @override
  State<StudentNotesPage> createState() => _StudentNotesPageState();
}

class _StudentNotesPageState extends State<StudentNotesPage> {
  @override
  void initState() {
    super.initState();

    Onpost();
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

  int selectedIndex = 0; // 0 = My Notes, 1 = Teacher Notes

  Future<String> Async_get_sub_index() async {
    String query = "";
    String responce = "";

    if (Load_type == "All_Notes") {
      query =
          "select noteid,ndesc,question,answer,usertype from trueguide.tnotestbl where  " +
              "instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and " +
              "subid='" +
              Glb.sub_id_cur +
              "' and indexid='" +
              Glb.index_id_cur +
              "' and " +
              "subindexid='" +
              Glb.sub_index_id_cur +
              "' and usertype='STAFF' ";
    }

    if (Load_type == "My_Notes") {
      query =
          "select noteid,ndesc,question,answer,usertype from trueguide.tnotestbl where  " +
              "instid='" +
              Glb.inst_id +
              "' and classid='" +
              Glb.classid +
              "' and " +
              "subid='" +
              Glb.sub_id_cur +
              "' and indexid='" +
              Glb.index_id_cur +
              "' and " +
              "subindexid='" +
              Glb.sub_index_id_cur +
              "' and userid='" +
              Glb.userid +
              "'";
    }

    print("Query: $query");

    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("Errpr");
      return "NODATA";
    }

    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      noteid_lst = data['X^1_1'] ?? [];
      ndesc_lst = data['X^2_2'] ?? [];
      question_lst = data['X^3_3'] ?? [];
      answer_lst = data['X^4_4'] ?? [];
      usertype_lst = data['X^5_5'] ?? [];

      print("noteid_lst : $noteid_lst");
      print("ndesc_lst : $ndesc_lst");
      print("question_lst: $question_lst");
      print("answer_lst: $answer_lst");
      print("usertype_lst : $usertype_lst");
    }

    return "SUCCESS";
  }

  void Onpost() async {
    String check = await Async_get_sub_index();

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
      if (noteid_lst == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No Data Found")));
        return;
      }
      aList.clear();
      for (int j = 0; j < noteid_lst.length; j++) {
        Map<String, String> hm = {};

        hm["Desc"] = ndesc_lst[j].toString();
        hm["Que"] = question_lst[j].toString();
        hm["Ans"] = answer_lst[j].toString();

        aList.add(hm);
      }

      print("ALIST: $aList");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "STUDENT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // ===== Buttons Row =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildButton("MY NOTES", 0),
              const SizedBox(width: 15),
              buildButton("TEACHER NOTES", 1),
            ],
          ),

          const SizedBox(height: 10),

          // ===== Blue Line =====
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.blue,
          ),

          const SizedBox(height: 15),

          // ===== All Notes Text =====
          const Text(
            "All Notes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // ===== Empty Space / Content Area =====
          Expanded(
            child: aList.isEmpty
                ? const Center(
                    child: Text(
                      "No Notes Found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: aList.length,
                    itemBuilder: (context, index) {
                      final item = aList[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Desc
                              Text(
                                item["Desc"] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Question
                              Text(
                                "Q: ${item["Que"] ?? ""}",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Answer
                              Text(
                                "Ans: ${item["Ans"] ?? ""}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // ===== Custom Button =====
  Widget buildButton(String title, int index) {
    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
          if (selectedIndex == 0) {
            print("MY LIST BUTTON CLICKED");
            Load_type = "My_Notes";
            Onpost();
          } else {
            print("TEACHER LIST BUTTON CLICKED");
            Load_type = "All_Notes";
            Onpost();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffdfe6f2) // Selected color
              : const Color(0xfff2f2f2), // Normal color

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.blue.shade300,
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            )
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
