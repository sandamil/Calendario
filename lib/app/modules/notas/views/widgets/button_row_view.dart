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
                    : Colors.transparent,
                border: Border.all(
                  width: state.soloImportantes ? 2 : 1,
                  color: state.soloImportantes
                      ? Colors.red.shade700
                      : MyColors.borderAccentLine,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
              padding: EdgeInsets.only(left: 10.w),
              height: 42.h,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.borderAccentLine),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Busqueda',
                        hintStyle: TextStyle(
                          color: MyColors.borderAccentLine,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.busqueda.isEmpty
                          ? Icons.search
                          : Icons.cancel,
                      color: MyColors.borderAccentLine,
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
