
import 'dart:math';


const String APP_FIRST_TIME_OPEN = 'app_first_time_open';


class ConstantData {
  ///icons
  static const BASEIMAGEURL = "assets/images/";

  static final appIcon = BASEIMAGEURL + "todey.png";

  ///animaciones
  static const BASEANIMATIONURL = "assets/animaciones/";

  static final darklightswitch = BASEANIMATIONURL + "darklightswitch.riv";
  static final lightdark_theme = BASEANIMATIONURL + "lightdark_theme.riv";

  ///alarmas
  static const BASEALARMURL = "assets/alarmas/";

  static final nokiaAlarm = BASEALARMURL + "nokia.mp3";
  static final mozartAlarm = BASEALARMURL + "mozart.mp3";
  static final onepieceAlarm = BASEALARMURL + "one_piece.mp3";
  static final starwarsAlarm = BASEALARMURL + "star_wars.mp3";


///fonts
  static final ralewayFont = 'Raleway';

///duration
  static final kDuration = Duration(milliseconds: 300);

/// error message
  static const error = "An error has occcured";



}

/// notas
const String warnDefaultt = 'Al principio';



int idGenerator() {
  final now = DateTime.now();
  return now.microsecondsSinceEpoch ;
}


randomIdGenerator() {
  var ranAssets = RanKeyAssets();
  String middle4Digits = '';
  for (int i = 0; i < 4; i++) {
    middle4Digits +=
    ranAssets.digits[Random.secure().nextInt(ranAssets.digits.length)];
  }

  return '$middle4Digits${DateTime.now().microsecondsSinceEpoch.toString().substring(8, 12)}';
}

class RanKeyAssets {
  var digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
}
