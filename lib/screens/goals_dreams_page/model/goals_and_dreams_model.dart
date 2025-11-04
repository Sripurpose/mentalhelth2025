// To parse this JSON data, do
//
//     final goalsAndDreamsModel = goalsAndDreamsModelFromJson(jsonString);

import 'dart:convert';

GoalsAndDreamsModel goalsAndDreamsModelFromJson(String str) =>
    GoalsAndDreamsModel.fromJson(json.decode(str));

String goalsAndDreamsModelToJson(GoalsAndDreamsModel data) =>
    json.encode(data.toJson());

class GoalsAndDreamsModel {
  bool? status;
  String? text;
  String? userId;
  String? currentPage;
  int? pageCount;
  int? totalCount;
  String? source;
  List<Goalsanddream>? goalsanddreams;

  GoalsAndDreamsModel({
    this.status,
    this.text,
    this.userId,
    this.currentPage,
    this.pageCount,
    this.totalCount,
    this.source,
    this.goalsanddreams,
  });

  factory GoalsAndDreamsModel.fromJson(Map<String, dynamic> json) =>
      GoalsAndDreamsModel(
        status: json["status"],
        text: json["text"],
        userId: json["user_id"],
        currentPage: json["currentPage"],
        pageCount: json["pageCount"],
        totalCount: json["totalCount"],
        source: json["source"],
        goalsanddreams: json["goalsanddreams"] == null
            ? []
            : List<Goalsanddream>.from(
                json["goalsanddreams"]!.map((x) => Goalsanddream.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "text": text,
        "user_id": userId,
        "currentPage": currentPage,
        "pageCount": pageCount,
        "totalCount": totalCount,
        "source": source,
        "goalsanddreams": goalsanddreams == null
            ? []
            : List<dynamic>.from(goalsanddreams!.map((x) => x.toJson())),
      };
}

class Goalsanddream {
  String? goalId;
  String? goalTitle;
  String? goalDetails;
  String? goalMedia;
  String? categoryId;
  String? categoryName;
  String? displayType;
  String? createdAt;
  String? goalStartdate;
  String? goalEnddate;
  String? goalStatus;
  int? goalCompletePercent;
  List<Action>? action;
  Location? location;
  List<GemMedia>? gemMedia;
  String? preview_link;

  Goalsanddream({
    this.goalId,
    this.goalTitle,
    this.goalDetails,
    this.goalMedia,
    this.categoryId,
    this.categoryName,
    this.displayType,
    this.createdAt,
    this.goalStartdate,
    this.goalEnddate,
    this.goalStatus,
    this.goalCompletePercent,
    this.action,
    this.location,
    this.gemMedia,
    this.preview_link,
  });

  factory Goalsanddream.fromJson(Map<String, dynamic> json) => Goalsanddream(
        goalId: json["goal_id"],
        goalTitle: json["goal_title"],
        goalDetails: json["goal_details"],
        goalMedia: json["goal_media"],
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        displayType: json["display_type"],
        createdAt: json["created_at"],
        goalStartdate: json["goal_startdate"],
        goalEnddate: json["goal_enddate"],
        goalStatus: json["goal_status"],
        goalCompletePercent: json["goal_complete_percent"],
        action: json["action"] == null
            ? []
            : List<Action>.from(json["action"]!.map((x) => Action.fromJson(x))),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        gemMedia: json["gem_media"] == null
            ? []
            : List<GemMedia>.from(
                json["gem_media"]!.map((x) => GemMedia.fromJson(x))),
    preview_link: json["preview_link"],
      );

  Map<String, dynamic> toJson() => {
        "goal_id": goalId,
        "goal_title": goalTitle,
        "goal_details": goalDetails,
        "goal_media": goalMedia,
        "category_id": categoryId,
        "category_name": categoryName,
        "display_type": displayType,
        "created_at": createdAt,
        "goal_startdate": goalStartdate,
        "goal_enddate": goalEnddate,
        "goal_status": goalStatus,
        "goal_complete_percent": goalCompletePercent,
        "action": action == null
            ? []
            : List<dynamic>.from(action!.map((x) => x.toJson())),
        "location": location?.toJson(),
        "gem_media": gemMedia == null
            ? []
            : List<dynamic>.from(gemMedia!.map((x) => x.toJson())),
    "preview_link": preview_link,
      };
}

class Action {
  String? actionId;
  String? actionTitle;
  String? actionDatetime;
  String? actionStatus;

  Action({
    this.actionId,
    this.actionTitle,
    this.actionDatetime,
    this.actionStatus,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        actionId: json["action_id"],
        actionTitle: json["action_title"],
        actionDatetime: json["action_datetime"],
        actionStatus: json["action_status"],
      );

  Map<String, dynamic> toJson() => {
        "action_id": actionId,
        "action_title": actionTitle,
        "action_datetime": actionDatetime,
        "action_status": actionStatus,
      };
}

class GemMedia {
  String? mediaId;
  String? gemId;
  String? mediaType;
  String? gemMedia;
  String? videoThumb;

  GemMedia({
    this.mediaId,
    this.gemId,
    this.mediaType,
    this.gemMedia,
    this.videoThumb,
  });

  factory GemMedia.fromJson(Map<String, dynamic> json) => GemMedia(
        mediaId: json["media_id"],
        gemId: json["gem_id"],
        mediaType: json["media_type"],
        gemMedia: json["gem_media"],
        videoThumb: json["video_thumb"],
      );

  Map<String, dynamic> toJson() => {
        "media_id": mediaId,
        "gem_id": gemId,
        "media_type": mediaType,
        "gem_media": gemMedia,
        "video_thumb": videoThumb,
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
