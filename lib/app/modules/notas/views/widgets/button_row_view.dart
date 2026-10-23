import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/modules/notas/providers/notas_list_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonRowView extends ConsumerStatefulWidget {
  const ButtonRowView({Key? key}) : super(key: key);

  @override
  ConsumerState<ButtonRowView> createState() => _ButtonRowViewState();
}

class _ButtonRowViewState extends ConsumerState<ButtonRowView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notasListProvider);
    final notifier = ref.read(notasListProvider.notifier);

    final tutorialController = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(tutorialControllerProvider);

    // Sincroniza el campo si la búsqueda se limpia desde el provider.
    if (_searchController.text != state.busqueda) {
      _searchController.value = TextEditingValue(
        text: state.busqueda,
        selection: TextSelection.collapsed(
          offset: state.busqueda.length,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: notifier.toggleSoloImportantes,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 42.h,
              width: 35.w,
              curve: Curves.slowMiddle,
              decoration: BoxDecoration(
                color: state.soloImportantes
                    ? Colors.red
                    : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .48),
                border: Border.all(
                  width: state.soloImportantes ? 1.5 : 1,
                  color: state.soloImportantes
                      ? Colors.red.shade700
                      : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55),
                ),
                borderRadius: BorderRadius.all(Radius.circular(14.r)),
              ),
              key: state.tutorialVisible
                  ? tutorialController.keyButton11
                  : widget.key,
              child: Icon(
                state.soloImportantes ? Icons.flag : Icons.flag_outlined,
                color: state.soloImportantes
                    ? Colors.white
                    : MyColors.borderAccentLine,
              ),
            ),
          ),
          Expanded(
            key: state.tutorialVisible
                ? tutorialController.keyButton12
                : widget.key,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 4.w),
              padding: EdgeInsets.only(left: 12.w, right: 4.w),
              height: 48.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .48),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55)),
                borderRadius: BorderRadius.all(Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      maxLines: 1,
                      onChanged: notifier.setBusqueda,
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55)),
                        hintText: 'Buscar notas',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .48),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.busqueda.isEmpty
                          ? Icons.search
                          : Icons.cancel,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65),
                    ),
                    onPressed: () {
                      if (state.busqueda.isEmpty) {
                        FocusScope.of(context).unfocus();
                      } else {
                        notifier.limpiarBusqueda();
                        _searchController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
