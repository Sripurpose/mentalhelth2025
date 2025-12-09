// To parse this JSON data, do
//
//     final journalsModelGrid = journalsModelGridFromJson(jsonString);

import 'dart:convert';

JournalsModelGrid journalsModelGridFromJson(String str) => JournalsModelGrid.fromJson(json.decode(str));

String journalsModelGridToJson(JournalsModelGrid data) => json.encode(data.toJson());

class JournalsModelGrid {
  bool? status;
  String? text;
  String? currentPage;
  int? pageCount;
  int? totalCount;
  String? source;
  List<JournalGrid>? journals;

  JournalsModelGrid({
    this.status,
    this.text,
    this.currentPage,
    this.pageCount,
    this.totalCount,
    this.source,
    this.journals,
  });

  factory JournalsModelGrid.fromJson(Map<String, dynamic> json) => JournalsModelGrid(
    status: json["status"],
    text: json["text"],
    currentPage: json["currentPage"],
    pageCount: json["pageCount"],
    totalCount: json["totalCount"],
    source: json["source"],
    journals: json["journals"] == null ? [] : List<JournalGrid>.from(json["journals"]!.map((x) => JournalGrid.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "currentPage": currentPage,
    "pageCount": pageCount,
    "totalCount": totalCount,
    "source": source,
    "journals": journals == null ? [] : List<dynamic>.from(journals!.map((x) => x.toJson())),
  };
}

class JournalGrid {
  String? userId;
  String? journalId;
  String? journalTitle;
  String? journalDesc;
  String? previewLink;
  String? journalDatetime;
  String? displayImage;
  String? displayType;
  List<JournalMedia>? journalMedia;
  Location? location;

  JournalGrid({
    this.userId,
    this.journalId,
    this.journalTitle,
    this.journalDesc,
    this.previewLink,
    this.journalDatetime,
    this.displayImage,
    this.displayType,
    this.journalMedia,
    this.location,
  });

  factory JournalGrid.fromJson(Map<String, dynamic> json) => JournalGrid(
    userId: json["user_id"],
    journalId: json["journal_id"],
    journalTitle: json["journal_title"],
    journalDesc: json["journal_desc"],
    previewLink: json["preview_link"],
    journalDatetime: json["journal_datetime"],
    displayImage: json["display_image"],
    displayType: json["display_type"],
    journalMedia: json["journal_media"] == null ? [] : List<JournalMedia>.from(json["journal_media"]!.map((x) => JournalMedia.fromJson(x))),
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "journal_id": journalId,
    "journal_title": journalTitle,
    "journal_desc": journalDesc,
    "preview_link": previewLink,
    "journal_datetime": journalDatetime,
    "display_image": displayImage,
    "display_type": displayType,
    "journal_media": journalMedia == null ? [] : List<dynamic>.from(journalMedia!.map((x) => x.toJson())),
    "location": location?.toJson(),
  };
}

class JournalMedia {
  String? mediaId;
  String? journalId;
  String? mediaType;
  String? gemMedia;
  String? videoThumb;
  String? isChart;

  JournalMedia({
    this.mediaId,
    this.journalId,
    this.mediaType,
    this.gemMedia,
    this.videoThumb,
    this.isChart,
  });

  factory JournalMedia.fromJson(Map<String, dynamic> json) => JournalMedia(
    mediaId: json["media_id"],
    journalId: json["journal_id"],
    mediaType: json["media_type"],
    gemMedia: json["gem_media"],
    videoThumb: json["video_thumb"],
    isChart: json["is_chart"],
  );

  Map<String, dynamic> toJson() => {
    "media_id": mediaId,
    "journal_id": journalId,
    "media_type": mediaType,
    "gem_media": gemMedia,
    "video_thumb": videoThumb,
    "is_chart": isChart,
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
