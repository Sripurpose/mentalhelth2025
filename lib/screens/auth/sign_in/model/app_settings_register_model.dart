import 'dart:convert';

SettingsRegisterModel settingsRegisterModelFromJson(String str) =>
    SettingsRegisterModel.fromJson(json.decode(str));

String settingsRegisterModelToJson(SettingsRegisterModel data) => json.encode(data.toJson());

class SettingsRegisterModel {
  bool? status;
  String? text;
  List<SettingRegister>? settings;

  SettingsRegisterModel({
    this.status,
    this.text,
    this.settings,
  });

  factory SettingsRegisterModel.fromJson(Map<String, dynamic> json) => SettingsRegisterModel(
    status: json["status"],
    text: json["text"],
    settings: json["settings"] == null
        ? []
        : List<SettingRegister>.from(json["settings"].map((x) => SettingRegister.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "settings": settings == null
        ? []
        : List<dynamic>.from(settings!.map((x) => x.toJson())),
  };
}

class SettingRegister {
  String? id;
  String? type;
  String? isRequired;
  String? title;
  String? message;
  String? link;
  String? linkUrl;
  String? target;
  String? status;

  SettingRegister({
    this.id,
    this.type,
    this.isRequired,
    this.title,
    this.message,
    this.link,
    this.linkUrl,
    this.target,
    this.status,
  });

  factory SettingRegister.fromJson(Map<String, dynamic> json) => SettingRegister(
    id: json["id"],
    type: json["type"],
    isRequired: json["is_required"],
    title: json["title"],
    message: json["message"],
    link: json["link"],
    linkUrl: json["link_url"],
    target: json["target"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "is_required": isRequired,
    "title": title,
    "message": message,
    "link": link,
    "link_url": linkUrl,
    "target":target,
    "status": status,
  };
}
