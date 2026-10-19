import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ajustesProvider);
    final notifier = ref.read(ajustesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          LocalizationService.translate('Idioma', Localizations.localeOf(context)),
          style: CustomTextStyle.appBarTitle(context: context),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: settings.languages.length,
        itemBuilder: (context, index) {
          final language = settings.languages[index];

          return ListTile(
            title: Text(language.name),
            onTap: () => notifier.onLanguageTilePressed(
              language.languageCode,
            ),
            trailing: Radio<String>(
              value: language.languageCode,
              groupValue: settings.selectedLanguage.languageCode,
              onChanged: (value) {
                if (value != null) {
                  notifier.onLanguageTilePressed(value);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
