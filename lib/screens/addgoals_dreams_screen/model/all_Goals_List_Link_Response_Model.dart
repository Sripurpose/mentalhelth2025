// To parse this JSON data, do
//
//     final allGoalsListLinkResponseModel = allGoalsListLinkResponseModelFromJson(jsonString);

import 'dart:convert';

AllGoalsListLinkResponseModel allGoalsListLinkResponseModelFromJson(String str) => AllGoalsListLinkResponseModel.fromJson(json.decode(str));

String allGoalsListLinkResponseModelToJson(AllGoalsListLinkResponseModel data) => json.encode(data.toJson());

class AllGoalsListLinkResponseModel {
  bool? status;
  String? text;
  List<GoalListLink>? goalsListLink;

  AllGoalsListLinkResponseModel({
    this.status,
    this.text,
    this.goalsListLink,
  });

  factory AllGoalsListLinkResponseModel.fromJson(Map<String, dynamic> json) => AllGoalsListLinkResponseModel(
    status: json["status"],
    text: json["text"],
    goalsListLink: json["goals"] == null ? [] : List<GoalListLink>.from(json["goals"]!.map((x) => GoalListLink.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "goals": goalsListLink == null ? [] : List<dynamic>.from(goalsListLink!.map((x) => x.toJson())),
  };
}

class GoalListLink {
  String? id;
  String? title;

  GoalListLink({
    this.id,
    this.title,
  });

  factory GoalListLink.fromJson(Map<String, dynamic> json) => GoalListLink(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}
