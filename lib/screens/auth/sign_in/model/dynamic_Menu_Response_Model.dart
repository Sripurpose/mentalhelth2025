// To parse this JSON data, do
//
//     final dynamicMenuResponseModel = dynamicMenuResponseModelFromJson(jsonString);

import 'dart:convert';

DynamicMenuResponseModel dynamicMenuResponseModelFromJson(String str) => DynamicMenuResponseModel.fromJson(json.decode(str));

String dynamicMenuResponseModelToJson(DynamicMenuResponseModel data) => json.encode(data.toJson());

class DynamicMenuResponseModel {
  bool? status;
  String? text;
  List<DynamicSetting>? dynamicSettings;

  DynamicMenuResponseModel({
    this.status,
    this.text,
    this.dynamicSettings,
  });

  factory DynamicMenuResponseModel.fromJson(Map<String, dynamic> json) => DynamicMenuResponseModel(
    status: json["status"],
    text: json["text"],
    dynamicSettings: json["settings"] == null ? [] : List<DynamicSetting>.from(json["settings"]!.map((x) => DynamicSetting.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "settings": dynamicSettings == null ? [] : List<dynamic>.from(dynamicSettings!.map((x) => x.toJson())),
  };
}

class DynamicSetting {
  String? id;
  String? type;
  String? title;
  String? message;
  String? link;
  String? linkUrl;
  String? status;

  DynamicSetting({
    this.id,
    this.type,
    this.title,
    this.message,
    this.link,
    this.linkUrl,
    this.status,
  });

  factory DynamicSetting.fromJson(Map<String, dynamic> json) => DynamicSetting(
    id: json["id"],
    type: json["type"],
    title: json["title"],
    message: json["message"],
    link: json["link"],
    linkUrl: json["link_url"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "title": title,
    "message": message,
    "link": link,
    "link_url": linkUrl,
    "status": status,
  };
}
