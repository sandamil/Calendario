import 'package:calendario2/app/modules/ajustes/providers/ajustes_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:calendario2/config/translations/localization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ajustesProvider);
    final notifier = ref.read(ajustesProvider.notifier);
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme,
        title: Text(LocalizationService.translate('Idioma', Localizations.localeOf(context)), style: CustomTextStyle.appBarTitle(context: context)),
      ),
      body: RadioGroup<String>(
        groupValue: settings.selectedLanguage.languageCode,
        onChanged: (value) {
          if (value != null) notifier.onLanguageTilePressed(value);
        },
        child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
        physics: const BouncingScrollPhysics(),
        itemCount: settings.languages.length,
        separatorBuilder: (_, __) => SizedBox(height: 9.h),
        itemBuilder: (context, index) {
          final language = settings.languages[index];
          final selected = language.languageCode == settings.selectedLanguage.languageCode;
          return Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: () => notifier.onLanguageTilePressed(language.languageCode),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: selected ? PRIMARY_COLOR.withValues(alpha: .75) : theme.colorScheme.outlineVariant.withValues(alpha: .4), width: selected ? 1.4 : 1),
                ),
                child: Row(children: [
                  Container(width: 40.w, height: 40.w, decoration: BoxDecoration(color: PRIMARY_COLOR.withValues(alpha: selected ? .18 : .1), borderRadius: BorderRadius.circular(13.r)), child: Icon(Icons.language_rounded, color: PRIMARY_COLOR, size: 21.sp)),
                  SizedBox(width: 12.w),
                  Expanded(child: Text(language.name, style: TextStyle(fontSize: 14.sp, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: text))),
                  Radio<String>(value: language.languageCode),
                ]),
              ),
            ),
          );
        },
      )),
    );
  }
}
