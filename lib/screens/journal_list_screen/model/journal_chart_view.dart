import 'dart:convert';

JournalChartViewModel journalChartViewModelFromJson(String str) =>
    JournalChartViewModel.fromJson(json.decode(str));

String journalChartViewModelToJson(JournalChartViewModel data) =>
    json.encode(data.toJson());

class JournalChartViewModel {
  bool? status;
  String? text;
  Chartpercentage? chartpercentage;
  Chart? chart;
  List<Emotion>? supportemotions;

  JournalChartViewModel({
    this.status,
    this.text,
    this.chartpercentage,
    this.chart,
    this.supportemotions,
  });

  factory JournalChartViewModel.fromJson(Map<String, dynamic> json) =>
      JournalChartViewModel(
        status: json["status"],
        text: json["text"],
        chartpercentage: json["chartpercentage"] == null
            ? null
            : Chartpercentage.fromJson(json["chartpercentage"]),
        chart: json["chart"] == null ? null : Chart.fromJson(json["chart"]),
        supportemotions: json["supportemotions"] == null
            ? []
            : List<Emotion>.from(
            json["supportemotions"].map((x) => Emotion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "chartpercentage": chartpercentage?.toJson(),
    "chart": chart?.toJson(),
    "supportemotions":
    supportemotions == null ? [] : supportemotions!.map((x) => x.toJson()).toList(),
  };
}

class Chartpercentage {
  int? optimalPercent;
  int? stressfullPercent;
  int? passivePercent;
  int? destructivePercent;

  Chartpercentage({
    this.optimalPercent,
    this.stressfullPercent,
    this.passivePercent,
    this.destructivePercent,
  });

  factory Chartpercentage.fromJson(Map<String, dynamic> json) =>
      Chartpercentage(
        optimalPercent: json["optimal_percent"],
        stressfullPercent: json["stressfull_percent"],
        passivePercent: json["passive_percent"],
        destructivePercent: json["destructive_percent"],
      );

  Map<String, dynamic> toJson() => {
    "optimal_percent": optimalPercent,
    "stressfull_percent": stressfullPercent,
    "passive_percent": passivePercent,
    "destructive_percent": destructivePercent,
  };
}

class Chart {
  ChartDetail? optimal;
  ChartDetail? passive;
  ChartDetail? stressful;
  ChartDetail? destructive;

  Chart({
    this.optimal,
    this.passive,
    this.stressful,
    this.destructive,
  });

  factory Chart.fromJson(Map<String, dynamic> json) => Chart(
    optimal:
    json["optimal"] == null ? null : ChartDetail.fromJson(json["optimal"]),
    passive:
    json["passive"] == null ? null : ChartDetail.fromJson(json["passive"]),
    stressful:
    json["stressful"] == null ? null : ChartDetail.fromJson(json["stressful"]),
    destructive: json["destructive"] == null
        ? null
        : ChartDetail.fromJson(json["destructive"]),
  );

  Map<String, dynamic> toJson() => {
    "optimal": optimal?.toJson(),
    "passive": passive?.toJson(),
    "stressful": stressful?.toJson(),
    "destructive": destructive?.toJson(),
  };
}

class ChartDetail {
  String? text;
  int? percent;
  int? count;
  List<Emotion>? emotions;

  ChartDetail({
    this.text,
    this.percent,
    this.count,
    this.emotions,
  });

  factory ChartDetail.fromJson(Map<String, dynamic> json) => ChartDetail(
    text: json["text"],
    percent: json["percent"],
    count: json["count"],
    emotions: json["emotions"] == null
        ? []
        : List<Emotion>.from(
        json["emotions"].map((x) => Emotion.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "percent": percent,
    "count": count,
    "emotions": emotions == null
        ? []
        : List<dynamic>.from(emotions!.map((x) => x.toJson())),
  };
}

class Emotion {
  String? emotionId;
  String? emotionTitle;

  Emotion({
    this.emotionId,
    this.emotionTitle,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) => Emotion(
    emotionId: json["emotion_id"],
    emotionTitle: json["emotion_title"],
  );

  Map<String, dynamic> toJson() => {
    "emotion_id": emotionId,
    "emotion_title": emotionTitle,
  };
}
