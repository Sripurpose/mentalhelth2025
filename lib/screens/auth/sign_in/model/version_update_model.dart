import 'dart:convert';

VersionUpdateModel versionUpdateModelFromJson(String str) =>
    VersionUpdateModel.fromJson(json.decode(str));

String notificationModelToJson(VersionUpdateModel data) => json.encode(data.toJson());

class VersionUpdateModel {
  bool? status; // Changed from String? to bool?
  String? text;
  String? message;
  String? title;
  String? notifyType;
  String? device;
  String? version;

  VersionUpdateModel({
    this.status,
    this.text,
    this.message,
    this.title,
    this.notifyType,
    this.device,
    this.version,
  });

  factory VersionUpdateModel.fromJson(Map<String, dynamic> json) => VersionUpdateModel(
    status: json["status"], // Parses boolean correctly
    text: json["text"],
    message: json["message"],
    title: json["title"],
    notifyType: json["notify_type"],
    device: json["device"],
    version: json["version"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "message": message,
    "title": title,
    "notify_type": notifyType,
    "device": device,
    "version": version,
  };
}
