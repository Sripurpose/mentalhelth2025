class UrlConstant {
  static const String baseUrl = "https://mh.featureme.live/v1/";

  static const String loginUrl = "${baseUrl}login";
  static const String logOutUrl = "${baseUrl}logout";
  static const String forgotPassword = "${baseUrl}forgotpassword";
  static const String signupUrl = "${baseUrl}signup";
  static const String plansUrl = "${baseUrl}plans";
  static String profileUrl({required String userId}) {
    return "${baseUrl}profile/$userId";
  }

  static const String socialmedialoginUrl = "${baseUrl}socialmedialogin";
  static const String savefirebasetokenUrl = "${baseUrl}token/";
  static const String saveReminderUrl = "${baseUrl}reminder/";

  static const String otpPhoneLoginUrl = "${baseUrl}otplogin";
  static const String verifyOtpUrl = "${baseUrl}verifyOtp";
  static const String subscribePlanUrl = "${baseUrl}subscribe";
  static const String accountUrl = "${baseUrl}account";
  static const String categoryUrl = "${baseUrl}category";

  static const String interestsUrl = "${baseUrl}interests";
  static const String feedbackUrl = "${baseUrl}feedback";
  static const String savegemUrl = "${baseUrl}savegem";
  static const String mediauploadUrl = "${baseUrl}mediaupload";
  static const String chartviewUrl = "${baseUrl}chartview";
  static const String appSettingsUrl = "${baseUrl}appsettings";
  static const String appRegisterUrl= "${baseUrl}setup";
  static const String version_update = "${baseUrl}version_update";


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
  static const String journalChartViewUrl = "${baseUrl}journalchartview";
  static const String emotionsUrl = "${baseUrl}emotions/";
  static const String goalsUrl = "${baseUrl}goals/";

  static String goalActionsUrl({required String goalId}) {
    return "${baseUrl}goalactions/$goalId";
  }

  static String goalDetails({required String goalId}) {
    return "${baseUrl}goal/$goalId";
  }

  static String actionDetailsPage({required String actionId}) {
    return "${baseUrl}actions/$actionId";
  }

  static const String journalUrl = "${baseUrl}journal/";

  static String goalsanddreamsUrl({required String page}) {
    return "${baseUrl}goalsanddreams/$page";
  }

  static const String updateGoalstatusUrl = "${baseUrl}update_goalstatus";
  static const String updateActionStatusUrl = "${baseUrl}update_actionstatus";

  static String deleteGoal({required String goal}) {
    return "${baseUrl}goal/$goal";
  }

  static String deleteActions({required String action}) {
    return "${baseUrl}actions/$action";
  }

  static String deleteReminders({required String reminder_id}) {
    return "${baseUrl}reminder/$reminder_id";
  }

  static const String removemediaUrl = "${baseUrl}removemedia";

  static const String sendOtpEmailPhone = "${baseUrl}send_otp_email_phone";

  static const String verifyOtpEmailPhone = "${baseUrl}verify_otp_email_phone";

  static String webContentPolicy({required String type}) {
    return "${baseUrl}content/$type";
  }
}

