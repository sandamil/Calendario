
import 'package:calendario2/app/components/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_fonts.dart';
import '../../../../../config/util/app_utils.dart';
import '../../../../../config/util/list_view_animator.dart';
import 'package:go_router/go_router.dart';

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
    // _addDevListItem();
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
        context.push('/privacy-policy');
        break;
      case OnListViewPress.dev:
        context.push('/dev');
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
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
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
        separatorBuilder: (context, index) => SizedBox(height: 9.h),
      ),
    );
  }

  Container _buildAbout(Map data) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(data['icon'] as IconData, color: data['color'] as Color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              data['title'] as String,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: .45)),
        ],
      ),
    );
  }
}
