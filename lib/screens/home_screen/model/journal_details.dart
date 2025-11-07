// To parse this JSON data, do
//
//     final journalDetails = journalDetailsFromJson(jsonString);

import 'dart:convert';

JournalDetails journalDetailsFromJson(String str) =>
    JournalDetails.fromJson(json.decode(str));

String journalDetailsToJson(JournalDetails data) => json.encode(data.toJson());

class JournalDetails {
  bool? status;
  String? text;
  String? source;
  Journals? journals;

  JournalDetails({
    this.status,
    this.text,
    this.source,
    this.journals,
  });

  factory JournalDetails.fromJson(Map<String, dynamic> json) => JournalDetails(
        status: json["status"],
        text: json["text"],
        source: json["source"],
        journals: json["journals"] == null
            ? null
            : Journals.fromJson(json["journals"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "text": text,
        "source": source,
        "journals": journals?.toJson(),
      };
}

class Journals {
  String? userId;
  String? journalId;
  String? journalTitle;
  String? journalDesc;
  String? emotionId;
  String? emotionTitle;
  int? emotionValue;
  int? driveValue;
  String? journalDatetime;
  String? displayImage;
  String? displayType;
  Goal? goal;
  List<Action>? action;
  Location? location;
  List<JournalMedia>? journalMedia;
  String? preview_link;
  String? chatlink;
  String? chartlink;

  Journals({
    this.userId,
    this.journalId,
    this.journalTitle,
    this.journalDesc,
    this.emotionId,
    this.emotionTitle,
    this.emotionValue,
    this.driveValue,
    this.journalDatetime,
    this.displayImage,
    this.displayType,
    this.goal,
    this.action,
    this.location,
    this.journalMedia,
    this.preview_link,
    this.chatlink,
    this.chartlink,
  });

  factory Journals.fromJson(Map<String, dynamic> json) => Journals(
        userId: json["user_id"],
        journalId: json["journal_id"],
        journalTitle: json["journal_title"],
        journalDesc: json["journal_desc"],
        emotionId: json["emotion_id"],
        emotionTitle: json["emotion_title"],
        emotionValue: json["emotion_value"],
        driveValue: json["drive_value"],
        journalDatetime: json["journal_datetime"],
        displayImage: json["display_image"],
        displayType: json["display_type"],
        goal: json["goal"] == null ? null : Goal.fromJson(json["goal"]),
        action: json["action"] == null
            ? []
            : List<Action>.from(json["action"]!.map((x) => Action.fromJson(x))),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        journalMedia: json["journal_media"] == null
            ? []
            : List<JournalMedia>.from(
                json["journal_media"]!.map((x) => JournalMedia.fromJson(x))),
    preview_link: json["preview_link"],
    chatlink: json["chatlink"],
    chartlink: json["chartlink"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "journal_id": journalId,
        "journal_title":journalTitle,
        "journal_desc": journalDesc,
        "emotion_id": emotionId,
        "emotion_title": emotionTitle,
        "emotion_value": emotionValue,
        "drive_value": driveValue,
        "journal_datetime": journalDatetime,
        "display_image": displayImage,
        "display_type": displayType,
        "goal": goal?.toJson(),
        "action": action == null
            ? []
            : List<dynamic>.from(action!.map((x) => x.toJson())),
        "location": location?.toJson(),
        "journal_media": journalMedia == null
            ? []
            : List<dynamic>.from(journalMedia!.map((x) => x.toJson())),
    "preview_link":preview_link,
    "chatlink":chatlink,
    "chartlink":chartlink
      };
}

class Action {
  String? actionId;
  String? actionTitle;

  Action({
    this.actionId,
    this.actionTitle,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        actionId: json["action_id"],
        actionTitle: json["action_title"],
      );

  Map<String, dynamic> toJson() => {
        "action_id": actionId,
        "action_title": actionTitle,
      };
}

class Goal {
  String? goalId;
  String? goalTitle;

  Goal({
    this.goalId,
    this.goalTitle,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        goalId: json["goal_id"],
        goalTitle: json["goal_title"],
      );

  Map<String, dynamic> toJson() => {
        "goal_id": goalId,
        "goal_title": goalTitle,
      };
}

class JournalMedia {
  String? mediaId;
  String? journalId;
  String? mediaType;
  String? gemMedia;
  String? videoThumb;
  String? is_chart;

  JournalMedia({
    this.mediaId,
    this.journalId,
    this.mediaType,
    this.gemMedia,
    this.videoThumb,
    this.is_chart,
  });

  factory JournalMedia.fromJson(Map<String, dynamic> json) => JournalMedia(
        mediaId: json["media_id"],
        journalId: json["journal_id"],
        mediaType: json["media_type"],
        gemMedia: json["gem_media"],
        videoThumb: json["video_thumb"],
    is_chart: json["is_chart"],
      );

  Map<String, dynamic> toJson() => {
        "media_id": mediaId,
        "journal_id": journalId,
        "media_type": mediaType,
        "gem_media": gemMedia,
        "video_thumb": videoThumb,
    "is_chart":is_chart,
      };
}

class Location {
  String? locationId;
  String? locationName;
  String? locationAddress;
  String? locationLatitude;
  String? locationLongitude;

  Location({
    this.locationId,
    this.locationName,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationId: json["location_id"],
        locationName: json["location_name"],
        locationAddress: json["location_address"],
        locationLatitude: json["location_latitude"],
        locationLongitude: json["location_longitude"],
      );

  Map<String, dynamic> toJson() => {
        "location_id": locationId,
        "location_name": locationName,
        "location_address": locationAddress,
        "location_latitude": locationLatitude,
        "location_longitude": locationLongitude,
      };
}
