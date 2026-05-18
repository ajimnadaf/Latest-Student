import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:student_app/LoginPage/Dashboard/Dashboard.dart';

String ip = "101.53.149.18";
int port = 3333;
int currentHostIndex = 0;

Map<String, List<dynamic>> all_ex_sub_map = {};
Map<String, List<dynamic>> all_ex_tot_map = {};
Map<String, List<dynamic>> all_ex_obt_map = {};
Map<String, String> sub_marks_legend = {};
Map<String, String> Days_to_Date = {};
Map<String, SubjectObj>? SubMap;

Uint8List responceBytes = Uint8List(0);

bool ips_fetched = false, fileOp = true;
bool restart = false;
bool dont_disconnect = false;
bool epoch_taken = false;
bool is_subscribed = false;
bool noti_remind_later = false;
bool subwise_att = false;
bool ids_only = false;
bool compress_image = false;
bool online_att = false;
bool study_index = false;
bool study_concept = false;
bool study_sub_index = false;

List View_todayTT_timetblid = [];
List upcmng_Invigi_name = [];

String localimagePath = "";
String downloadDirPath = "";
String ErrorCode = "", syl_coverage_subid_cur = "";
String subject_name = "";
String upcoming_exid_cur = "";

int error_code = 0;
int usr_ind = 0;
int prof_ind = 0;
int dt_ind = 0;

List main_stud_usrid_lst = [];
bool enable_devid = true;
List noti_nid_lst = [];
List noti_count_lst = [];
List info_lst = [];
List nfrom_lst = [];
List noti_type_lst = [];
List nfrome_name_lst = [];
List nfrom_uid_lst = [];
List pbgroup_lst = [];
List distinct_examname_lst = [];
List subname_lst = [], marks_total_lst = [], marks_obtained_lst = [];

String app_version_in_db = "";
//String examname = "";
String app_link = "";
String link = "";
String Hostnames = "101.53.149.18:3333";
String version = "";
String devinf = "";
String dltype = "";

String student_name = "";
String custadvurl_cur = "";
String ctype_cur = "";
String stu_id = "";
String father_name = "";
String inst_adtp_cur = "";
String up_info_flag = "";
String mother_name = "";
String student_contact = "";
String fcontact = "";
String mcontact = "";
String date_of_birth = "";
String aadhar_no = "";
String present_address = "";
String permanant_addr = "";
String email_id = "";
String gender = "";
String blood_group = "";
String admission_no = "";
String stsno = "";
String usnno = "";
String caste = "";
String category = "";
String religion = "";
String height = "";
String weight = "";
String tot_max_mark = "";
String tot_obt_mark = "";
String exam_id_curr = "";
String ToteachFilename = "";
String responce = "";

List distinct_date = [];

String rcv_password = "";
String devid = "";
String fbmsgdevid = "";
String fbmsgtkn = "";
String dplink = "";

List distinct_date_noti = [];

String total_trans_of_year = "";

String amount_trans = "";
String trans_email = "";
String trans_contact_no = "";
String pgtwtype_cur = "";
String rzkey_cur = "";
String rzpass_cur = "";
String sbpsclientcode_cur = "";
String sbpsusrname_cur = "";
String sbpspasswd_cur = "";
String sbpsauthkey_cur = "";
String svpsauthiv_cur = "";
List<String> update_info_lst = [];

int tot_concepts = 0;
int tot_materials = 0;
int concept_counter = 0;
int concept_material_counter = 0;

List syldatadesc_lst = [], main_stud_usrname_lst = [];
List auto_id_lst = [];
List qconcept_id_lst = [];
List file_exist_lst = [];
List islink = [];
List qconcept_name_lst = [];
List conceptid_lst = [];
List concept_lst = [];
List sdtid_lst = [];

List autoId_lst = [];
List filenames_lst = [];
List file_type = [];
List filter_id_lst = [];
List filter_subindexid_lst = [];
List filter_indexid_lst = [];
List filter_conceptid_lst = [];

String fname_cur = "";
String today_noti_count = "";
String mobno = "";
String cnfrmpass = "";
String hw_subid = "";
String fw_dt = "";
String shwid_cur = "";
String edit_image = "";
String qconid = "";
String hwid_cur = "";
String hw_fname = "";
String filter_query = "";
String reg_instid = "";
String false_ttid_cur = "";
String atttype_cur = "";
String View_todayTT_subtype_cur = "";
String division_cur = "";
String question_str_cur = "";
String false_dt = "";
String auto_id_cur = "";
String ToteachFilename_q = "";
String screen = "";
String uid = "";
String ToteachFilename_op1 = "";
String ToteachFilename_op2 = "";
String ToteachFilename_op3 = "";
String hw_desc = "";
String ToteachFilename_op4 = "";
String Link_Lids = "";

String selected_online_exmid = "";
String subtypelst_cur = "";
String exam_end_time = "";
String selected_online_exmname = "";
String selected_online_exmdate = "";
String exam_start_time = "";
String tot_questions_str = "";
String tot_exm_marks_str = "";
String fpath = "";
String niti_from_uid = "";
String noti_info = "";
String notitype_cur = "";
String insttype_cur = "";
String notiinfo_cur = "";
String noti_from = "";
String noti_from_name = "";
String nepoch = "";
String rep_nrid_cur = "";
String tlvStr2 = "";
String doc = "";
String notiid_cur = "";
String sub_index_id_cur = "";
String index_id_cur = "";
String index_name_curr = "";
String contact_no = "";
String instname_ref = "";
String attend_type = "";
String batchid_cur = "";
String active_batchid = "";
String logo_name = "";

List concept_files_to_download = [];
List embedinapp_lst = [];
List conf_ttid_lst = [];
List subtype_lst = [];
List subdiv_lst = [];
List conf_link_lst = [];
List false_ttid_lst = [];
List false_subindexid_lst_new = [];
List false_indexid_lst_new = [];
List exm_qid_lst = [];
List exametime_eme = [];
List examid_eme_lst_opt = [];
List examname_eme = [];
List examdate_eme = [];
List examstime_eme = [];
List total_exam_ques = [];
List tot_exam_marks = [];
List att_subid_lst = [];
List batchid_lst = [];
List sub_index_id_lst = [];
List sub_index_name_lst = [];
List active_batch_name = [];
List index_id_lst = [];
List index_name_lst = [];
List View_todayTT_status = [];
List View_tomTimeTblStatus = [];
List teacherdcssid_lst = [];
List ctype_lst = [];
List year_lst = [];
List atttype_lst = [];
List consent_teacher_name = [];
List consent_subject = [];
List consent_ttid_count = [];
List concession_lst = [];
List balance_lst = [];
List paid_fees_lst = [];
List total_fees_lst = [];
List last_trans_lst = [];
List trans_date_lst = [];
List fees_paid_lst = [];
List mode_lst = [];
List scholarship_lst = [];
List checkno_lst = [];
List checkdate_lst = [];
List bankname_lst = [];
List ddno_lst = [];
List dddate_lst = [];
List scholtype_lst = [];
List scholid_lst = [];
List remark_lst = [];
List sftransid_lst = [];
List lm_due_date_lst = [];
List lm_issue_date_lst = [];
List lm_bstatus_lst = [];
List lm_publishr_lst = [];
List lm_edition_lst = [];
String Module_ID = "academic";
String Role_id = "student";
String sftransid_cur = "";
String rep_role = "";
String examname = "";
String examsylid_cur = "";
String lm_catid_cur = "";
String question_cur = "";
String optid_cur = "";
String sysDate = "";
String leave_day = "";
String long_lst = "";
String lat_lst = "";
String driverid_lst_cur = "";
String routid_lst_cur = "";
String routeid = "";
String tripfrom_cur = "";
String tripto_cur = "";
String sfid_lst = "";
List date_lst = [];
List driverid_lst = [];
List routid_lst = [];
List fther_occid_lst = [];
List caste_nameid_lst = [];

List pinstids = [];
List psubids = [];
List pclassids = [];
List exid_perf_lst_opt = [];
List inst_expiry_lst = [];
List inst_status_lst = [];
String pinstids_cur = "";
String psubids_cur = "";
String pclassids_cur = "";
String examid_cur = "";
String tdy_date = "";
String todayDay = "", tommorow = "", att_from_date = "", att_to_date = "";
String from_feature = "";
String sub_indexid_cur = "";
String pic_type = "";
String qid_str = "";
String inst_expiry_cur = "";
String inst_status_cur = "";
String server_epoch = "";
String server_date = "";
String Toteachid = "";
List location_lst = [];
List duration_lst = [];
List distance_lst = [];
List origin_lst = [];
List tripfrom_lst = [];
List tripto_lst = [];
List time_lst = [];
String address = "";
String duration = "";
String distance = "";
String origin_addresses = "";
String feedback_role = "";
List nfromlst = [];
List nfromuid_lst = [];
List ntype_lst = [];
List ninfo_lst = [];
int pic_count = -1;
int cur_q_ind = 0;
String ndate_cur = "";
String nepoch_cur = "";
String nfromuid_cur = "";
String nfrom_cur = "";
String ntouid_cur = "";
String ntorole_cur = "";
String ntype_cur = "";
String ninfo_cur = "";
List db_ntype_lst = [];
List db_nclassid_lst = [];
List db_nsecdesc_lst = [];
List db_ninfo_lst = [];
List db_nfromuid_lst = [];
List db_nfrom_lst = [];
List db_nid_lst = [];
String perf_since = "";
String notification_date = "";
String nid_cur = "";
String smsquota_lst_cur = "";
List nid_lst = [];
List epoch_lst = [];
List adv_lst = [];
List smsquota_lst = [];
List index_lst = [];
List sub_index_lst = [];

String SubIds_cur = "";
String main_index = "";
String sub_index_cur = "";
String cur_subject_index = "";
List issubindx_lst = [];
List topic_lst = [];

List sub_topic_lst = [];
String View_todayTT_subname_cur = "";
String ex_sub_name_cur = "";
String adv_cur = "";
String country_code = "";
String full_path = "";
String state_code = "";
String dist_code = "";
String city_code = "";
String TeacherID_Cur = "";
bool new_reg = true;
String tlvStr = "";
String mobileno = "";
String userid = "";
String hw_teacherid_cur = "";
String classid = "";
String sec_id = "";
String otp = "";
String student_id = "";
String sub_id_cur = "";
String inst_id = "";
String classid_cur = "";
String sub_id_count = "";
String class_name = "";
String roll_cur = "";
String studid_cur = "";
String sec_id_cur = "";
String reg_instname = "";
String sec_name = "";
String roll_no = "";
String classid_prof_cur = "";
List<String> sub_id = [];
List<String> sub_name = [];
List<String> inst_name = [];
List<String> instid = [];
List<String> secnamesList = [];
List<String> classid_prof = [];
List<String> class_names_prof = [];
List<String> sec_id_prof = [];
List<String> inst_type = [];
List<String> roll_list = [];
List<String> studid_list = [];

String class_name_cur = "";
String main_feature = "";
String inst_name_cur = "";
String student_instname_cur = "";
String student_insttype_cur = "";
String inst_id_reg = "";
String class_names_cur = "";
String check_opt_gen = "";
String ExamId_for_img = "";
String instid_for_det = "";

List student_id_lst = [];
List inst_id_lst = [];
List classid_lst = [];
List sec_id_lst = [];
List roll_no_lst = [];
List Status_lst = [];
List stud_insttype_cur_lst = [];
List instname_lst = [];
int approved_inst_count = -1;
int unapp_inst_count = -1;
String Status = "";
String rollno = "";
String imagePath = "";
String sysTime = "";
String profilepicname = "";
String day = "";
List sect_lst = [];
String sec_lst_cur = "";
List jobdid = [];
List title_lst = [];
List jd_lst = [];
List pakage_lst = [];
List dt_lst = [];
List opp_lst = [];
List inst_lst = [];
int shift = -1;
int tilt = -1;
String View_todayTT_timetblid_cur = "";
List View_todayTT_teacherID = [];
String View_todayTT_teacherID_cur = "";
List Check_mockStatus = [];
List View_tomTime_timetblId_lst_opt = [];
List View_fullTime_timetblId_lst_opt = [];
String Check_mockStatus_cur = "";
String Check_mockClassid_cur = "";
String Check_mockSec_cur = "";
String Check_mockRoll_cur = "";
String Check_mockInstid_cur = "";
String Check_mockUsrid_cur = "";
List Check_mockStudid = [];
List Check_mockInstid_lst = [];
String Check_mockStudid_cur = "";
String class_sub_id_count = "";
int inst_created = 1;
List View_todayTT_subid = [];
String View_todayTT_subid_cur = "";
List View_todayTT_starttime = [];
String View_todayTT_starttime_cur = "";
List CheckJoinedSub = [];
String CheckJoinedSub_cur = "";
List sectorname_lst = [];
List instid_lst = [];
List corpid_lst = [];
List sectorid_lst = [];
List coubt_lst = [];
List View_todayTT_endtime = [];
String View_todayTT_endtime_cur = "";
List View_todayTT_roomno = [];
String View_todayTT_roomno_cur = "";
List View_todayTT_Username = [];
String Faculty_tt_cur = "";
List View_todayTT_Lastname = [];
List View_todayTT_MobileNo = [];
List View_todayTT_userid = [];
String View_todayTT_userid_cur = "";
String date = "";
List FileNamesToTeach = [];
String FileNamesToTeach_cur = "";
String total_classes_taken = "";
String total_attended_classes = "";
String percentage = "";
List FileNamesclassnotes = [];
String FileNamesclassnotes_cur = "";
List FileNamesclassTask = [];
String FileNamesclassTask_cur = "";
String nextdayTom = "";
List View_tomTimeTblId = [];
String View_tomTimeTblId_cur = "";
List View_tomTimeTblTeacherId = [];
String View_tomTimeTblTeacherId_cur = "";
List View_tomTimeTblStartTime = [];
String View_tomTimeTblStartTime_cur = "";
List View_tomTimeTblSubids = [];
String View_tomTimeTblSubids_cur = "";
List View_tomTimeTblEndTime = [];
String View_tomTimeTblEndTime_cur = "";
List View_tomTimeTblRoomno = [];
String View_tomTimeTblRoomno_cur = "";
String selected_day = "";
List ExamId_MyPerf = [];
String ExamId_MyPerf_cur = "";
List Examname_MyPerf = [];
String Examname_MyPerf_cur = "";
List Marksobt_MyPerf = [];
String Marksobt_MyPerf_cur = "";
List totalMrks_MyPerf = [];
String totalMrks_MyPerf_cur = "";
List My_atend_perf_StartTime = [];
String My_atend_perf_StartTime_cur = "";
List My_atend_perf_EndTime = [];
String My_atend_perf_EndTime_cur = "";
List My_atend_perf_TimetblId = [];
String My_atend_perf_TimetblId_cur = "";
String todays_date = "";
List upcmng_perf_ExmId = [];
String upcmng_perf_ExmId_cur = "";
List upcmng_perf_SubId = [];
String upcmng_perf_SubId_cur = "";
List upcmng_perf_Exmname = [];
String upcmng_perf_Exmname_cur = "";
List psubid_lst = [];
List psubname_lst = [];
List psubtype_lst = [];
int sub_ind = 0;
List upcmng_perf_ExmDate = [];
String upcmng_perf_ExmDate_cur = "";
List upcmng_perf_startime = [];
String upcmng_perf_startime_cur = "";
List upcmng_perf_endtime = [];
String upcmng_perf_endtime_cur = "";
String calculatedweekday = "";
List My_atende_perf_attendid = [];
String My_atende_perf_attendid_cur = "";
List My_atende_perf_status = [];
String My_atende_perf_status_cur = "";
String claculatemonthday = "";
List View_exm_TT_TeacherID = [];
String View_exm_TT_TeacherID_cur = "";
List View_exm_TT_UserID = [];
String View_exm_TT_UserID_cur = "";
List View_exm_TT_username = [];
String View_exm_TT_username_cur = "";
List View_exm_TT_Filename = [];
String View_exm_TT_Filename_cur = "";
String View_exm_TT_ExamnotesFilename_cur = "";
List View_exm_TT_ExamnotesFilename = [];
String password = "";
String status = "";
List View_tomTT_userid = [];
String View_tomTT_userid_cur = "";
List View_tomTT_Username = [];
List View_tomTT_Lastname = [];
List View_tomTT_MobileNo = [];
List View_FullweekTT_userid = [];
String View_FullweekTT_userid_cur = "";
List View_FullweekTT_username = [];
List My_atende_perf_timetblid = [];
String My_atende_perf_timetblid_cur = "";
List My_atende_perf_attdate = [];
String My_atende_perf_attdate_cur = "";
List View_todaysTime_timetblId_lst_opt = [];
String ttid_cur = "";
String classAssign_count_lst = "";
String classnotes_count_lst = "";
String classtask_count_lst = "";
String toteach_count_lst = "";
String className = "";
String studentRoll = "";
String studentName = "";
List upcoming_exid_lst_opt = [];
String up_ex_id = "";
List teacherid_view_up_exms_lst_opt = [];
String teacherid_up_coming_exm = "";
String examid_perf_cur = "";
String sub_name_cur = "";
String total_classes_count_atend_perf = "";
String status_sum_atend_perf = "";
String selected_att_since = "";
String reg_cur_inst_type = "";
String toteach_pic_count = "";
String classnotes_pic_count = "";
String classtask_pic_count = "";
String classassign_pic_count = "";
String sub_feature = "";
String Syllabus_count = "";
String assignmet_text_count = "";
String notes_text_count = "";
String class_task_text_count = "";
String toteach_text_count = "";
String pic_feature = "";

String query = "";
int reqType = 0;

// Place this inside Glb.dart or a utility class
String replaceSpecial(String input) {
  // Replicates Java: input.replaceAll("_", "").replaceAll("&", "")...
  return input.replaceAll(RegExp(r"[_&.@#?+'$=+]"), "");
}

showLoadingIndicator(BuildContext context) {
  return Positioned.fill(
    child: Container(
      color: Colors.black.withOpacity(0.5), // Faint the background
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 200, // Control the width of the loading box
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 15),
              Text(
                'Loading....',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class updateStudentDetailsToSocket {
  updateStudentDetailsToSocket(Map<String, dynamic> updatedData);
}

List<String> getSubjects() {
  Set<String> subjects = {};
  all_ex_sub_map.forEach((exam, subList) {
    subjects.addAll(subList.cast<String>()); // <-- cast here
  });
  return subjects.toList();
}

class fetchStudentDetailsFromSocket {}

class updateStudentField {
  updateStudentField(String field, String value);
}

class get_generic_ex {
  get_generic_ex(String questionQuery);
}

void setTlvString() {
  query = getTlvStr(reqType);
}

void setTlv(int type) {
  reqType = type;
  setTlvString();
}

String getTlvStr(int type) {
  String tlvStr = "";

  if (type == 9) {
    tlvStr = "tusertbl.mobno\\#'${mobileno}'&tusertbl.status\\#'0'";
  } else if (type == 6) {
    tlvStr = "otptabel.usrid\\#'${userid}'&otptabel.mobno\\#'${mobileno}'";
  } else if (type == 7) {
    tlvStr =
        "otptabel.1_usrid\\#?&otptabel.1_otp_\\#='${otp}'&otptabel.2_mobno_?\\#='${mobileno}'";
  } else if (type == 8) {
    tlvStr =
        "pinsttbl.1_instid\\#?&pinsttbl.2_instname\\#?&pinsttbl.3_address\\#?&pinsttbl.4_chairpersonname\\#?&pinsttbl.5_chairpersonnum\\#?&pinsttbl.6_city\\#?&pinsttbl.7_area\\#?&pinsttbl.8_street\\#?&pinsttbl.9_landmark\\#?&pinsttbl.9a_type\\#?&pinsttbl.1_status_\\#='1'";
  } else if (type == 10) {
    tlvStr =
        "tusertbl.1_usrid\\#?&tusertbl.2_status\\#?&tusertbl.1_mobno_\\#='${mobileno}'&tusertbl.2_password_?\\#='${password}'";
  } else if (type == 4) {
    tlvStr =
        "otptabel.1_otp\\#?&otptabel.1_usrid_\\#'${userid}'&otptabel.mobno_?\\#='${mobileno}'";
  } else if (type == 11) {
    tlvStr =
        "tstudenttbl.1_studid\\#?&tstudenttbl.2_instid\\#?&tstudenttbl.3_classid\\#?&tstudenttbl.4_secdesc\\#?&tstudenttbl.5_rollno\\#?&tstudenttbl.6_status\\#?&tstudenttbl.7_usrid\\#?&tstudenttbl.8_batchid\\#?&tstudenttbl.9_ctype\\#?&tstudenttbl.9a_year\\#?&tstudenttbl.1_usrid_\\#='${userid}'&tstudenttbl.2_status_?\\#='1'";
  } else if (type == 12) {
    tlvStr =
        "pclasstbl.1_classname\\#?&pclasstbl.2_classid\\#?&pclasstbl.3_type\\#?&pclasstbl.1_classid_\\#='${classid}'";
  } else if (type == 13) {
    tlvStr = "psectbl.1_secname\\#?&psectbl.1_secid_\\#='${sec_id_cur}'";
  } else if (type == 14) {
    tlvStr =
        "tstudsubtbl.1_count(*)\\#?&tstudsubtbl.1_studid_\\#='${student_id}'&tstudsubtbl.2_instid_?\\#='${inst_id}'&tstudsubtbl.3_classid_?\\#='${classid}'&tstudsubtbl.4_secdesc_?\\#='${sec_id}'&tstudsubtbl.5_rollno_?\\#='${roll_no}'";
  } else if (type == 15) {
    tlvStr =
        "psubtbl.1_subname\\#?&psubtbl.2_subid\\#?&psubtbl.3_deptid\\#?&psubtbl.4_type\\#?&psubtbl.5_classid\\#?&psubtbl.1_subid_\\#='${sub_id_cur}'";
  } else if (type == 17) {
    tlvStr =
        "tinstclasstbl.1_classid\\#?&tinstclasstbl.2_instid\\#?&tinstclasstbl.3_instclassid\\#?&tinstclasstbl.1_instid_\\#='${inst_id_reg}'";
  } else if (type == 18) {
    tlvStr =
        "pclasstbl.1_classname\\#?&pclasstbl.2_classid\\#?&pclasstbl.3_type\\#?&pclasstbl.1_classid_\\#='${classid}'";
  } else if (type == 19) {
    tlvStr =
        "tclasectbl.1_secdesc\\#?&tclasectbl.2_classid\\#?&tclasectbl.3_instid\\#?&tclasectbl.4_clasecid\\#?&tclasectbl.5_roomno\\#?&tclasectbl.1_classid_\\#='${classid_cur}'&tclasectbl.2_instid_?\\#='${inst_id_reg}'";
  } else if (type == 20) {
    tlvStr = "psectbl.1_secname\\#?&psectbl.1_secid_\\#='${sec_id_cur}'";
  } else if (type == 21) {
    tlvStr =
        "tstudenttbl.1_studid\\#?&tstudenttbl.2_status\\#?&tstudenttbl.3_classid\\#?&tstudenttbl.4_secdesc\\#?&tstudenttbl.5_rollno\\#?&tstudenttbl.6_usrid\\#?&tstudenttbl.7_instid\\#?&tstudenttbl.8_batchid\\#?&tstudenttbl.1_instid_\\#='${inst_id}'&tstudenttbl.2_classid_?\\#='${classid_cur}'&tstudenttbl.3_secdesc_?\\#='${sec_id_cur}'&tstudenttbl.4_rollno_?\\#='${roll_no}'&tstudenttbl.5_batchid_?\\#='${active_batchid}'";
  } else if (type == 22) {
    tlvStr =
        "tstudenttbl.usrid\\#='${userid}'&tstudenttbl.status\\#='1'&tstudenttbl.1_studid_\\#='${studid_cur}'&tstudenttbl.2_instid_?\\#='${inst_id_reg}'&tstudenttbl.3_classid_?\\#='${classid_cur}'&tstudenttbl.4_secdesc_?\\#='${sec_id_cur}'&tstudenttbl.5_rollno_?\\#='${roll_cur}'&tstudenttbl.6_batchid_?\\#='${active_batchid}'";
  } else if (type == 23) {
    tlvStr =
        "tstudenttbl.usrid\\#'${userid}'&tstudenttbl.instid\\#'${inst_id}'&tstudenttbl.classid\\#'${classid_cur}'&tstudenttbl.secdesc\\#'${sec_id_cur}'&tstudenttbl.rollno\\#'${roll_no}'&tstudenttbl.batchid\\#'${active_batchid}'";
  } else if (type == 25) {
    tlvStr =
        "tinstdcstbl.1_subid\\#?&tinstdcstbl.1_instid_\\#='${inst_id}'&tinstdcstbl.2_classid_?\\#='${classid}'";
  } else if (type == 26) {
    tlvStr =
        "tinstdcstbl.1_subid\\#?&tinstdcstbl.2_classid\\#?&tinstdcstbl.3_instid\\#?&tinstdcstbl.4_instdcsid\\#?&tinstdcstbl.1_classid_\\#='${classid}'&tinstdcstbl.2_instid_?\\#='${inst_id}'";
  } else if (type == 27) {
    tlvStr =
        "psubtbl.1_subname\\#?&psubtbl.2_subid\\#?&psubtbl.3_deptid\\#?&psubtbl.4_type\\#?&psubtbl.1_subid_\\#='${sub_id_cur}'";
  } else if (type == 28) {
    tlvStr =
        "tstudsubtbl.studid\\#'${student_id}'&tstudsubtbl.subid\\#'${sub_id_cur}'&tstudsubtbl.instid\\#'${inst_id}'&tstudsubtbl.classid\\#'${classid}'&tstudsubtbl.secdesc\\#'${sec_id}'&tstudsubtbl.rollno\\#'${roll_no}'";
  } else if (type == 29) {
    tlvStr =
        "tstudsubtbl.1_studid_\\#='${student_id}'&tstudsubtbl.2_subid_?\\#='${sub_id_cur}'";
  } else if (type == 30) {
    tlvStr =
        "tstudsubtbl.1_subid\\#?&tstudsubtbl.2_studid\\#?&tstudsubtbl.3_instid\\#?&tstudsubtbl.4_classid\\#?&tstudsubtbl.5_secdesc\\#?&tstudsubtbl.6_rollno\\#?&tstudsubtbl.7_studsubid\\#?&tstudsubtbl.1_studid_\\#='${student_id}'";
  } else if (type == 32) {
    tlvStr =
        "tteachertbl.1_usrid\\#?&tteachertbl.2_teacherid\\#?&tteachertbl.3_instid\\#?&tteachertbl.1_teacherid_\\#='${View_todayTT_teacherID_cur}'";
  } else if (type == 33) {
    tlvStr =
        "tusertbl.1_usrname\\#?&tusertbl.2_usrid\\#?&tusertbl.1_usrid_\\#='${View_todayTT_userid_cur}'";
  } else if (type == 36) {
    tlvStr =
        "tstudsubtbl.1_subid\\#?&tstudsubtbl.2_studid\\#?&tstudsubtbl.3_instid\\#?&tstudsubtbl.4_classid\\#?&tstudsubtbl.5_secdesc\\#?&tstudsubtbl.6_rollno\\#?&tstudsubtbl.7_studsubid\\#?&tstudsubtbl.1_studid_\\#='${student_id}'&tstudsubtbl.2_instid_?\\#='${inst_id}'";
  } else if (type == 37 || type == 41) {
    tlvStr =
        "ttimetbl.1_timetblid\\#?&ttimetbl.2_teacherid\\#?&ttimetbl.3_stime\\#?&ttimetbl.4_etime\\#?&ttimetbl.5_subid\\#?&ttimetbl.6_instid\\#?&ttimetbl.7_classid\\#?&ttimetbl.8_secdesc\\#?&ttimetbl.9_day\\#?&ttimetbl.9a_roomno\\#?&ttimetbl.9b_minutes\\#?&ttimetbl.9c_batchid\\#?&ttimetbl.9d_ctype\\#?&ttimetbl.9e_div\\#?&ttimetbl.9f_extrdate\\#?&ttimetbl.9g_status\\#?&ttimetbl.1_timetblid_\\#='${ttid_cur}'";
  } else if (type == 38) {
    tlvStr =
        "tteachertbl.1_usrid\\#?&tteachertbl.2_teacherid\\#?&tteachertbl.3_instid\\#?&tteachertbl.1_teacherid_\\#='${View_tomTimeTblTeacherId_cur}'";
  } else if (type == 39) {
    tlvStr =
        "tusertbl.1_usrname\\#?&tusertbl.2_usrid\\#?&tusertbl.1_usrid_\\#='${View_tomTT_userid_cur}'";
  } else if (type == 40) {
    tlvStr =
        "tstudsubtbl.1_subid\\#?&tstudsubtbl.2_studid\\#?&tstudsubtbl.3_instid\\#?&tstudsubtbl.4_classid\\#?&tstudsubtbl.5_secdesc\\#?&tstudsubtbl.6_rollno\\#?&tstudsubtbl.7_studsubid\\#?&studsubtbl.1_studid_\\#='${student_id}'";
  } else if (type == 42) {
    tlvStr =
        "tteachertbl.1_usrid\\#?&tteachertbl.2_teacherid\\#?&tteachertbl.3_instid\\#?&tteachertbl.1_teacherid_\\#='${View_todayTT_teacherID_cur}'";
  } else if (type == 43) {
    tlvStr =
        "tusertbl.1_usrname\\#?&tusertbl.2_usrid\\#?&tusertbl.1_usrid_\\#='${View_FullweekTT_userid_cur}'";
  } else if (type == 44) {
    if (ids_only) {
      tlvStr =
          "texamtbl.1_examid\\#?&texamtbl.1_instid_\\#='${inst_id}'&texamtbl.2_classid_?\\#='${classid}'&texamtbl.3_subid_?\\#='${sub_id_cur}'&texamtbl.4_status_?\\#>='2'&texamtbl.5_secdesc_?\\#='${sec_id}'&texamtbl.6_batchid_?\\#='${active_batchid}'";
    } else {
      tlvStr =
          "texamtbl.1_examid\\#?&texamtbl.2_examname\\#?&texamtbl.3_teacherid\\#?&texamtbl.4_instid\\#?&texamtbl.5_classid\\#?&texamtbl.6_subid\\#?&texamtbl.7_secdesc\\#?&texamtbl.8_exdate\\#?&texamtbl.9_stime\\#?&texamtbl.9a_etime\\#?&texamtbl.9b_roomno\\#?&texamtbl.9c_examname\\#?&texamtbl.9d_totmarks\\#?&texamtbl.9e_status\\#?&texamtbl.9f_adminid\\#?&texamtbl.9g_batchid\\#?&texamtbl.9h_examtype\\#?&texamtbl.9i_passingmarks\\#?&texamtbl.9j_subtype\\#?&texamtbl.9k_subdiv\\#?&texamtbl.9l_ctype\\#?&texamtbl.9m_subcode\\#?&texamtbl.9n_exmorder\\#?&texamtbl.1_examid_\\#='${exam_id_curr}'";
    }
  } else if (type == 45) {
    reqType = 608;
    tlvStr =
        "tstudmarkstbl^1_marksobt\\#?&tstudmarkstbl^2_totmarks\\#?&tstudmarkstbl^3_studmarksid\\#?&tstudmarkstbl^4_examid\\#?&tstudmarkstbl^5_examname\\#?&tstudmarkstbl^6_studid\\#?&tstudmarkstbl^7_teacherid\\#?&tstudmarkstbl^8_rollno\\#?&tstudmarkstbl^9_perc\\#?&tstudmarkstbl^9a_instid\\#?&tstudmarkstbl^9b_classid\\#?&tstudmarkstbl^9c_secdesc\\#?&tstudmarkstbl^9d_subid\\#?&tstudmarkstbl^9e_batchid\\#?&tstudmarkstbl^9f_subname\\#?&tstudmarkstbl^9g_adminid\\#?&tstudmarkstbl^9h_resultstatus\\#?&tstudmarkstbl^9i_type\\#?&tstudmarkstbl^9j_examtype\\#?&tstudmarkstbl^9k_subdiv\\#?&tstudmarkstbl^9l_subcode\\#?&tstudmarkstbl^9m_usrid\\#?&tstudmarkstbl^9n_ctype\\#?&tstudmarkstbl^1_studid_\\#='${student_id}'&tstudmarkstbl^2_examid_?\\#='${ExamId_MyPerf_cur}'&tstudmarkstbl^3_batchid_?\\#='${active_batchid}'";
  } else if (type == 46) {
    tlvStr =
        "ttimetbl.1_timetblid\\#?&ttimetbl.2_instid\\#?&ttimetbl.3_classid\\#?&ttimetbl.5_subid\\#?&ttimetbl.6_teacherid\\#?&ttimetbl.7_stime\\#?&ttimetbl.8_etime\\#?&ttimetbl.4_secdesc\\#?&ttimetbl.9_day\\#?&ttimetbl.9a_roomno\\#?&ttimetbl.1_instid_\\#='${inst_id}'&ttimetbl.2_classid_?\\#='${classid_cur}'&ttimetbl.3_secid_?\\#='${sec_id_cur}'&ttimetbl.4_subid_?\\#='${sub_id_cur}'";
  } else if (type == 0) {
    tlvStr =
        "texamtbl.1_examid\\#?&texamtbl.2_examname\\#?&texamtbl.3_exdate\\#?&texamtbl.4_stime\\#?&texamtbl.5_etime\\#?&texamtbl.6_subid\\#?&texamtbl.7_instid\\#?&texamtbl.8_classid\\#?&texamtbl.9_teacherid\\#?&texamtbl.9a_totmarks\\#?&texamtbl.9b_status\\#?&texamtbl.9c_roomno\\#?&texamtbl.9d_batchid\\#?&texamtbl.1_instid_\\#='${inst_id}'&texamtbl.2_classid_?\\#='${classid_cur}'&texamtbl.3_subid_?\\#='${sub_id_cur}'&texamtbl.4_examdate_?\\#>='${todays_date}'&texamtbl.5_batchid_?\\#='${active_batchid}'";
  } else if (type == 51) {
    if (attend_type == "0") {
      tlvStr =
          "tattperctbl.1_ttids\\#?&tattperctbl.2_tstat\\#?&tattperctbl.3_perc\\#?&tattperctbl.1_studid_\\#='${student_id}'&tattperctbl.2_instid_?\\#='${inst_id}'&tattperctbl.3_classid_?\\#='${classid}'&tattperctbl.4_secdesc_?\\#='${sec_id}'&tattperctbl.5_subid_?\\#='${sub_id_cur}'";
    } else if (attend_type == "1") {
      tlvStr =
          "tconsoleattperctbl.1_ttids\\#?&tconsoleattperctbl.2_tstat\\#?&tconsoleattperctbl.3_perc\\#?&tconsoleattperctbl.1_studid_\\#='${student_id}'&tconsoleattperctbl.2_instid_?\\#='${inst_id}'&tconsoleattperctbl.3_classid_?\\#='${classid}'&tconsoleattperctbl.4_secdesc_?\\#='${sec_id}'";
    }
  }

  return "TLV_STRING_FOR_TYPE_$type";
}

Future<XFile?> compressImageFile(File file,
    {int quality = 80, int maxWidth = 1280, int maxHeight = 1280}) async {
  final targetPath =
      path.join(file.parent.path, "compressed_${path.basename(file.path)}");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    targetPath,
    quality: quality, // 0-100, higher is better
    minWidth: maxWidth, // maximum width
    minHeight: maxHeight, // maximum height
    keepExif: true, // preserve EXIF info
  );

  if (result != null) {
    return XFile(result.path); // wrap File as XFile
  }

  return null; // return null if compression failed
}

bool checkIfFileExists(String path) {
  File f = File(path);
  print('checking path=$path ${f.existsSync()}');

  if (f.existsSync()) {
    return true;
  } else {
    Directory f2 = Directory(f.parent.path);
    f2.createSync(recursive: true);
    return false;
  }
}

class Glb {}
