import 'package:intl/intl.dart';

extension Date on DateTime {
  String get formatDate => DateFormat('hh:mm a').format(this).toString();
  String get formatDateYMD => DateFormat.yMd().format(this).toString();
  String get formatDateYMMMd => DateFormat.yMMMMd().format(this).toString();
}
