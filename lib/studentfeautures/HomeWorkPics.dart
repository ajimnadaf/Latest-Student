import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;
import 'package:student_app/GlobalClasses/NetworkingIO.dart';
import 'package:student_app/LoginPage/Dashboard/HomeScreen.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:mime/mime.dart';
//import 'package:open_filex/open_filex.dart' hide ResultType;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:student_app/Services/image_utils.dart' show compressImageFile;
import 'package:student_app/studentfeautures/ImageViewerScreen.dart';
import 'package:student_app/network/java_style_tlv_socket.dart';

String Today_Day = "";
String Today_Date = "";
String corrected = "", corrected_txt = "", remark_cur = "";

bool isLoading = false;

List aList = [];
String file_name = "";
bool download_hw_pic = false;
List filename_lst = [];
String fname = "";
String remark_text = "";
String appDirectoryName = "";

List shwid_lst = [], fname_lst = [], corrected_lst = [], remark_lst = [];

JavaStyleTlvSocket socket = JavaStyleTlvSocket();
final socketService = JavaStyleTlvSocket();

class HomeworkPicsScreen extends StatefulWidget {
  const HomeworkPicsScreen({super.key});

  @override
  State<HomeworkPicsScreen> createState() => _HomeworkPicsScreenState();
}

class _HomeworkPicsScreenState extends State<HomeworkPicsScreen> {
  void initState() {
    super.initState();
    today_date_day();
    onpostE();
  }

  String hwDate = "2025-12-29(Mon)";
  String hwTitle = "ABCDEF WRITE A TO Z";

  // Async function for camera tap
  Future<void> _onCameraTap() async {
    // Simulate async task
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera tapped!")),
    );
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

  // Async function for orange container tap
  Future<void> _onHwTap() async {
    // Simulate async task
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Homework container tapped!")),
    );
  }

  Future<void> onTapHomework(BuildContext context) async {
    if (Glb.hw_fname.toUpperCase() == "NA") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Sorry, Home-Work image is not attached by your teacher")),
      );
      return;
    }

    Glb.fname_cur = Glb.hw_fname;
    download_hw_pic = true;

    final String appDirectoryName =
        'TRUGUIDE/${Glb.inst_id}/${Glb.classid}/${Glb.hw_subid}/${Glb.sec_id}/${Glb.hw_teacherid_cur}/${Glb.notification_date}/HW';

    final List<Directory>? externalDirs =
        await getExternalStorageDirectories(type: StorageDirectory.pictures);

    if (externalDirs == null || externalDirs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot access external storage")),
      );
      return;
    }

    Glb.ToteachFilename = Glb.hw_fname;
    await onpost();

    final Directory imageRoot =
        Directory('${externalDirs.first.path}/$appDirectoryName');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);

    Glb.localimagePath = imageRoot.path;
    final File f = File('${Glb.localimagePath}/${Glb.hw_fname}');

    // ------------------- DOWNLOAD IF NOT EXISTS -------------------
    if (!await f.exists()) {
      Glb.ToteachFilename = Glb.hw_fname;
      await onpost(); // download and write files
    }

    // ------------------- VALIDATE FILE -------------------
    if (!await f.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File download failed")),
      );
      return;
    }

    final int size = await f.length();
    if (size == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloaded file is corrupted")),
      );
      return;
    }

    // ------------------- MIME TYPE -------------------
    String? mimeType = lookupMimeType(f.path);
    if (mimeType == null || mimeType.isEmpty) {
      mimeType = get_file_extension(Glb.fname_cur, f);
    }

    mimeType ??= '*/*';

    // ------------------- OPEN FILE -------------------
    try {
      final result = await OpenFilex.open(f.path, type: mimeType);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No app available to open this file")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to open the file")),
        );
      }
    }
  }

  void today_date_day() {
    DateTime date = DateTime.now();

    // Day abbreviation like Mon, Tue
    Today_Day = DateFormat('EEE', 'en_US').format(date);

    // Date in yyyy-MM-dd format
    Today_Date = DateFormat('yyyy-MM-dd').format(date);
  }

  Future<String> Async_Download_doc() async {
    try {
      // Set TLV type for the request
      Glb.setTlv(558);
      String sanitize(String s) =>
          s.replaceAll(RegExp(r'[\[\]\(\)#^]'), '').replaceAll(' ', '_');

      // Sanitize main filename
      String filename = sanitize(Glb.ToteachFilename);

      // Build the full server query path
      if (download_hw_pic == true) {
        Glb.query = "/var/trueguide/" +
            sanitize(Glb.inst_id) +
            "/" +
            sanitize(Glb.classid) +
            "/" +
            sanitize(Glb.hw_subid) +
            "/" +
            sanitize(Glb.sec_id) +
            "/" +
            sanitize(Glb.hw_teacherid_cur) +
            "/" +
            sanitize(Glb.notification_date) +
            "/HW/" +
            sanitize(filename);
      } else {
        Glb.query = "/var/trueguide/" +
            sanitize(Glb.inst_id) +
            "/" +
            "STUDHW" +
            "/" +
            sanitize(Glb.student_id) +
            "/" +
            sanitize(Glb.hwid_cur) +
            "/" +
            sanitize(filename);
      }

      try {
        await socket.connect(Glb.ip, Glb.port);

        Uint8List bytes = await socket.doAllNetworkImage(
          559,
          Glb.query,
        );

        socket.close();

        final file = File(
          '${Glb.localimagePath}/${Glb.fname_cur}',
        );

        await file.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);

        print("✅ Image saved: ${bytes.length} bytes");
      } catch (e) {
        print("❌ Download error: $e");
      }

      print("Glb Query is: ${Glb.query}");
      await socketService.connect(Glb.ip, Glb.port);

      String responce = await socket.doAllNetwork(559, Glb.query);
      print("responce");

      //  DOWNLOAD MAIN FILE

      // Ensure local directory exists
      Directory dir = Directory(Glb.localimagePath);
      if (!await dir.exists()) await dir.create(recursive: true);

      // Save main file
      String localFilePath = path.join(Glb.localimagePath, filename);
      File localFile = File(localFilePath);

      print("File downloaded: $filename");

      // HANDLE MULTIPLE FILES IF RESPONSE IS RECORD MODE
      if (Glb.responce.startsWith("record#")) {
        Map<String, List<String>> data = processRecords(Glb.responce);
        filename_lst = data['X^1_1'] ?? [];

        for (int i = 0; i < filename_lst.length; i++) {
          fname = filename_lst[i].trim();

          // Sanitize filename
          String safeFname = fname.replaceAll(RegExp(r'[\[\]]'), '');

          // Build server query path for each file
          if (download_hw_pic == true) {
            Glb.query = "/var/trueguide/" +
                sanitize(Glb.inst_id) +
                "/" +
                sanitize(Glb.classid) +
                "/" +
                sanitize(Glb.hw_subid) +
                "/" +
                sanitize(Glb.sec_id) +
                "/" +
                sanitize(Glb.hw_teacherid_cur) +
                "/" +
                sanitize(Glb.notification_date) +
                "/HW/" +
                sanitize(safeFname);
          } else {
            Glb.query = "/var/trueguide/" +
                sanitize(Glb.inst_id) +
                "/" +
                "STUDHW" +
                "/" +
                sanitize(Glb.student_id) +
                "/" +
                sanitize(Glb.hwid_cur) +
                "/" +
                sanitize(safeFname);
          }

          print("Glb Query is: ${Glb.query}");

          // Download each file

          File f = File(path.join(Glb.localimagePath, safeFname));
          if (!await f.exists()) {
            print("File downloaded: $safeFname");
          }
        }

        // Handle 'corrected' update if required
        if (corrected.toLowerCase() == "1" && !download_hw_pic) {
          String query =
              "update trueguide.tstudhwtbl set corrected='2' where shwid='${Glb.shwid_cur}'";

          String responce =
              await socketService.sendMessage(Glb.ip, Glb.port, query, 714);

          print("Corrected update response: $responce");
        }
      }

      return "SUCCESS";
    } catch (e) {
      print("Async_Download_doc ERROR: $e");
      return "ERROR";
    }
  }

// ------------------- onpost function -------------------
  Future<void> onpost() async {
    String check = await Async_Download_doc();

    if (!mounted) return;

    if (check.toUpperCase() == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Lost. Try Again")),
      );
      return;
    }

    if (check == "NODATA") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Data Found")),
      );
      return;
    }

    if (check.toUpperCase() == "SUCCESS") {
      final File file_path = File(path.join(Glb.localimagePath, Glb.fname_cur));
      if (!await file_path.exists() || await file_path.length() == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloaded file is corrupted")),
        );
        return;
      }

      String? ftype = get_file_extension(Glb.fname_cur, file_path);
      ftype ??= lookupMimeType(file_path.path) ?? '*/*';

      try {
        final result = await OpenFilex.open(file_path.path, type: ftype);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No app available to open this file")),
          );
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to open the file")),
        );
      }
    }
  }

  String? get_file_extension(String fileName, File fileObj) {
    // Extract extension
    int index = fileName.lastIndexOf('.') + 1;
    if (index <= 0 || index >= fileName.length) return null;

    String ext = fileName.substring(index).toLowerCase();

    // Lookup MIME type
    String? type = lookupMimeType(fileObj.path, headerBytes: null);

    // Fallback mapping (like MimeTypeMap in Java)
    if (type == null) {
      switch (ext) {
        case 'pdf':
          type = 'application/pdf';
          break;
        case 'doc':
          type = 'application/msword';
          break;
        case 'docx':
          type =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        case 'jpg':
        case 'jpeg':
          type = 'image/jpeg';
          break;
        case 'png':
          type = 'image/png';
          break;
        case 'bmp':
          type = 'image/bmp';
          break;
        case 'gif':
          type = 'image/gif';
          break;
        default:
          type = '*/*';
      }
    }

    return type;
  }

  Future<String> Async_get_all_home_work_pics_students() async {
    String query =
        "select shwid,fname,corrected,remark from trueguide.tstudhwtbl where hwid='" +
            Glb.hwid_cur +
            "' and studid='" +
            Glb.student_id +
            "'  order by shwid";
    print("Glb Query is: ${query}");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("NO DATA");
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(Glb.responce);

      shwid_lst = data['X^1_1'] ?? [];
      fname_lst = data['X^2_2'] ?? [];
      corrected_lst = data['X^3_3'] ?? [];
      remark_lst = data['X^4_4'] ?? [];
      print('shwid_lst = $shwid_lst');
      print('fname_lst = $fname_lst');
      print('corrected_lst = $corrected_lst');
      print('remark_lst = $remark_lst');
    }

    return "SUCCESS";
  }

  void onpostE() async {
    setState(() {
      isLoading = true;
    });
    String result = await Async_get_all_home_work_pics_students();

    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Connection Lost. Try Again")));
      return;
    }
    if (result.toUpperCase() == "NODATA") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NODATA")));
      return;
    }
    if (result.toUpperCase() == "SUCCESS") {
      aList.clear();
      for (int i = 0; shwid_lst != null && i < shwid_lst.length; i++) {
        corrected = corrected_lst[i].toString();
        remark_cur = remark_lst[i].toString();
        file_name = fname_lst[i].toString();
        String appDirectoryName = path.join(
          'TRUGUIDE',
          'STUDHW',
          Glb.student_id.toString(),
          Glb.hwid_cur.toString(),
        );

        Directory? picturesDir = await getExternalStorageDirectory();

        Directory imageRoot = Directory(
          path.join(
            picturesDir!.path,
            appDirectoryName,
          ),
        );

        Glb.localimagePath = imageRoot.toString();
        if (!await imageRoot.exists()) {
          await imageRoot.create(recursive: true);
        }

        File f = File('${Glb.localimagePath}/$file_name');

        if (await f.exists()) {
          if (corrected == "1") {
            await f.delete();
          }
        }

        if (corrected == "0") {
          corrected_txt = "Not Checked";
        } else {
          corrected_txt = "Checked";
        }

        if (remark_cur == "NA") {
          remark_text = "";
        } else {
          remark_text = "\nRemark : $remark_cur";
        }

        Map<String, String> hm = {
          "first": "$corrected_txt\nClick here to View Pic$remark_cur",
        };
        aList.add(hm);
        setState(() {
          isLoading = false;
        });
      }
    }
    if (isLoading) Glb.showLoadingIndicator(context);
  }

  Future<String> Async_delete_pic() async {
    String query =
        "delete from trueguide.tstudhwtbl where shwid='" + Glb.shwid_cur + "'";

    print("query : 25== : $query");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
    if (responce.startsWith("ErrorCode#0")) {
      print("Success");
    }
    if (responce.startsWith("ErrorCode#8") ||
        responce.startsWith("ErrorCode#9")) {
      print("Error");
      return "ERROR";
    }
    if (responce.startsWith("Err:")) {
      return "ERROR";
    }

    return "SUCCESS";
  }

  void onPostExecute() async {
    setState(() {
      isLoading = true;
    });
    String result = await Async_delete_pic();
    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Connection Lost. or program Faild to Update Database ")));
      return;
    }

    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomeworkPicsScreen()));
    }
  }

  Future<void> onActivityResultEquivalent(BuildContext sregContext) async {
    final picker = ImagePicker();

    // Pick image from gallery
    final XFile? data = await picker.pickImage(source: ImageSource.gallery);

    if (data == null) return; // User cancelled

    String picture_path = data.path;
    File f = File(picture_path);
    String fname = path.basename(f.path);

    Path? pathVar; // Not used, placeholder like Java
    int file_limit = 1024 * 1024 * 3;
    int result = await f.length();
    String size_in_m = (result / (1024 * 1024)).toStringAsFixed(2);

    // File size check
    if (result > file_limit) {
      ScaffoldMessenger.of(sregContext).showSnackBar(
        SnackBar(
          content: Text(
              "Too Long Image size ${size_in_m}MB. Max limit of image is 3 MB"),
        ),
      );
      return;
    }

    // Assign values to global object
    Glb.compress_image = true;
    Glb.ToteachFilename = fname;
    Glb.imagePath = picture_path;

    // Build folder path like Java
    String appDirectoryName =
        "TRUGUIDE/STUDHW/${Glb.student_id}/${Glb.hwid_cur}";

    Directory? extDir = await getExternalStorageDirectory();

    if (extDir == null) {
      ScaffoldMessenger.of(sregContext).showSnackBar(
        const SnackBar(content: Text("External storage not available")),
      );
      return;
    }

    File imageRoot = File(path.join(extDir.path, appDirectoryName));

    if (!await imageRoot.exists()) {
      await imageRoot.create(recursive: true);
    }

    Glb.localimagePath = imageRoot.path; // keep as string (like File in Java)

    onpostExecute();
  }

  Future<String> Async_set_to_exam_syllabus_path_and_download_image() async {
    String query = "select count(*) from trueguide.tstudhwtbl where fname='" +
        Glb.ToteachFilename +
        "' and instid='" +
        Glb.inst_id +
        "' and studid='" +
        Glb.student_id +
        "' and hwid='" +
        Glb.hwid_cur +
        "'  and hwdt='" +
        Today_Date +
        "'";
    print("Glb Query is: ${Glb.query}");
    String responce =
        await socketService.sendMessage(Glb.ip, Glb.port, Glb.query, 709);

    if (responce.startsWith("Err:")) {
      return "ERROR";
    }
    if (responce.startsWith("ErrorCode#2")) {
      print("NO DATA");
      return "NODATA";
    }
    if (responce.startsWith("record#")) {
      Map<String, List<String>> data = processRecords(Glb.responce);
      String data1 = data['X^1_1']![0];
      int user_count = int.parse(data1);
      print("Print INT =================: ${user_count}");

      Glb.setTlv(557);
      String filename = Glb.ToteachFilename;
      String file =
          filename.replaceAll('#', '--hash--').replaceAll('^', '--cap--');

      Glb.query = "/var/trueguide/" +
          Glb.inst_id +
          "/" +
          "STUDHW" +
          "/" +
          Glb.student_id +
          "/" +
          Glb.hwid_cur +
          "/" +
          file;
      print("Glb Query is: ${Glb.query}");
      Glb.responce =
          await socketService.sendMessage(Glb.ip, Glb.port, Glb.query, 709);

      print("Responce =================: ${Glb.query}");

      File f = File('${Glb.localimagePath}/$file');
      File originalFile = File("${Glb.localimagePath}/$file");

      XFile? compressedXFile = await compressImageFile(
        originalFile,
        quality: 80,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (compressedXFile != null) {
        print("Compressed file path: ${compressedXFile.path}");
      }

      try {
        socketService.sendImage(
            ip: Glb.ip,
            port: Glb.port,
            type: 100,
            imagePath: '${Glb.localimagePath}/${file}');

        Map<String, List<String>> data =
            processRecords('${Glb.localimagePath}/${file}');

        print("DATA");
      } catch (e) {
        print("error: $e");
      }

      if (Glb.ErrorCode.startsWith("ErrorCode#2")) {
        print("Uploaded Successfully Image");
      }
      if (Glb.ErrorCode.startsWith("ErrorCode#2")) {
        print("NO Data Found");
        return "NODATA";
      }

      String query =
          "insert into trueguide.tstudhwtbl(instid,classid,secdesc,studid,usrid,batchid,hwdt,fname,hwid,corrected,subid) values ('" +
              Glb.inst_id +
              "','" +
              Glb.classid +
              "','" +
              Glb.sec_id +
              "','" +
              Glb.student_id +
              "','" +
              Glb.userid +
              "','" +
              Glb.active_batchid +
              "','" +
              Today_Date +
              "','" +
              Glb.ToteachFilename +
              "','" +
              Glb.hwid_cur +
              "','0','" +
              Glb.hw_subid +
              "')";

      responce = await socketService.sendMessage(Glb.ip, Glb.port, query, 714);
      print("Query is : $query");
      if (responce.startsWith("Err:")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#2")) {
        return "ERROR";
      }
      if (responce.startsWith("ErrorCode#0")) {
        print("Image is Successfully .aunched");
      }

      if (user_count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This image has already uploaded.")));
        return "FAILD";
      }
    }
    return "SUCCESS";
  }

  void onpostExecute() async {
    setState(() {
      isLoading = true;
    });
    String result = await Async_set_to_exam_syllabus_path_and_download_image();

    if (result.toUpperCase() == "NODATA") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sorry No Data Found")));
      return;
    }
    if (result.toUpperCase() == "ERROR") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check You Connection And Try Again")));
      return;
    }
    if (result.toUpperCase() == "FAILD") {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This image has already uploaded.")));
      return;
    }

    if (result.toUpperCase() == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeworkPicsScreen(),
          ));
    }
  }

  Future<String> getPath_new(Uri uri) async {
    final Directory tempDir = await getTemporaryDirectory();

    final String fileName =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'temp_file';

    final File tempFile = File(path.join(tempDir.path, fileName));

    // Open content URI as file stream
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(uri);
    final HttpClientResponse response = await request.close();

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await tempFile.writeAsBytes(bytes, flush: true);

    return tempFile.path;
  }

  Future<String?> getDataColumnFlutter(Uri uri) async {
    try {
      // If already a file path
      if (uri.scheme == 'file') {
        return uri.toFilePath();
      }

      if (uri.scheme != 'content') {
        return null;
      }

      final Directory dir = await getTemporaryDirectory();
      final String fileName =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'temp_file';

      final File file = File(path.join(dir.path, fileName));

      // Read content URI as stream
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();

      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);

      await file.writeAsBytes(bytes, flush: true);

      return file.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= TOP CAMERA ICON =================
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not Allowed'),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                color: Colors.white,
                child: Row(
                  children: const [
                    Icon(
                      Icons.camera_alt,
                      size: 28,
                      color: Colors.black,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "HOME WORK PICS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),

            // ================= ORANGE DATE + TITLE BAR =================
            InkWell(
              onTap: () async {
                onTapHomework(context);
                // if (Glb.hw_fname.toUpperCase() == "NA") {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text(
                //           "Sorry, Home-Work image is not attached by your teacher"),
                //     ),
                //   );
                //   return;
                // }

                // Glb.fname_cur = Glb.hw_fname;
                // download_hw_pic = true;

                // final String appDirectoryName =
                //     'TRUGUIDE/${Glb.inst_id}/${Glb.classid}/${Glb.hw_subid}/${Glb.sec_id}/${Glb.hw_teacherid_cur}/${Glb.notification_date}/HW';

                // final Directory? baseDir = await getExternalStorageDirectory();
                // if (baseDir == null) return;

                // final Directory imageRoot =
                //     Directory('${baseDir.path}/$appDirectoryName');
                // if (!await imageRoot.exists())
                //   await imageRoot.create(recursive: true);

                // Glb.localimagePath = imageRoot.path;
                // final File f = File('${Glb.localimagePath}/${Glb.hw_fname}');

                // // DOWNLOAD IF NOT EXISTS
                // if (!await f.exists()) {
                //   Glb.ToteachFilename = Glb.hw_fname;
                //   await onpost();

                //   if (!await f.exists()) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text("File download failed")),
                //     );
                //     return;
                //   }
                // }

                // final String ext =
                //     path.extension(f.path).replaceFirst('.', '').toLowerCase();

                // // IMAGE FILES → OPEN INTERNALLY
                // if (['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif']
                //     .contains(ext)) {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => ImageViewerScreen(file: f),
                //     ),
                //   );
                //   return;
                // }

                // // NON-IMAGE FILES → OPEN EXTERNALLY using Android Intent
                // final String? mimeType = lookupMimeType(f.path);
                // if (mimeType == null) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //         content: Text("SORRY UNRECOGNISED FILE TYPE")),
                //   );
                //   return;
                // }

                // try {
                //   final intent = AndroidIntent(
                //     action: 'action_view',
                //     data: f.path,
                //     type: mimeType,
                //     flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                //   );
                //   await intent.launch();
                // } catch (e) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //         content: Text("No activity to handle this file: $e")),
                //   );
                // }
              },
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFFB300),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " HOME WORK : ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.edit, size: 18, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          "Click To View Home Work Doc",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // ================= WHITE CONTENT CONTAINER =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: aList.length,
                itemBuilder: (context, index) {
                  final String item = aList[index];

                  return GestureDetector(
                    onTap: () {
                      showHWOptionsDialog(context: context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          item,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showHWOptionsDialog({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Click Here To"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["View Pic", "Delete Pic"].map((option) {
            return ListTile(
              title: Text(option),
              onTap: () async {
                Navigator.of(ctx).pop();
                for (int i = 0; shwid_lst.length > 0; i++) {
                  Glb.shwid_cur = shwid_lst[i].toString();
                  Glb.fname_cur = fname_lst[i].toString();
                  corrected = corrected_lst[i].toString();

                  if (option == "View Pic") {
                    String appDirectoryName = "TRUGUIDE/" +
                        "STUDHW" +
                        "/" +
                        Glb.student_id +
                        "/" +
                        Glb.hwid_cur;

                    final Directory imageRoot =
                        await getImageRootDirectory(appDirectoryName);

                    Glb.localimagePath = imageRoot.toString();
                    File f = File(
                      path.join(Glb.localimagePath, Glb.fname_cur),
                    );
                    download_hw_pic = false;
                    if (f.exists() == false) {
                      Glb.ToteachFilename = Glb.fname_cur;
                      final Directory imageRoot =
                          await getImageRootDirectory(appDirectoryName);
                      if (!await imageRoot.exists()) {
                        await imageRoot.create(recursive: true);
                      }
                      Glb.localimagePath = imageRoot.toString();
                      onpost();
                      return;
                    }
                    if (f.exists() == true) {
                      File filePath =
                          File(path.join(Glb.localimagePath, Glb.fname_cur));

                      String? ftype =
                          get_file_extension(Glb.fname_cur, filePath);

                      if (ftype == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Sorry, file type not recognized")));
                        return;
                      }

                      try {
                        final result = await OpenFilex.open(filePath.path);

                        if (result.type != ResultType.done) {
                          // No app could handle this file

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "no Activity to handle this kind of files")));
                        }
                      } catch (e) {
                        // Catch any unexpected errors
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to open file: $e")));
                      }
                    }
                  } else if (option == "Delete Pic") {
                    int cor = int.parse(corrected);
                    if (cor >= 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Sorry, images once corrected cannot be deleted.")),
                      );
                      return;
                    } else {
                      onPostExecute();
                    }
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<Directory> getImageRootDirectory(String appDirectoryName) async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // App-specific external storage on Android
      baseDir = (await getExternalStorageDirectory())!;
    } else if (Platform.isIOS) {
      // Documents directory on iOS
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    final Directory imageRoot =
        Directory(path.join(baseDir.path, appDirectoryName));

    if (!await imageRoot.exists()) {
      await imageRoot.create(recursive: true);
    }

    return imageRoot;
  }
}
