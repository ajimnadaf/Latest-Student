import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

class New_Attendance_Performance extends StatefulWidget {
  const New_Attendance_Performance({Key? key}) : super(key: key);

  @override
  State<New_Attendance_Performance> createState() =>
      _New_Attendance_PerformanceState();
}

class _New_Attendance_PerformanceState
    extends State<New_Attendance_Performance> {
  // SAME VARIABLES
  String date_str = "";

  bool from_date = false;
  bool till_date = false;

  bool onlinechk1 = false;
  bool offlinechk2 = false;

  bool onlineEnabled = true;
  bool offlineEnabled = true;

  TextEditingController attfrom = TextEditingController();
  TextEditingController atttill = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();

    // ===== JAVA STYLE NULL CHECKS =====
    if (Glb.sub_ind != -1 &&
        Glb.SubMap != null &&
        Glb.student_id != null &&
        Glb.SubMap!.containsKey(Glb.student_id)) {
      final subObj = Glb.SubMap![Glb.student_id];

      if (subObj != null && Glb.sub_ind < subObj.psubid_lst.length) {
        Glb.upcmng_perf_SubId_cur = Glb.syl_coverage_subid_cur =
            Glb.sub_id_cur = subObj.psubid_lst[Glb.sub_ind].toString();

        Glb.sub_name_cur = subObj.psubname_lst[Glb.sub_ind].toString();

        Glb.subtypelst_cur = subObj.psubtype_lst[Glb.sub_ind].toString();

        Glb.ex_sub_name_cur = Glb.sub_name_cur;
        Glb.subwise_att = false;
      } else {
        Glb.subwise_att = true;
      }
    } else {
      Glb.subwise_att = true;
    }

    make_setup();
  }

  // ================= MAKE SETUP =================
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

          onlinechk1 = true;
          onlineEnabled = false;
          offlineEnabled = false;
        } else {
          Glb.subject_name = "Consolidated Attendance";
        }
      }
    });
  }

  // ================= DATE PICKER =================
  Future<void> pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = DateFormat('yyyy-MM-dd').format(picked);

      setState(() {
        if (isFrom) {
          Glb.att_from_date = formatted;
          attfrom.text = formatted;
        } else {
          Glb.att_to_date = formatted;
          atttill.text = formatted;
        }
      });
    }
  }

  // ================= SUBJECT POPUP =================
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
                  onTap: () {
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Attendance Performance",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUBJECT ORANGE BAR =================
            GestureDetector(
              onTap: () => SelectSubjectPopUp(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.black, size: 40),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Glb.subject_name ?? "HINDI",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Click here to change subject",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= CHOOSE CLASS TYPE =================
            const Text(
              "Choose Class Type:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text("Offline Attendance",
                  style: TextStyle(fontSize: 16)),
              value: offlinechk2,
              onChanged: offlineEnabled
                  ? (v) {
                      setState(() {
                        offlinechk2 = v!;
                        if (offlinechk2) {
                          onlinechk1 = false;
                          onlineEnabled = false;
                        } else {
                          onlineEnabled = true;
                        }
                      });
                    }
                  : null,
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text("Online Attendance",
                  style: TextStyle(fontSize: 16)),
              value: onlinechk1,
              onChanged: onlineEnabled
                  ? (v) {
                      setState(() {
                        onlinechk1 = v!;
                        if (onlinechk1) {
                          offlinechk2 = false;
                          offlineEnabled = false;
                        } else {
                          offlineEnabled = true;
                        }
                      });
                    }
                  : null,
            ),

            const SizedBox(height: 20),

            // ================= FROM DATE =================
            const Text(
              "From Date:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: () => pickDate(true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFEFE7DF),
                child: Text(
                  Glb.att_from_date.isEmpty
                      ? "Click To Choose From Date"
                      : Glb.att_from_date,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= TILL DATE =================
            const Text(
              "Till Date:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: () => pickDate(false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFEFE7DF),
                child: Text(
                  Glb.att_to_date.isEmpty
                      ? "Click To Choose Till Date"
                      : Glb.att_to_date,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ================= VIEW ATTENDANCE BUTTON =================
            Center(
              child: GestureDetector(
                onTap: () {
                  if (onlinechk1) Glb.online_att = true;
                  if (offlinechk2) Glb.online_att = false;

                  if (Glb.att_from_date.isEmpty || Glb.att_to_date.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please Select date range"),
                      ),
                    );
                    return;
                  }

                  if (Glb.subwise_att) {
                    Navigator.pushNamed(context, "/HorizontalBarChart");
                  } else {
                    Navigator.pushNamed(context, "/PiePolylineChart");
                  }
                },
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6F00), Color(0xFFFFCC80)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "VIEW ATTENDANCE",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
