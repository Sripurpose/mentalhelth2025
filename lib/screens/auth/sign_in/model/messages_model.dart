import 'dart:convert';

MessagesModel messagesModelFromJson(String str) =>
    MessagesModel.fromJson(json.decode(str));

String messagesModelToJson(MessagesModel data) => json.encode(data.toJson());

class MessagesModel {
  bool? status;
  String? text;
  List<Messages>? messages;

  MessagesModel({
    this.status,
    this.text,
    this.messages,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
    status: json["status"],
    text: json["text"],
    messages: json["messages"] == null
        ? []
        : List<Messages>.from(json["messages"].map((x) => Messages.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "text": text,
    "messages": messages == null
        ? []
        : List<dynamic>.from(messages!.map((x) => x.toJson())),
  };
}

class Messages {
  String? title;
  String? description;
  String? url;
  String? type;
  String? button_text;
  String? image_url;

  Messages({
    this.title,
    this.description,
    this.url,
    this.type,
    this.button_text,
    this.image_url,
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
    title: json["title"],
    description: json["description"],
    url: json["url"],
    type: json["type"],
    button_text: json["button_text"],
    image_url: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "url": url,
    "type": type,
    "button_text": button_text,
    "image_url": image_url,
  };
}
