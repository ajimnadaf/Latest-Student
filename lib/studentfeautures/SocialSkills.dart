import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/studentfeautures/SocialSkills.dart'
    as Social_skills;

SocketService socketService = SocketService();
Map<String, String> answersMap = {};
Map<String, List<String>> questionOptionMap = {};
Map<String, TextEditingController> answerControllerMap = {};
Map<String, String>? descriptionMap;
bool isLoading = false;

List qid_Lst = [],
    qtype_Lst = [],
    imglnk_Lst = [],
    classid_Lst = [],
    classname_Lst = [],
    question_Lst = [],
    profid_Lst = [],
    prof_Lst = [],
    mandatory_Lst = [];

String def_date = "";
String cur_date = "";
Map<String, Set<String>> multiAnswerMap = {};
Map<String, TextEditingController> otherControllerMap = {};
List optid_lst = [], opt_qid_lst = [], option_lst = [];

class SocialSkill extends StatefulWidget {
  const SocialSkill({super.key});

  @override
  State<SocialSkill> createState() => _SocialSkillState();
}

class _SocialSkillState extends State<SocialSkill> {
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();

    DateFormat sourceFormat = DateFormat('dd/MM/yyyy');
    DateFormat sourceFormat1 = DateFormat('yyyy/MM/dd');

    def_date = sourceFormat.format(now);
    cur_date = sourceFormat1.format(now);

    print("Default Date: $def_date");
    print("Current Date: $cur_date");

    onpostExecute();
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

  Future<String> UpsertAnswerTask() async {
    String responce = "";
    DateTime now = DateTime.now();

    // Format date as yyyy-MM-dd
    DateFormat sourceFormat1 = DateFormat('yyyy-MM-dd');
    cur_date = sourceFormat1.format(now);
    print("cur_date: $cur_date");

    // Loop over all answers
    for (final entry in Social_skills.answersMap.entries) {
      String qid = entry.key;
      String answer = entry.value;
      String qtype = qtype_Lst[qid_Lst.indexOf(qid)].toString();

      print("QID: $qid");
      print("answers: $answer");
      print("QTYPE: $qtype");

      // DESCRIPTIVE and SINGLE ANSWER types
      if (qtype.toUpperCase() == "DESCRIPTIVE" ||
          qtype.toUpperCase() == "SINGLE ANSWER") {
        // DELETE query
        String deleteQuery =
            "DELETE FROM trueguide.skillstudanstbl WHERE qid='$qid' AND classid='${Glb.classid}' "
            "AND instid='${Glb.inst_id}' AND studid ='${Glb.student_id}' and date='$cur_date';";
        print("Query just Send: $deleteQuery");
        responce =
            await socketService.sendMessage(Glb.ip, Glb.port, deleteQuery, 714);
        if (responce.startsWith("Err:")) return "ERROR";

        // INSERT query
        String insertQuery =
            "INSERT INTO trueguide.skillstudanstbl (qid, classid, instid, studid, ans) "
            "VALUES('$qid','${Glb.classid}','${Glb.inst_id}','${Glb.student_id}','$answer') "
            "ON CONFLICT(qid, classid, instid, studid, date, ans) DO NOTHING;";
        print("Query the Query: $insertQuery");
        responce =
            await socketService.sendMessage(Glb.ip, Glb.port, insertQuery, 714);
        if (responce.startsWith("Err:")) return "ERROR";
      } else {
        // MULTIPLE ANSWER type
        List<String> splitAnswers = answer.split("#@");

        // DELETE query first
        String deleteQuery =
            "DELETE FROM trueguide.skillstudanstbl WHERE qid='$qid' AND classid='${Glb.classid}' "
            "AND instid='${Glb.inst_id}' AND studid ='${Glb.student_id}' and date='$cur_date';";
        print("Query just Send: $deleteQuery");
        responce =
            await socketService.sendMessage(Glb.ip, Glb.port, deleteQuery, 714);
        if (responce.startsWith("Err:")) return "ERROR";

        // INSERT each answer individually, keeping full SQL
        for (String ans in splitAnswers) {
          String desc = "NA";
          if (ans.toLowerCase() == "other") {
            if (descriptionMap != null && descriptionMap![qid] != null) {
              desc = descriptionMap![qid]!;
            }
          }

          String insertQuery =
              "INSERT INTO trueguide.skillstudanstbl (qid, classid, instid, studid, ans, othedesc) "
              "VALUES('$qid','${Glb.classid}','${Glb.inst_id}','${Glb.student_id}','$ans','$desc') "
              "ON CONFLICT(qid, classid, instid, studid, date, ans) DO NOTHING;";
          print("Query the Query: $insertQuery");
          responce = await socketService.sendMessage(
              Glb.ip, Glb.port, insertQuery, 714);
          if (responce.startsWith("Err:")) return "ERROR";
        }
      }

      // Check server response
      if (responce.startsWith("ErrorCode#8") ||
          responce.startsWith("ErrorCode#9")) {
        print("Sumething wrong ");
        return "ERR";
      }
      if (responce.startsWith("ErrorCode#0")) {
        print("SUCCESSFULLY UPDATED");
      }
    }

    return "SUCCESS";
  }

  Future<void> onpost() async {
    setState(() {
      isLoading = true;
    });
    String result = await UpsertAnswerTask();

    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Lost Pls Try again")));
    }
    if (result.toUpperCase() == "ERR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something Went Wrong")));
    }

    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Answers Uploaded SuccessFully")));
    }

    if (isLoading) Glb.showLoadingIndicator(context);
  }

  Future<String> get_Data_spcl() async {
    String query =
        "select qid,questiontbl.classid,classname,question,profid,prof,qtype,imglnk,mandatory from " +
            "trueguide.questiontbl,trueguide.pclasstbl,trueguide.profiletbl where " +
            "pclasstbl.classid = questiontbl.classid and profid=pfid and  profiletbl.status='1' and " +
            " questiontbl.classid = '" +
            Glb.classid +
            "' and " +
            "questiontbl.instid='" +
            Glb.inst_id +
            "' order by qid ";

    print("Query: $query");

    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      print("Internet Error");
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      //rreturn "NOATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);
      qid_Lst = data['X^1_1'] ?? [];
      classid_Lst = data['X^2_2'] ?? [];
      classname_Lst = data['X^3_3'] ?? [];
      question_Lst = data['X^4_4'] ?? [];
      profid_Lst = data['X^5_5'] ?? [];
      prof_Lst = data['X^6_6'] ?? [];
      qtype_Lst = data['X^7_7'] ?? [];
      imglnk_Lst = data['X^8_8'] ?? [];
      mandatory_Lst = data['X^9_9'] ?? [];
    }

    String qids = "";

    for (int i = 0; i < qid_Lst.length; i++) {
      if (i == qid_Lst.length - 1) {
        qids += "'" + qid_Lst[i].toString() + "'";
      } else {
        qids += "'" + qid_Lst[i].toString() + "',";
      }
    }

    query = "select optid,qid,option from trueguide.optionstbl where qid in (" +
        qids +
        ") order by qid ";

    print("Query : $query");
    responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(responce);

      optid_lst = data['X^1_1'] ?? [];
      opt_qid_lst = data['X^2_2'] ?? [];
      option_lst = data['X^3_3'] ?? [];

      print("optid_lst : $optid_lst");
      print("opt_qid_lst: $opt_qid_lst");
      print("option_lst: $option_lst");
    }
    return "SUCCESS";
  }

  void onpostExecute() async {
    setState(() {
      isLoading = true;
    });
    String result = await get_Data_spcl();

    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Internet Lost pls retry again")));
      return;
    }

    if (result.toUpperCase() == "NODATA") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("NO DATA")));
      return;
    }

    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        questionOptionMap.clear();

        for (int i = 0; i < optid_lst.length; i++) {
          String qid = opt_qid_lst[i].toString();
          questionOptionMap.putIfAbsent(qid, () => []);
          questionOptionMap[qid]!.add(option_lst[i].toString());
        }
      });

      print("QuestionMap: $questionOptionMap");

      setState(() {
        isLoading = false;
      });
    }

    if (isLoading) Glb.showLoadingIndicator(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.white,
                ),
                Container(
                  height: 25,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Social Skills",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          body: Column(
            children: [
              // ===== TOP BUTTONS =====
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: GestureDetector(
                        onTap: () {
                          print("Date Button Tapped");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$def_date",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, top: 10),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => isLoading = true);

                          if (answersMap.isEmpty) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("No Answer Given")));
                            return;
                          }

                          // Check mandatory answers
                          if (answersMap.length != qtype_Lst.length) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "All Questions are mandatory Please fill All Answers"),
                              ),
                            );
                            return;
                          }

                          await onpost();
                          setState(() => isLoading = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "SUBMIT ANSWERS",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ===== CARDS =====
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: question_Lst.length,
                  itemBuilder: (context, index) {
                    String qid = qid_Lst[index].toString();
                    String qtype = qtype_Lst[index].toString();
                    String question = question_Lst[index].toString();

                    // Initialize controller for descriptive answers
                    answerControllerMap.putIfAbsent(
                        qid, () => TextEditingController());
                    if (!answersMap.containsKey(qid) &&
                        qtype.toUpperCase() == "DESCRIPTIVE") {
                      answerControllerMap[qid]!.text = "";
                    } else if (answersMap.containsKey(qid) &&
                        qtype.toUpperCase() == "DESCRIPTIVE") {
                      answerControllerMap[qid]!.text = answersMap[qid]!;
                    }

                    // -------- DESCRIPTIVE CARD --------
                    if (qtype.toUpperCase() == "DESCRIPTIVE") {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: answerControllerMap[qid],
                                decoration: const InputDecoration(
                                  hintText: "Type your answer here",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  answersMap[qid] = val;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // -------- SINGLE ANSWER CARD --------
                    if (qtype.toUpperCase() == "SINGLE ANSWER") {
                      List<String> options = questionOptionMap[qid] ?? [];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            String? selected =
                                await showModalBottomSheet<String>(
                              context: context,
                              builder: (_) {
                                return ListView(
                                  children: options
                                      .map(
                                        (opt) => ListTile(
                                          title: Text(opt),
                                          onTap: () {
                                            Navigator.pop(context, opt);
                                          },
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            );

                            if (selected != null) {
                              setState(() {
                                answersMap[qid] = selected;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(question,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        answersMap[qid] ?? "Select option",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // -------- MULTIPLE ANSWER CARD --------
                    if (qtype.toUpperCase() == "MULTIPLE ANSWER") {
                      List<String> options = questionOptionMap[qid] ?? [];
                      multiAnswerMap.putIfAbsent(qid, () => <String>{});
                      otherControllerMap.putIfAbsent(
                          qid, () => TextEditingController());

                      // Restore OTHER value if already entered
                      if (descriptionMap != null &&
                          descriptionMap!.containsKey(qid)) {
                        otherControllerMap[qid]!.text = descriptionMap![qid]!;
                      }

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),

                              // ----- CHECKBOX OPTIONS -----
                              ...options.map((opt) {
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(opt),
                                  value: multiAnswerMap[qid]!.contains(opt),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        multiAnswerMap[qid]!.add(opt);
                                      } else {
                                        multiAnswerMap[qid]!.remove(opt);
                                      }

                                      answersMap[qid] =
                                          multiAnswerMap[qid]!.join("#@");

                                      // handle OTHER removal
                                      if (opt.toUpperCase() == "OTHER" &&
                                          checked == false) {
                                        descriptionMap ??= {};
                                        descriptionMap!.remove(qid);
                                        otherControllerMap[qid]!.clear();
                                      }
                                    });
                                  },
                                );
                              }).toList(),

                              // ----- OTHER TEXTFIELD -----
                              if (multiAnswerMap[qid]!.contains("OTHER")) ...[
                                const SizedBox(height: 8),
                                TextField(
                                  controller: otherControllerMap[qid],
                                  decoration: const InputDecoration(
                                    hintText: "Please specify",
                                    border: UnderlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    descriptionMap ??= {};
                                    descriptionMap![qid] = val;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox(); // fallback
                  },
                ),
              ),
            ],
          ),
        ),

        // ===== LOADING INDICATOR =====
        if (isLoading) Glb.showLoadingIndicator(context),
      ],
    );
  }
}
