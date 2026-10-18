import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportantIndicatorTextView extends ConsumerWidget {
  const ImportantIndicatorTextView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soloImportantes =
        ref.watch(notasListProvider.select((state) => state.soloImportantes));

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      firstChild: const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Solo se estan mostrando las marcadas como importantes',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      secondChild: Container(height: 2),
      crossFadeState: soloImportantes
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}
