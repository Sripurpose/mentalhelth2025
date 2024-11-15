class UrlConstant {
  static String baseUrl = "";

  static String loginUrl = "${baseUrl}login";
  static String logOutUrl = "${baseUrl}logout";
  static String forgotPassword = "${baseUrl}forgotpassword";
  static String signupUrl = "${baseUrl}signup";
  static String plansUrl = "${baseUrl}plans";
  static String profileUrl({required String userId}) {
    return "${baseUrl}profile/$userId";
  }

  static String socialmedialoginUrl = "${baseUrl}socialmedialogin";
  static String savefirebasetokenUrl = "${baseUrl}token/";
  static String saveReminderUrl = "${baseUrl}reminder/";

  static String otpPhoneLoginUrl = "${baseUrl}otplogin";
  static String verifyOtpUrl = "${baseUrl}verifyOtp";
  static String subscribePlanUrl = "${baseUrl}subscribe";
  static String accountUrl = "${baseUrl}account";
  static String categoryUrl = "${baseUrl}category";

  static String interestsUrl = "${baseUrl}interests";
  static String feedbackUrl = "${baseUrl}feedback";
  static String savegemUrl = "${baseUrl}savegem";
  static String mediauploadUrl = "${baseUrl}mediaupload";
  static String chartviewUrl = "${baseUrl}chartview";
  static String appSettingsUrl = "${baseUrl}appsettings";
  static String appRegisterUrl= "${baseUrl}setup";
  static String version_update = "${baseUrl}version_update";


  static String journalsUrl({required String page}) {
    return "${baseUrl}journals/$page";
  }

  static String deleteJournal({required String journalId}) {
    return "${baseUrl}journal/$journalId";
  }

  static String fetchJournalDetails({required String journalId}) {
    return "${baseUrl}journal/$journalId";
  }
  static String fetchRemindersDetails() {
    return "${baseUrl}reminder/";
  }
  static String journalChartViewUrl = "${baseUrl}journalchartview";
  static String emotionsUrl = "${baseUrl}emotions/";
  static String goalsUrl = "${baseUrl}goals/";

  static String goalActionsUrl({required String goalId}) {
    return "${baseUrl}goalactions/$goalId";
  }

  static String goalDetails({required String goalId}) {
    return "${baseUrl}goal/$goalId";
  }

  static String actionDetailsPage({required String actionId}) {
    return "${baseUrl}actions/$actionId";
  }

  static String journalUrl = "${baseUrl}journal/";

  static String goalsanddreamsUrl({required String page}) {
    return "${baseUrl}goalsanddreams/$page";
  }

  static String updateGoalstatusUrl = "${baseUrl}update_goalstatus";
  static String updateActionStatusUrl = "${baseUrl}update_actionstatus";

  static String deleteGoal({required String goal}) {
    return "${baseUrl}goal/$goal";
  }

  static String deleteActions({required String action}) {
    return "${baseUrl}actions/$action";
  }

  static String deleteReminders({required String reminder_id}) {
    return "${baseUrl}reminder/$reminder_id";
  }

  static String removemediaUrl = "${baseUrl}removemedia";

  static String sendOtpEmailPhone = "${baseUrl}send_otp_email_phone";

  static String verifyOtpEmailPhone = "${baseUrl}verify_otp_email_phone";

  static String webContentPolicy({required String type}) {
    return "${baseUrl}content/$type";
  }
}

