
import 'package:calendario2/app/components/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/app_utils.dart';
import '../../../../../config/util/list_view_animator.dart';
import '../../../../routes/app_pages.dart';

enum OnListViewPress { appUpdate, contribution, privacyPolicy, version, dev }

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Map> listViewData = [];

  static bool inDevMode = false;

  @override
  void initState() {
    super.initState();
    initList();
  }

  void initList() {
    listViewData = [];
    listViewData.addAll([
      {
        "icon": Icons.refresh,
        "title": 'Comprobar Actualización',
        "color": Colors.orange,
        "onPress": OnListViewPress.appUpdate
      },
      // {
      //   "icon": Icons.noise_aware,
      //   "title": 'Contribuciones',
      //   "color": Colors.lightGreen,
      //   "onPress": OnListViewPress.contribution
      // },
      {
        "icon": Icons.privacy_tip_outlined,
        "color": Colors.blueGrey,
        "title": 'Política de Privacidad',
        "onPress": OnListViewPress.privacyPolicy
      },
      {
        "icon": Icons.info_outline,
        "color": Colors.blue,
        "title": 'Version info',
        "onPress": OnListViewPress.version
      }
    ]);
    _addDevListItem();
  }

  void _addDevListItem() {
    if (inDevMode) {
      setState(() {
        listViewData.add({
          "icon": Icons.menu_open_sharp,
          "color": Colors.amberAccent,
          "title": 'Developer Mode',
          "onPress": OnListViewPress.dev
        });
      });
    }
  }

  int pressTime = 0;

  void _onListViewPress(OnListViewPress value) async {
    switch (value) {
      case OnListViewPress.appUpdate:
        Toast.toast(context, msg: 'Comprobando versión...');
        // final result = await APPVersion.checkShouldUpdate();
        // if (!result) {
        //   Toast.toast(context, msg: 'Already the latest version');
        // }
        break;
      case OnListViewPress.contribution:
        // RouteUtils.toContributorsPage();
        break;
      case OnListViewPress.version:
        String mainVersion = await AppUtils.getAppVersion();
        if (pressTime == 0) {
          Toast.toast(context, msg: mainVersion);

        }
        pressTime++;
        Future.delayed(const Duration(seconds: 2)).then((_) {
          pressTime = 0;
        });
        if (pressTime > 3 && kDebugMode) {
          if (!inDevMode) {
            inDevMode = true;
            _addDevListItem();
          }
        }
        break;
      case OnListViewPress.privacyPolicy:
        RouteUtils.toPrivacyPolicyPage();
        break;
      case OnListViewPress.dev:
        RouteUtils.toDevPage();
        break;
      default:
      Toast.toast(context, msg: 'No function');
       break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Informacion App',
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          Widget widget;
          widget = _buildAbout(listViewData[index]);
          return InkWell(
            child: WidgetAnimator(widget),
            onTap: () {
              _onListViewPress(listViewData[index]['onPress']);
            },
          );
        },
        separatorBuilder: (context, index) {
          // 顯示格線
          return Container(
            color: Colors.black12,
            height: 1,
          );
        },
      ),
    );
  }

  Container _buildAbout(Map data) {
    return Container(
      //color: Colors.yellow,
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'],
            color: data['color'],
          ),
          const SizedBox(
            width: 20.0,
          ),
          Text(
            data['title'],
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
