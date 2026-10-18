import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/app/modules/ajustes/views/pages/util/connector_parameter.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/util/app_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  PrivacyPolicyPage({super.key});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  late Future<String> _policyFuture;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  void _loadPolicy() {
    _policyFuture = ref.read(ajustesProvider.notifier).getDataByGet(
      ConnectorParameter(AppLink.privacyPolicyUrlString),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          title: Text(
            'Política de privacidad',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
        ),
        body: FutureBuilder<String>(
          future: _policyFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data ?? '',
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: IconButton(
                  tooltip: 'Reintentar',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(_loadPolicy);
                  },
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: PRIMARY_COLOR),
            );
          },
        ),
      );
}
