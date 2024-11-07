import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/edit_profile_model.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/get_category.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../token_expiry/token_expiry.dart';

class EditProfileProvider extends ChangeNotifier {
  TextEditingController myProfileController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController interestsValueController = TextEditingController();

  TextEditingController aboutYouValueController = TextEditingController();
  TextEditingController sendOtpEmailController = TextEditingController();
  TextEditingController sendOtpPhoneController = TextEditingController();
  var logger = Logger();
  String selectedDate = '';
  String profileUrl =
      'https://www.clevelanddentalhc.com/wp-content/uploads/2018/03/sample-avatar.jpg';
  GetProfileModel? getProfileModel;
  bool getProfileLoading = false;

  void clearTextEditingController() {
    sendOtpEmailController.clear();
    sendOtpPhoneController.clear();
    phoneOtp = '';
    otp = '';
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    try {
      getProfileModel = null;
      String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      getProfileLoading = true;
      notifyListeners();
      Uri url = Uri.parse(
        UrlConstant.profileUrl(
          userId: userId!,
        ),
      );
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "authorization": "$token"
        },
      );
      log(response.body.toString(), name: " response");
      if (response.statusCode == 200) {
        getProfileModel = getProfileModelFromJson(response.body);
        notifyListeners();
        fetchCategory();
        editProfileAddValue();
        notifyListeners();
      } else {
        getProfileLoading = false;
        notifyListeners();
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getProfileLoading = false;
      notifyListeners();
    } catch (e) {
      log(e.toString(), name: " response e");
      getProfileLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }


  void removeInterest(String interest) {
    // Check if interests are not null
    if (getProfileModel?.interests != null) {
      // Safely unwrap the nullable list and split into a non-nullable list
      List<String> currentInterests = getProfileModel!.interests!.split(',').map((e) => e.trim()).toList();

      // Remove the specified interest
      currentInterests.remove(interest);

      // Update the interests in the profile model
      getProfileModel!.interests = currentInterests.join(', ');

      // Notify listeners about the change
      notifyListeners();
    }
  }

  void removeInterestId(String interest) {
    // Check if interests are not null
    if (getProfileModel?.interest_ids != null) {
      // Safely unwrap the nullable list and split into a non-nullable list
      List<String> currentInterests = getProfileModel!.interest_ids!.split(',').map((e) => e.trim()).toList();

      // Remove the specified interest
      currentInterests.remove(interest);

      // Update the interests in the profile model
      getProfileModel!.interest_ids = currentInterests.join(', ');

      // Notify listeners about the change
      notifyListeners();
    }
  }

  void editProfileAddValue() {
    myProfileController.text = getProfileModel!.firstname.toString();

    phoneController.text = getProfileModel!.phone.toString();

    emailController.text = getProfileModel!.email.toString();
    date = getProfileModel?.dob;
    selectedDate = getProfileModel?.dob == null || getProfileModel?.dob == null
        ? ""
        : dateFormatter(
            date: getProfileModel!.dob.toString(),
          );
    interestsValueController.text = getProfileModel!.interests.toString();
    aboutYouValueController.text = getProfileModel!.note.toString();
    profileUrl = getProfileModel!.profileurl.toString();
  }

  DateTime? date;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != date) {
      date = picked;
      selectedDate = dateFormatter(date: picked.toString());
      notifyListeners();
    }
  }

  //image picker
  File? images;

  Future<void> getImageFromGallery({required BuildContext context}) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      images = File(pickedFile.path);
      await saveMediaUpload(
        context,
        file: images!,
        type: "profile",
      );
      notifyListeners();
    }
  }

  //media upload function
  bool saveMediaUploadLoading = false;

  Future<void> saveMediaUpload(BuildContext context,
      {required File file, required String type}) async {
    try {
      String? token = await getUserTokenSharePref();
      saveMediaUploadLoading = true;
      notifyListeners();
      var headers = {
        "authorization": "$token",
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          UrlConstant.mediauploadUrl,
        ),
      );
      request.fields.addAll({'type': type});
      request.files.add(
        await http.MultipartFile.fromPath(
          'media_name',
          file.path,
        ),
      );
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      // print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String? mediaName = jsonResponse['media_name'];
        profileUrl = mediaName.toString();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveMediaUploadLoading = false;
      notifyListeners();
    } catch (error) {
      saveMediaUploadLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      profileUrl = pickedFile.path;
      notifyListeners();
    }
  }

  //flutter put profile method
  bool editLoading = false;
  List<Category> selectedCategories = [];
  List<String>profileInterests = [];
  List<String>profileInterestIds = [];
  void setSelectedCategories(List<Category> categories) {
    for (var category in categories) {
      // Check if category already exists based on its ID
      if (!selectedCategories.any((selected) => selected.id == category.id)) {
        selectedCategories.add(category);
      }
    }
    notifyListeners();
  }

  void removeSelectedCategory(Category category) {
    selectedCategories.remove(category);
    logger.w("RemoveselectedCategories$selectedCategories");
    notifyListeners();
  }

  void initializeSelectedCategories(List<Category> allCategories) {
    final interests = getProfileModel?.interests?.split(',') ?? [];
    final interestIds = getProfileModel?.interest_ids?.split(',') ?? [];

    selectedCategories = allCategories.where((category) {
      // Check if the category name or ID matches the interests or interest IDs
      return interests.contains(category.categoryName) ||
          interestIds.contains(category.id.toString());
    }).toList();

    notifyListeners();
  }

  void addSelectedCategory(Category category) {
    if (!selectedCategories.contains(category)) {
      selectedCategories.add(category);
      logger.w("AddselectedCategories$selectedCategories");
      notifyListeners();
    }
  }

  Future<void> editProfileFunction(
      {required String firstName,
        required String note,
        required String profileimg,
        required String dob,
        required String phone,
        required String email,
        required BuildContext context,
        required List<String> interestIds}) async {  // Modified to accept a list of interest IDs
    try {
      editLoading = true;
      notifyListeners();
      String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      final Map<String, String> headers = <String, String>{
        "authorization": "$token"
      };
      late Map<String, dynamic> body;

      // Common fields
      body = {
        'firstname': firstName,
        'note': note,
        'dob': dob,
        'phone': phone,
        'email':email
      };

      logger.w("body$body");

      // Add profile image only if it's not an empty string or a URL
      if (!(profileimg.startsWith("https") || profileimg.startsWith("http") || profileimg == "")) {
        body['profileimg'] = profileimg;
      }

      // Dynamically add interest fields
      for (int i = 0; i < interestIds.length; i++) {
        body['interest[$i]'] = interestIds[i];
      }
      logger.w("body1$body");
      final http.Response response = await http.put(
        Uri.parse(
          UrlConstant.profileUrl(userId: userId!),
        ),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(
          context: context,
          message: 'Profile Updated Successfully.',
        );
        fetchUserProfile();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
        // Handle token refresh or re-authentication logic
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Edit request failed.',
        );
      }

      editLoading = false;
      notifyListeners();
    } catch (error) {
      editLoading = false;
      notifyListeners();
    }
  }


  bool saveIntrestsLoading = false;

  Future<void> saveIntrests(BuildContext context,
      {required String value}) async {
    try {
      saveIntrestsLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'interest[0]': value,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.interestsUrl,
        ),
        headers: <String, String>{
          // 'Content-Type': 'application/json',
          "authorization": "$token"
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveIntrestsLoading = false;
      notifyListeners();
    } catch (error) {
      saveIntrestsLoading = false;
      notifyListeners();
    }
  }

  GetCategory? getCategoryModel;
  bool getCategoryLoading = false;

  Future<void> fetchCategory() async {
    try {
      getCategoryLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      final response = await http.get(
        Uri.parse(
          UrlConstant.categoryUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "authorization": "$token"
        },
      );
      if (response.statusCode == 200) {
        getCategoryModel = getCategoryFromJson(response.body);
        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getCategoryLoading = false;
      notifyListeners();
    } catch (e) {
      getCategoryLoading = false;
      notifyListeners();
    }
  }

  Category? categorys;

  void selectCategory({required String value, required Category mainCategory}) {
    interestsValueController.text = value;
    categorys = mainCategory;
    notifyListeners();
  }

  bool phoneIsValid = true;

  void phoneValidate(bool value) async {
    phoneIsValid = value;
    notifyListeners();
  }

  bool validatePhoneNumber(String value) {
    final RegExp phoneRegex = RegExp(r'^(\d{3}[-\s]?\d{3}[-\s]?\d{4})$');
    return phoneRegex.hasMatch(value);
  }


  bool sendOtpLoading = false;
  bool verifyOtpLoading = false;
  int sendOtpStatus = 0;
  int verifyOtpStatus = 0;
  String? sendOtpMailMessage = "";
  String? verifyOtpMailMessage = "";
  int sendOtpPhoneStatus = 0;
  bool sendOtpPhoneLoading = false;
  String? sendOtpPhoneMessage = "";
  int verifyOtpPhoneStatus = 0;
  String? verifyOtpPhoneMessage = "";
  bool verifyOtpPhoneLoading = false;

  String otp = '';
  String phoneOtp = '';

  Future<void> sendOtpFunction(
      BuildContext context, {
        String? type,
      }) async {
    try {
      sendOtpStatus = 0;
      sendOtpMailMessage = '';
      sendOtpLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'type': getProfileModel!.email,
      };

      logger.w("body $body");

      print(UrlConstant.sendOtpEmailPhone + " sendOtpFunction");
      print(body.toString() + " sendOtpFunction");
      final response = await http.post(
        Uri.parse(
          UrlConstant.sendOtpEmailPhone,
        ),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        sendOtpLoading = false;
        sendOtpStatus = response.statusCode;
        sendOtpMailMessage = response.reasonPhrase;
        showCustomSnackBar(
          context: context,
          message: 'An OTP has been sent to your email.Please enter it to verify your account.',
        );
       // Navigator.of(context).pop();
      } else {
        sendOtpLoading = false;
        sendOtpStatus = response.statusCode;
        sendOtpMailMessage =  response.reasonPhrase;
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message:'Please try again!!',
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      notifyListeners();
    }
  }
  void addOtpFunction({required String value}) {
    if (value.length == 6) {
      otp = value;
      notifyListeners();
    }
  }
  void addPhoneOtpFunction({required String value}) {
    if (value.length == 6) {
      phoneOtp = value;
      notifyListeners();
    }
  }

  Future<void> verifyOtpFunction(
      BuildContext context, {
        String? type,
      }) async {
    try {
      verifyOtpStatus = 0;
      verifyOtpMailMessage = '';
      verifyOtpLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'type': 'email',
        'otp':otp
      };

      logger.w("body $body");

      print(UrlConstant.verifyOtpEmailPhone + " verifyOtpFunction");
      print(body.toString() + " verifyOtpFunction");
      final response = await http.post(
        Uri.parse(
          UrlConstant.verifyOtpEmailPhone,
        ),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        verifyOtpLoading = false;
        verifyOtpStatus = response.statusCode;
        verifyOtpMailMessage = response.reasonPhrase;
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        Navigator.of(context).pop();
      } else {
        verifyOtpLoading = false;
        verifyOtpStatus = response.statusCode;
        verifyOtpMailMessage = response.reasonPhrase;
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      notifyListeners();
    }
  }

  Future<void> sendOtpPhoneFunction(
      BuildContext context, {
        String? type,
      }) async {
    try {
      sendOtpPhoneStatus = 0;
      sendOtpPhoneMessage = '';
      sendOtpPhoneLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'type': getProfileModel!.phone,
      };

      logger.w("body $body");

      print(UrlConstant.sendOtpEmailPhone + " sendOtpPhoneFunction");
      print(body.toString() + " sendOtpPhoneFunction");
      final response = await http.post(
        Uri.parse(
          UrlConstant.sendOtpEmailPhone,
        ),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        sendOtpPhoneLoading = false;
        sendOtpPhoneStatus = response.statusCode;
        sendOtpPhoneMessage = response.reasonPhrase;
        showCustomSnackBar(
          context: context,
          message: 'An OTP has been sent to your email.Please enter it to verify your account.',
        );
       // Navigator.of(context).pop();
      } else {
        sendOtpPhoneLoading = false;
        sendOtpPhoneStatus = response.statusCode;
        sendOtpPhoneMessage =  response.reasonPhrase;
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: 'Please try again!!',
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      notifyListeners();
    }
  }

  Future<void> verifyOtpPhoneFunction(
      BuildContext context, {
        String? type,
      }) async {
    try {
      verifyOtpPhoneStatus = 0;
      verifyOtpPhoneMessage = '';
      verifyOtpPhoneLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'type': 'phone',
        'otp':phoneOtp
      };

      logger.w("body $body");

      print(UrlConstant.verifyOtpEmailPhone + " verifyOtpPhoneFunction");
      print(body.toString() + " verifyOtpPhoneFunction");
      final response = await http.post(
        Uri.parse(
          UrlConstant.verifyOtpEmailPhone,
        ),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        verifyOtpPhoneLoading = false;
        verifyOtpPhoneStatus = response.statusCode;
        verifyOtpPhoneMessage = response.reasonPhrase;
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        Navigator.of(context).pop();
      } else {
        verifyOtpPhoneLoading = false;
        verifyOtpPhoneStatus = response.statusCode;
        verifyOtpPhoneMessage = response.reasonPhrase;
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      notifyListeners();
    }
  }

  Future<void> saveSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> categoriesJson = selectedCategories.map((category) => jsonEncode(category.toJson())).toList();
    await prefs.setStringList('selectedCategories', categoriesJson);
  }

  // Load selected categories from Shared Preferences
  Future<void> loadSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? categoriesJson = prefs.getStringList('selectedCategories');

    if (categoriesJson != null) {
      selectedCategories = categoriesJson.map((json) => Category.fromJson(jsonDecode(json))).toList();
    }
    notifyListeners();
  }
}
