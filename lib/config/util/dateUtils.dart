import 'package:intl/intl.dart';

extension Date on DateTime {
  String get formatDate => DateFormat('hh:mm a').format(this).toString();
  String get formatDateYMD => DateFormat.yMd().format(this).toString();
  String get formatDateYMMMd => DateFormat.yMMMMd().format(this).toString();
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
