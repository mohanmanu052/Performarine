import 'package:intl/intl.dart';

String getFormattedDate(String date) {
  /// Convert into local date format.
  var localDate = DateTime.parse(date).toLocal();
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
  var inputDate = inputFormat.parse(localDate.toString());
  var outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
  var outputDate = outputFormat.format(inputDate);
  return outputDate.toString();
}