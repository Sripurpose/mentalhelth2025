// To parse this JSON data, do
//
//     final actionsDetailsModel = actionsDetailsModelFromJson(jsonString);

import 'dart:convert';

ActionsDetailsModel actionsDetailsModelFromJson(String str) =>
    ActionsDetailsModel.fromJson(json.decode(str));

String actionsDetailsModelToJson(ActionsDetailsModel data) =>
    json.encode(data.toJson());

class ActionsDetailsModel {
  bool? status;
  String? text;
  String? source;
  Actions? actions;

  ActionsDetailsModel({
    this.status,
    this.text,
    this.source,
    this.actions,
  });

  factory ActionsDetailsModel.fromJson(Map<String, dynamic> json) =>
      ActionsDetailsModel(
        status: json["status"],
        text: json["text"],
        source: json["source"],
        actions:
            json["actions"] == null ? null : Actions.fromJson(json["actions"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "text": text,
        "source": source,
        "actions": actions?.toJson(),
      };
}

class Actions {
  String? goalId;
  String? goalTitle;
  String? actionId;
  String? actionTitle;
  String? actionDetails;
  String? actionStatus;
  String? actionDatetime;
  Location? location;
  Reminder? reminder;
  List<GemMedia>? gemMedia;
  String? preview_link;

  Actions({
    this.goalId,
    this.goalTitle,
    this.actionId,
    this.actionTitle,
    this.actionDetails,
    this.actionStatus,
    this.actionDatetime,
    this.location,
    this.reminder,
    this.gemMedia,
    this.preview_link,
  });

  factory Actions.fromJson(Map<String, dynamic> json) => Actions(
        goalId: json["goal_id"],
        goalTitle: json["goal_title"],
        actionId: json["action_id"],
        actionTitle: json["action_title"],
        actionDetails: json["action_details"],
        actionStatus: json["action_status"],
        actionDatetime: json["action_datetime"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
    reminder: json["reminder"] == null
        ? null
        : Reminder.fromJson(json["reminder"]),
        gemMedia: json["gem_media"] == null
            ? []
            : List<GemMedia>.from(
                json["gem_media"]!.map((x) => GemMedia.fromJson(x))),
    preview_link: json["preview_link"],
      );

  Map<String, dynamic> toJson() => {
        "goal_id": goalId,
        "goal_title": goalTitle,
        "action_id": actionId,
        "action_title": actionTitle,
        "action_details": actionDetails,
        "action_status": actionStatus,
        "action_datetime": actionDatetime,
        "location": location?.toJson(),
        "reminder":reminder?.toJson(),
        "gem_media": gemMedia == null
            ? []
            : List<dynamic>.from(gemMedia!.map((x) => x.toJson())),
    "preview_link": preview_link,
      };
}

class Reminder {
  String? reminder_id;
  String? reminder_title;
  String? reminder_desc;
  String? reminder_startdate;
  String? reminder_enddate;
  String? from_time;
  String? to_time;
  String? reminder_before;
  String? reminder_repeat;



  Reminder({
    this.reminder_id,
    this.reminder_title,
    this.reminder_desc,
    this.reminder_startdate,
    this.reminder_enddate,
    this.from_time,
    this.to_time,
    this.reminder_before,
    this.reminder_repeat,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    reminder_id: json["reminder_id"],
    reminder_title: json["reminder_title"],
    reminder_desc: json["reminder_desc"],
    reminder_startdate: json["reminder_startdate"],
    reminder_enddate: json["reminder_enddate"],
    from_time: json["from_time"],
    to_time: json["to_time"],
    reminder_before: json["reminder_before"],
    reminder_repeat: json["reminder_repeat"],
  );

  Map<String, dynamic> toJson() => {
    "reminder_id": reminder_id,
    "reminder_title": reminder_title,
    "reminder_desc": reminder_desc,
    "reminder_startdate": reminder_startdate,
    "reminder_enddate": reminder_enddate,
    "from_time": from_time,
    "to_time": to_time,
    "reminder_before": reminder_before,
    "reminder_repeat": reminder_repeat,
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
