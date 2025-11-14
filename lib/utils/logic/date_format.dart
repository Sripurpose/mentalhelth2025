import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String dateFormatter({required String date}) {
  DateTime originalDate = DateTime.parse(date);
  String formattedDateStr = DateFormat('dd MMM yyyy').format(originalDate);
  return formattedDateStr;
}

String formatTimeOfDay(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return "$hours:$minutes";
}

String dateFormatterMillisecond({required String date}) {
  // DateTime originalDate = DateTime.parse(date);
  DateTime originalDate = DateTime.fromMillisecondsSinceEpoch(int.parse(date));
  String formattedDateStr = DateFormat('dd MMM yyyy').format(originalDate);
  return formattedDateStr;
}

String dateTimeFormatterMain({required String date}) {
  DateTime parsedDate = DateTime.parse(date);
  // DateTime parsedDate = DateTime.fromMillisecondsSinceEpoch(int.parse(date));
  String formattedDate = DateFormat("dd MMM yyyy, hh:mma").format(parsedDate);
  return formattedDate;
}

String dateTimeFormatter({required String date}) {
  // DateTime parsedDate = DateTime.parse(date);
  DateTime parsedDate =
      DateTime.fromMillisecondsSinceEpoch(int.parse("${date}000"));
  String formattedDate = DateFormat("dd MMM yyyy, hh:mma").format(parsedDate);
  return formattedDate;
}

String dateFormatterViewJournal({required String date}) {
  final DateTime parsedDate =
  DateTime.fromMillisecondsSinceEpoch(int.parse("${date}000"));
  return DateFormat("dd MMM yyyy").format(parsedDate);
}

String timeFormatter({required String date}) {
  final DateTime parsedDate =
  DateTime.fromMillisecondsSinceEpoch(int.parse("${date}000"));
  return DateFormat("hh:mma").format(parsedDate);
}


String formatTimestampToDate(String timestamp) {
  // Convert the timestamp string to an integer
  int timestampInt = int.parse(timestamp);

  // Multiply by 1000 if the timestamp is in seconds (Unix time) to get milliseconds
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000);

  // Use DateFormat from intl package to format the date as needed
  // Import 'package:intl/intl.dart';
  return DateFormat('dd MMM yyyy').format(date);
}


String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String formatAchievementDate(String dateStr) {
  // Split the date string and handle the case where the year might be incorrect
  if (dateStr.isEmpty) return "Achievement Date"; // Return placeholder if the string is empty

  // Handle different formats, including invalid or unexpected ones
  try {
    // Try to parse the date directly if it follows "yyyy-MMM-dd" format
    DateTime parsedDate = DateFormat('yyyy-MMM-dd').parse(dateStr);

    // Return the formatted date as "dd MMM yyyy"
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (e) {
    // Handle parsing exceptions
    print("Error parsing date: $e");
    return dateStr; // Return original string if parsing fails
  }

}


