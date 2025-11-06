// To parse this JSON data, do
//
//     final appshareResponse = appshareResponseFromJson(jsonString);

import 'dart:convert';

AppShareResponse appShareResponseFromJson(String str) => AppShareResponse.fromJson(json.decode(str));

String appShareResponseToJson(AppShareResponse data) => json.encode(data.toJson());

class AppShareResponse {
  String? status;
  String? text;
  String? title;
  String? message;
  String? link;
  String? appstoreUrl;
  String? playstoreUrl;

  AppShareResponse({
    this.status,
    this.text,
    this.title,
    this.message,
    this.link,
    this.appstoreUrl,
    this.playstoreUrl,
  });

  factory AppShareResponse.fromJson(Map<String, dynamic> json) => AppShareResponse(
    status: json["status"],
    text: json["text"],
    title: json["title"],
    message: json["message"],
    link: json["link"],
    appstoreUrl: json["appstore_url"],
    playstoreUrl: json["playstore_url"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "title": title,
    "message": message,
    "link": link,
    "appstore_url": appstoreUrl,
    "playstore_url": playstoreUrl,
  };
}
