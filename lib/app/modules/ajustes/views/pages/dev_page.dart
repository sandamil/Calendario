import 'package:calendario2/app/modules/ajustes/views/pages/util/cloud_messaging_utils.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

import '../../../../../config/util/list_view_animator.dart';
import '../../../../../debug/log/log.dart';
import '../../../../components/toast.dart';
import 'package:go_router/go_router.dart';

enum OnListViewPress {
  cloudMessageToken,
  appLog,
}

class DevPage extends StatelessWidget {
  const DevPage({super.key});

  final List<Map> listViewData = const [
    {
      "icon": Icons.vpn_key_outlined,
      "title": "Cloud Messaging Token",
      "color": Colors.green,
      "onPress": OnListViewPress.cloudMessageToken
    },
    {
      "icon": Icons.info_outline,
      "title": "App Log",
      "color": Colors.yellow,
      "onPress": OnListViewPress.appLog
    },
  ];

  void _onListViewPress(context, OnListViewPress value) async {
    switch (value) {
      case OnListViewPress.cloudMessageToken:
        final token = await CloudMessagingUtils.getToken();
        Log.e("file size = $token");

        Toast.toast(context, msg: "$token copy");
        FlutterClipboard.copy(token ?? '');
        break;
      case OnListViewPress.appLog:
        context.push('/log-console');
        break;
      default:
        Toast.toast(context, msg: 'No function');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Developer Mode'),
        ),
        body: ListView.separated(
          itemCount: listViewData.length,
          itemBuilder: (context, index) => InkWell(
            child: WidgetAnimator(_buildAbout(listViewData[index])),
            onTap: () =>
                _onListViewPress(context, listViewData[index]['onPress']),
          ),
          separatorBuilder: (context, index) {
            return Container(
              color: Colors.black12,
              height: 1,
            );
          },
        ),
      );

  Widget _buildAbout(Map data) => Container(
        //color: Colors.yellow,
        padding: const EdgeInsets.only(
            top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
