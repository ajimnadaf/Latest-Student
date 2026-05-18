import 'package:flutter/material.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:student_app/native_opener.dart';

SocketService socketService = SocketService();
List syldatadescimglink_lst = [];
List filenames_lst = [];

List<Data_Upload_Syllabus> uploadDataList = [];

class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({Key? key}) : super(key: key);

  @override
  State<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends State<StudyMaterialPage> {
  @override
  void initState() {
    super.initState();

    // ===== CLEAR FILE DATA =====
    if (Glb.auto_id_lst != null && Glb.auto_id_lst.isNotEmpty) {
      Glb.filenames_lst.clear();
      Glb.auto_id_lst.clear();
      Glb.syldatadesc_lst.clear();
    }

    // ===== CLEAR CONCEPT DATA =====
    if (Glb.conceptid_lst != null && Glb.conceptid_lst.isNotEmpty) {
      Glb.conceptid_lst.clear();
      Glb.concept_lst.clear();
      Glb.sdtid_lst.clear();
    }

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

  /// SAMPLE DATA (Replace with API data later)
  List<Map<String, String>> materialList = [
    {
      "title": "Auxospores and hormocysts are formed respectively by",
      "type": "unrecog",
    },
    {
      "title": "Angiosperm - NCERT - Plant Kingdom | Class 11 Biology",
      "type": "unrecog",
    },
    {
      "title":
          "Diversity in Living World in Hindi | Class 11 | NCERT NEET Notes",
      "type": "unrecog",
    },
  ];

  Future<String> Async_get_already_sent_files() async {
    String query =
        "select sdtid,fname,syldatadesc,syldatadescimglink from trueguide.syldatatbl   where instid='" +
            Glb.inst_id +
            "' and classid='" +
            Glb.classid +
            "' and subid='" +
            Glb.sub_id_cur +
            "' and subindexid='" +
            Glb.sub_index_id_cur +
            "'";

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
      Glb.auto_id_lst = data['X^1_1'] ?? [];
      Glb.filenames_lst = data['X^2_2'] ?? [];
      Glb.syldatadesc_lst = data['X^3_3'] ?? [];
      syldatadescimglink_lst = data['X^4_4'] ?? [];

      print("auto_id_lst : ${Glb.auto_id_lst}");
      print("filenames_lst : ${Glb.filenames_lst}");
      print("syldatadesc_lst: ${Glb.syldatadesc_lst}");
      print("syldatadescimglink_lst: ${syldatadescimglink_lst}");
    }

    query =
        "select conceptid,concept,sdtid from trueguide.tconceptbindtbl where instid='" +
            Glb.inst_id +
            "' and classid='" +
            Glb.classid +
            "' and subid='" +
            Glb.sub_id_cur +
            "' and subindexid='" +
            Glb.sub_index_id_cur +
            "' order by oder";

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

      Glb.conceptid_lst = data['X^1_1'] ?? [];
      Glb.concept_lst = data['X^2_2'] ?? [];
      Glb.sdtid_lst = data['X^3_3'] ?? [];

      print("conceptid_lst : ${Glb.conceptid_lst}");
      print("concept_lst : ${Glb.concept_lst}");
      print("sdtid_lst : ${Glb.sdtid_lst}");
    }

    return "SUCCESS";
  }

  void Onpost() async {
    String check = await Async_get_already_sent_files();

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
      List fname = [];
      if (filenames_lst != null) {
        List<String> fname = [];

        for (int z = 0; z < filenames_lst.length; z++) {
          String fname_cur = filenames_lst[z]
              .replaceAll("--hash--", "#")
              .replaceAll("--cap--", "^")
              .replaceAll("--and--", "&");

          fname.add(fname_cur);
        }

        filenames_lst = fname;
      }

      await get_already_sent_images();
      setState(() {
        uploadDataList = fill_with_data();
      });
    }
  }

  String getURLForResource(String resourceName) {
    return "assets/images/$resourceName";
  }

  Future<void> get_already_sent_images() async {
    // SAME AS: sub = sreg.glbObj.sub_name_cur;
    String sub = Glb.sub_name_cur;

    // ===== Get Base Directory (Android + iOS Safe) =====
    Directory baseDir = await getApplicationDocumentsDirectory();

    // SAME AS:
    // sppath_str + "/TRUGUIDE/SYLSUBIND/sub_index_id"
    String sppathStr =
        "${baseDir.path}/TRUGUIDE/SYLSUBIND/${Glb.sub_index_id_cur}";

    Directory f1 = Directory(sppathStr);

    // SAME AS:
    // sreg.glbObj.localimagePath = f1;
    Glb.localimagePath = sppathStr;

    // ===== CLEAR OLD DATA =====

    if (Glb.file_exist_lst != null && Glb.file_exist_lst.isNotEmpty) {
      Glb.file_exist_lst.clear();
    }

    if (Glb.file_type != null && Glb.file_type.isNotEmpty) {
      Glb.file_type.clear();
    }

    if (Glb.file_type == null) {
      Glb.file_type = [];
    } else {
      Glb.file_type.clear();
    }

    // ===== MAIN LOOP =====

    for (int i = 0;
        Glb.filenames_lst != null && i < Glb.filenames_lst.length;
        i++) {
      String file_name = Glb.filenames_lst[i].toString();

      String fullPath = "${Glb.localimagePath}/$file_name";

      print("File==========$fullPath");

      File f = File(fullPath);

      // ===== CHECK FILE EXISTS =====

      if (await f.exists()) {
        Glb.file_exist_lst.add("1");
      } else {
        Glb.file_exist_lst.add("0");
      }

      // ===== GET FILE EXTENSION =====

      String ft = get_file_extension(file_name);

      Glb.file_type.add(ft);
    }

    // ===== LOAD DATA INTO UI =====

    List data = fill_with_data();
  }

  List<Data_Upload_Syllabus> fill_with_data() {
    List<Data_Upload_Syllabus> data = [];

    for (int i = 0; i < Glb.filenames_lst.length; i++) {
      String fe = Glb.file_exist_lst[i].toString();

      String op = "";

      String filetype = Glb.filenames_lst[i].toString();

      String autoid_cur = Glb.auto_id_lst[i].toString();

      String syldatadesc_cur = Glb.syldatadesc_lst[i].toString();

      String syldatadescimglink_cur = syldatadescimglink_lst[i].toString();

      List all_concept_indicess = [];

      String text = "";

      // ===== MATCH SDTID =====
      if (Glb.sdtid_lst != null) {
        for (int j = 0; j < Glb.sdtid_lst.length; j++) {
          String sdtid_cur = Glb.sdtid_lst[j].toString();

          if (autoid_cur.toLowerCase() == sdtid_cur.toLowerCase()) {
            all_concept_indicess.add(j);
          }
        }
      }

      // ===== URL CHECK (SAME AS JAVA) =====
      bool isUrl = Uri.tryParse(filetype)?.isAbsolute ?? false;

      if (isUrl) {
        op = "[View]";
      } else {
        if (fe == "0") {
          op = " [Download Material]";
        }

        if (fe == "1") {
          op = " [View Material]";
        }
      }

      // ===== MIME =====
      String mime_type = "";

      if (isUrl) {
        // URL → force unrecog
        mime_type = "unrecog";
      } else {
        if (Glb.file_type[i] == null || Glb.file_type[i].toString().isEmpty) {
          mime_type = "unrecog";
        } else {
          mime_type = Glb.file_type[i].toString();
        }
      }

      print("MIME=====$mime_type");

      // ===== ICON + TEXT =====

      if (mime_type.contains("image/")) {
        text = "Click Here To$op";
      }

      if (mime_type.contains("application/")) {
        text = "Click Here To$op";
      }

      if (mime_type.contains("video/")) {
        text = "Click Here To$op";
      }

      if (mime_type.contains("audio/")) {
        text = "Click Here To$op";
      }

      if (mime_type.contains("text/")) {
        text = "Click Here To$op";
      }

      if (mime_type.contains("unrecog")) {
        text = "Click Here To Open The Link";
      }

      // ===== CONCEPT STRING =====

      String concepts_str = "";

      if (all_concept_indicess.isEmpty) {
        concepts_str = "Please attach Concepts covered in materal";
      } else {
        String cncp_cat = "Concepts Covered: ";

        for (int k = 0; k < all_concept_indicess.length; k++) {
          int ind = int.parse(all_concept_indicess[k].toString());

          if (k == 0) {
            cncp_cat += Glb.concept_lst[ind].toString();
          } else {
            cncp_cat += "," + Glb.concept_lst[ind].toString();
          }
        }

        concepts_str = cncp_cat;
      }

      // ===== FILETYPE CHECK =====

      if (!isUrl) {
        filetype = "NA";
      }

      // ===== ADD DATA =====

      data.add(
        Data_Upload_Syllabus(
          syldatadescimglink_cur,
          syldatadesc_cur,
          mime_type,
          concepts_str,
          filetype,
        ),
      );
    }

    print("Data:============= $data");

    return data;
  }

  String get_file_extension(String fileName) {
    int index = fileName.lastIndexOf('.') + 1;

    if (index <= 0 || index >= fileName.length) {
      return "unrecog";
    }

    String ext = fileName.substring(index).toLowerCase();

    String? type = lookupMimeType("file.$ext");

    return type ?? "unrecog";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// APPBAR
      appBar: AppBar(
        title: const Text(
          "STUDY MATERIAL",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// BODY
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: uploadDataList.length,
        itemBuilder: (context, index) {
          return buildMaterialCard(uploadDataList[index]);
        },
      ),
    );
  }

  /// CARD UI
  Widget buildMaterialCard(Data_Upload_Syllabus data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ORANGE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA500),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Text(
              data.syldatadesc_cur, // ✅ TITLE
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// GREY BODY
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFEDEDED),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FILE TYPE
                Text(
                  "File Type: ${data.mime_type}", // ✅ TYPE
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                /// CONCEPTS
                Text(
                  data.concepts_str, // ✅ DESCRIPTION
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 18),

                /// VIEW BUTTON
                Center(
                  child: InkWell(
                    onTap: () async {
                      String path = data.material_url; // URL or local file

                      await NativeOpener.open(path);
                    },
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF7A00),
                            Color(0xFFFFD194),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "VIEW MATERIAL",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Data_Upload_Syllabus {
  String syldatadescimglink_cur;
  String syldatadesc_cur;
  String mime_type;
  String concepts_str;
  String material_url;

  Data_Upload_Syllabus(
    this.syldatadescimglink_cur,
    this.syldatadesc_cur,
    this.mime_type,
    this.concepts_str,
    this.material_url,
  );
}
