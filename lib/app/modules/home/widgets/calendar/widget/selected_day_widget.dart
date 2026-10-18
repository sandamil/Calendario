import 'package:calendario2/app/modules/home/providers/calendar_providers.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SelectedDayWidget extends ConsumerWidget {
  const SelectedDayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMonth = ref.watch(focusedMonthProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        DateFormat.MMMM('es').add_y().format(focusedMonth).toUpperCase(),
        style: CustomTextStyle.appBarTitle(context: context),
      ),
    );
  }
}
