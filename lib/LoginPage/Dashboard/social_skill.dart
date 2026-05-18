import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

SocketService socketService = SocketService();

class DailyStudentReportPage extends StatefulWidget {
  const DailyStudentReportPage({Key? key}) : super(key: key);

  @override
  State<DailyStudentReportPage> createState() => _DailyStudentReportPageState();
}

class _DailyStudentReportPageState extends State<DailyStudentReportPage> {
  // --- Data Logic Variables ---
  List<String> qidList = [];
  List<String> questionList = [];
  List<String> qtypeList = [];
  List<String> mandatoryList = [];
  List<String> imglnkList = [];

  Map<String, List<String>> questionOptionMap = {};
  Map<String, String> answersMap = {};
  Map<String, String> descriptionMap = {};
  Map<String, TextEditingController> dynamicControllers = {};
  Map<String, List<String>> selectedMultiAnswers = {};

  bool isLoading = true;
  String todayDate = DateFormat('EEEE, d MMM').format(DateTime.now());
  String cur_date = DateFormat('yyyy/MM/dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  void fetchInitialData() async => await getQuestions();

  // --- Logic: Fetching Questions ---
  Future<void> getQuestions() async {
    setState(() => isLoading = true);

    String query =
        "select qid,questiontbl.classid,classname,question,profid,prof,qtype,imglnk,mandatory "
        "from trueguide.questiontbl,trueguide.pclasstbl,trueguide.profiletbl "
        "where pclasstbl.classid = questiontbl.classid and profid=pfid and profiletbl.status='1' "
        "and questiontbl.classid='${Glb.classid}' and questiontbl.instid='${Glb.inst_id}' order by qid";

    try {
      String response =
          await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

      if (response.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(response);

        setState(() {
          // Mapping according to your server response keys (X1, X4, etc.)
          qidList = data['X1'] ?? [];
          questionList = data['X4'] ?? [];
          qtypeList = data['X7'] ?? [];
          imglnkList = data['X8'] ?? [];
          mandatoryList = data['X9'] ?? [];
        });

        if (qidList.isNotEmpty) {
          await getOptions();
        }
      } else if (response.contains("ErrorCode#2")) {
        _showMsg("No questions available for this class.", isError: true);
      }
    } catch (e) {
      _showMsg("Connection Error: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- Logic: Fetching Options ---
  Future<void> getOptions() async {
    String qids = qidList.map((id) => "'$id'").join(',');
    String optQuery =
        "select optid,qid,option from trueguide.optionstbl where qid in ($qids) order by qid";

    String response =
        await socketService.sendMessage(Glb.ip, Glb.port, optQuery, 709);

    if (response.startsWith("record#")) {
      Map<String, List<String>> optData = processRecords(response);
      List<String> optQidLst = optData['X2'] ?? [];
      List<String> optionLst = optData['X3'] ?? [];

      setState(() {
        for (int i = 0; i < optQidLst.length; i++) {
          String qid = optQidLst[i];
          questionOptionMap.putIfAbsent(qid, () => []).add(optionLst[i]);
        }
      });
    }
  }

  // --- Logic: Submit Data ---
  Future<void> submitData() async {
    if (answersMap.isEmpty &&
        selectedMultiAnswers.isEmpty &&
        dynamicControllers.isEmpty) {
      _showMsg("Please answer all questions", isError: true);
      return;
    }

    setState(() => isLoading = true);
    String q = "";

    try {
      for (int i = 0; i < qidList.length; i++) {
        String qid = qidList[i];
        String qtype = qtypeList[i];
        String isMandatory = mandatoryList[i];
        String answer = "";

        if (qtype == "SINGLE ANSWER") {
          answer = answersMap[qid] ?? "";
        } else if (qtype == "MULTIPLE ANSWER") {
          answer = (selectedMultiAnswers[qid] ?? []).join('#@');
        } else {
          answer = dynamicControllers[qid]?.text ?? "";
        }

        if (isMandatory == "1" && answer.isEmpty) {
          setState(() => isLoading = false);
          _showMsg("Mandatory: ${questionList[i]}", isError: true);
          return;
        }

        if (answer.isEmpty) continue;

        q +=
            "DELETE FROM trueguide.skillstudanstbl WHERE qid='$qid' AND classid='${Glb.classid}' AND instid='${Glb.inst_id}' AND studid ='${Glb.stu_id}' and date='$cur_date';";

        if (qtype == "DESCRIPTIVE" || qtype == "SINGLE ANSWER") {
          q +=
              "INSERT INTO trueguide.skillstudanstbl (qid, classid, instid, studid, ans) VALUES('$qid','${Glb.classid}','${Glb.inst_id}','${Glb.stu_id}','$answer');";
        } else {
          List<String> splitAnswers = answer.split("#@");
          for (String ans in splitAnswers) {
            String desc = (ans.toLowerCase() == "other")
                ? (descriptionMap[qid] ?? "NA")
                : "NA";
            q +=
                "INSERT INTO trueguide.skillstudanstbl (qid, classid, instid, studid, ans, othedesc) VALUES('$qid','${Glb.classid}','${Glb.inst_id}','${Glb.stu_id}','$ans','$desc');";
          }
        }
      }

      String res = await socketService.sendMessage(Glb.ip, Glb.port, q, 709);

      if (res.toLowerCase().contains("success") ||
          res.contains("ErrorCode#0")) {
        _showMsg("Report submitted successfully!");
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.pop(context));
      } else {
        _showMsg("Submission Failed", isError: true);
      }
    } catch (e) {
      _showMsg("Server Error", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- Helper: Parsing Records ---
  Map<String, List<String>> processRecords(String input) {
    List<String> records =
        input.split('record#').where((r) => r.isNotEmpty).toList();
    Map<String, List<String>> resultMap = {};
    for (var record in records) {
      List<String> items = record.split('&');
      for (var item in items) {
        if (!item.contains('#')) continue;
        List<String> parts = item.split('#');
        String keyRaw = parts[0];
        String value = parts.length > 1 ? parts[1] : "";
        String cleanKey = keyRaw.replaceAll(RegExp(r'\^\d+_'), '');
        resultMap.putIfAbsent(cleanKey, () => []).add(value);
      }
    }
    return resultMap;
  }

  void _showMsg(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.green));
  }

  @override
  void dispose() {
    // 1. Sabhi dynamic controllers ko loop karke dispose karein
    for (var controller in dynamicControllers.values) {
      controller.dispose();
    }
    // 2. Map ko clear karein
    dynamicControllers.clear();

    // 3. Super dispose call karein
    super.dispose();
  }

  // --- UI: Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildDateBanner(),
              if (qidList.isEmpty && !isLoading) _buildEmptyState(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildQuestionCard(index),
                    childCount: qidList.length,
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150.0, // Thoda height badhaya flexible feel ke liye
      pinned: true,
      stretch: true, // Pull down effect ke liye
      backgroundColor: const Color(0xFF1E3A8A),
      // Leading icon ko thoda styling diya
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, // Android/iOS dono par center title ke liye
        titlePadding: const EdgeInsets.only(bottom: 16), // Bottom se space
        title: const Text(
          "Daily Student Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                ),
              ),
            ),
            // Decorative Icons (Background mein halka design)
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.assignment_turned_in,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.event_note, color: Colors.indigo),
              const SizedBox(width: 12),
              Text(todayDate,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.verified_user, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    String qid = qidList[index];
    String type = qtypeList[index];
    bool isRequired = mandatoryList[index] == "1";
    List<String> opts = questionOptionMap[qid] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "${index + 1}. ${questionList[index]}${isRequired ? ' *' : ''}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B)),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildInputSection(qid, type, opts),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(String qid, String type, List<String> opts) {
    if (type == "SINGLE ANSWER") {
      return Column(children: opts.map((o) => _buildRadio(qid, o)).toList());
    } else if (type == "MULTIPLE ANSWER") {
      return Column(children: opts.map((o) => _buildCheckbox(qid, o)).toList());
    } else {
      return _buildTextField(qid);
    }
  }

  Widget _buildRadio(String qid, String option) {
    bool isSelected = answersMap[qid] == option;
    return ListTile(
      onTap: () => setState(() => answersMap[qid] = option),
      leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? Colors.blue : Colors.grey),
      title: Text(option),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildCheckbox(String qid, String option) {
    bool isSelected = (selectedMultiAnswers[qid] ?? []).contains(option);
    return ListTile(
      onTap: () {
        setState(() {
          selectedMultiAnswers.putIfAbsent(qid, () => []);
          isSelected
              ? selectedMultiAnswers[qid]!.remove(option)
              : selectedMultiAnswers[qid]!.add(option);
        });
      },
      leading: Icon(
          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
          color: isSelected ? Colors.blue : Colors.grey),
      title: Text(option),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTextField(String qid) {
    return TextField(
      controller:
          dynamicControllers.putIfAbsent(qid, () => TextEditingController()),
      maxLines: 2,
      decoration: InputDecoration(
        hintText: "Your answer...",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("SUBMIT REPORT",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child:
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(child: Text("No data found.")),
    );
  }
}
