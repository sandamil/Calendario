import 'package:calendario2/config/translations/es_ES/es_es_translation.dart';
import 'package:intl/intl.dart';

extension Date on DateTime {
  String get formatDateTime24H => DateFormat('HH:mm').format(this).toString();
  String get formatDateD => DateFormat.d().format(this).toString();
  String get formatDateMMM => DateFormat('MMMM', 'es').format(this).toString();
  String get formatDateYMD => DateFormat.yMd().format(this).toString();
  String get formatDateYMMMd => DateFormat('yMMMMd', 'es').format(this).toString();
}

class DataConvert {
  static String getNameOfMonth(DateTime date) {
    final List months = [
      'Jan',
      'Feb',
      'Mar',
      'April',
      'May',
      'Jun',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = date.month;
    print(month);
    return months[month - 1];
  }
}
