
class MyIcon {
  MyIcon._();

  static const baseICONURL = "assets/images/iconos";
  static const languageIcon = "$baseICONURL/language_icon_64.png";
  static const solIcon = "$baseICONURL/sol.png";
  static const lunaIcon = "$baseICONURL/luna.png";
  static const languageIcon2 = "$baseICONURL/language.png";
  static const notificationIcon = "$baseICONURL/notification.png";
  static const candadoIcon = "$baseICONURL/candado.png";

}

class AppAsset {

  static String logo(String s) {
    return 'assets/logos/$s';
  }

  static String image(String s) {
    return 'assets/images/$s';
  }

  static String imageTutorial(String s) {
    return 'assets/images/tutorial/$s';
  }
}