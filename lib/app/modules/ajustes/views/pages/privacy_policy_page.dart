
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../../config/theme/my_colors.dart';


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Privacy policy'),
        ),
        body: FutureBuilder<String>(
          // future: Connector.getDataByGet(ConnectorParameter(AppLink.privacyPolicyUrlString)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data ?? '',
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Icon(Icons.error),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: PRIMARY_COLOR,
              ),
            );
          },
        ),
      );
}
