// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) =>
    GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) =>
    json.encode(data.toJson());

class GetProfileModel {
  bool? status;
  String? text;
  String? userId;
  String? firstname;
  String? email;
  String? phone;
  String? countryCode;
  DateTime? dob;
  String? userToken;
  String? emailVerify;
  String? phoneVerify;
  String? showPhoneVerify;
  int? loggedStatus;
  String? note;
  String? profileurl;
  String? interests;
  String? interest_ids;
  int? isPassword;
  String? isSubscribed;
  String? show_subscription;
  String? isRequired;
  String? createdAt;
  Subscription? subscription;

  GetProfileModel({
    required this.status,
    required this.text,
    required this.userId,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.dob,
    required this.userToken,
    required this.emailVerify,
    required this.phoneVerify,
    required this.showPhoneVerify,
    required this.loggedStatus,
    required this.note,
    required this.profileurl,
    required this.interests,
    required this.interest_ids,
    required this.isPassword,
    required this.isSubscribed,
    required this.show_subscription,
    required this.isRequired,
    required this.createdAt,
    required this.subscription,
  });

  factory GetProfileModel.fromJson(Map<String?, dynamic> json) =>
      GetProfileModel(
        status: json["status"],
        text: json["text"],
        userId: json["user_id"],
        firstname: json["firstname"],
        email: json["email"],
        phone: json["phone"],
        countryCode: json["country_code"],
        dob: json["dob"] == null || json["dob"] == ""
            ? null
            : DateTime.parse(json["dob"]),
        userToken: json["user_token"],
        emailVerify: json["email_verify"],
        phoneVerify: json["phone_verify"],
        showPhoneVerify: json["show_verify_phone"],
        loggedStatus: json["logged_status"],
        note: json["note"],
        profileurl: json["profileurl"],
        interests: json["interests"],
        interest_ids: json["interest_ids"],
        isPassword: json["is_password"],
        isSubscribed: json["is_subscribed"],
        isRequired: json["is_required"],
        show_subscription: json["show_subscription"],
        createdAt: json["created_at"],
        subscription: json["subscription"] == null || json["subscription"] == ""
            ? null
            : Subscription.fromJson(json["subscription"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "text": text,
        "user_id": userId,
        "firstname": firstname,
        "email": email,
        "phone": phone,
        "country_code": countryCode,
        "dob": dob?.toIso8601String(),
        "user_token": userToken,
        "email_verify": emailVerify,
        "phone_verify": phoneVerify,
        "show_verify_phone":showPhoneVerify,
        "logged_status": loggedStatus,
        "note": note,
        "profileurl": profileurl,
        "interests": interests,
        "interest_ids": interest_ids,
        "is_password": isPassword,
        "is_subscribed": isSubscribed,
        "is_required": isRequired,
        "show_subscription": show_subscription,
        "created_at": createdAt,
        "subscription": subscription?.toJson(),
      };
}

class Subscription {
  String? id;
  String? stripeSubscriptionId;
  String? paidAmount;
  String? paidAmountCurrency;
  String? planInterval;
  String? planIntervalCount;
  DateTime? planPeriodStart;
  DateTime? planPeriodEnd;
  String? customerName;
  String? customerEmail;
  String? status;
  String? planName;
  String? planValidity;
  String? planAmount;

  Subscription({
    required this.id,
    required this.stripeSubscriptionId,
    required this.paidAmount,
    required this.paidAmountCurrency,
    required this.planInterval,
    required this.planIntervalCount,
    required this.planPeriodStart,
    required this.planPeriodEnd,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.planName,
    required this.planValidity,
    required this.planAmount,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json["id"],
        stripeSubscriptionId: json["stripe_subscription_id"],
        paidAmount: json["paid_amount"],
        paidAmountCurrency: json["paid_amount_currency"],
        planInterval: json["plan_interval"],
        planIntervalCount: json["plan_interval_count"],
        planPeriodStart:
            json["plan_period_start"] == null || json["plan_period_start"] == ""
                ? null
                : DateTime.parse(json["plan_period_start"]),
        planPeriodEnd:
            json["plan_period_end"] == null || json["plan_period_end"] == ""
                ? null
                : DateTime.parse(json["plan_period_end"]),
        customerName: json["customer_name"],
        customerEmail: json["customer_email"],
        status: json["status"],
        planName: json["plan_name"],
        planValidity: json["plan_validity"],
        planAmount: json["plan_amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "stripe_subscription_id": stripeSubscriptionId,
        "paid_amount": paidAmount,
        "paid_amount_currency": paidAmountCurrency,
        "plan_interval": planInterval,
        "plan_interval_count": planIntervalCount,
        "plan_period_start": planPeriodStart?.toIso8601String(),
        "plan_period_end": planPeriodEnd?.toIso8601String(),
        "customer_name": customerName,
        "customer_email": customerEmail,
        "status": status,
        "plan_name": planName,
        "plan_validity": planValidity,
        "plan_amount": planAmount,
      };
}
