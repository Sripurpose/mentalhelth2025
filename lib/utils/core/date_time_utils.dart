import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const String dateTimeFormatPattern = 'dd/MM/yyyy';

extension DateTimeExtension on DateTime {
  /// Return a string representing [date] formatted according to our locale
  String format([
    String pattern = dateTimeFormatPattern,
    String? locale,
  ]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }
}

String formatMilliseconds(int millisecondsMain) {
  int milliseconds = int.parse("${millisecondsMain}000");
  // Convert milliseconds to DateTime
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  // Format the DateTime object as desired
  String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

  return formattedDate;
}

String formatDate(int millisecondsMain) {
  int milliseconds = int.parse("${millisecondsMain}000");
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);

// Format the DateTime object
  String formattedDate = DateFormat('dd MMM yyyy').format(date);

  return formattedDate;
}

String formatDate1(int millisecondsMain) {
  // Use millisecondsMain directly without multiplying
  DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsMain);

  // Format the DateTime object
  String formattedDate = DateFormat('dd MMM yyyy').format(date);

  return formattedDate;
}


String formatDate2(int millisecondsMain) {
  int milliseconds = int.parse("$millisecondsMain");
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);

// Format the DateTime object
  String formattedDate = DateFormat('dd MMM yyyy').format(date);

  return formattedDate;
}

DateTime formatDateToDateTime(int millisecondsMain) {
  int milliseconds = int.parse("${millisecondsMain}000");
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);

// Format the DateTime object
//   String formattedDate = DateFormat('dd MMM yyyy').format(date);

  return date;
}

String formatDateToString(int millisecondsMain) {
  int milliseconds = int.parse("${millisecondsMain}000");
  String date = DateTime.fromMillisecondsSinceEpoch(milliseconds).toString();
  String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(date));
// Format the DateTime object
//   String formattedDate = DateFormat('dd MMM yyyy').format(date);

  return formattedDate;
}

String formatPickedDateFor(DateTime pickedDate) {
  // Convert milliseconds to DateTime
  String formattedDate = DateFormat('yyMMddHHmm').format(pickedDate);

  return formattedDate;
}

String formatPickedDateFor2(DateTime pickedDate) {
  // Convert milliseconds to DateTime
  String formattedDate = DateFormat('d MMM yyyy').format(pickedDate);

  return formattedDate;
}

String formatPickedDateFor1(DateTime pickedDate) {
  final localDate = pickedDate.toLocal(); // Ensures local time
  return DateFormat('yyyy-MM-dd').format(localDate);
}


String formatPickedDateFor23(DateTime pickedDate) {
  final localDate = pickedDate.toLocal(); // Ensures local time
  return DateFormat('yyyy-MM-dd').format(localDate);
}


String formatPickedDateFromMilliseconds(int milliseconds) {
  // Create a DateTime from milliseconds since the Epoch
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  // Use DateFormat to format the DateTime object
  String formattedDate = DateFormat('yyMMddHHmm').format(dateTime);

  return formattedDate;
}
