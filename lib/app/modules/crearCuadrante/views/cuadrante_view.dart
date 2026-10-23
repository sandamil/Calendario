import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:calendario2/app/components/custom_dialog.dart';
import 'package:calendario2/app/modules/crearCuadrante/widgets/beautifulAlertDialog.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/theme/my_fonts.dart';
import 'package:calendario2/config/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendario2/app/controllers/tutorial_provider.dart';
import 'package:calendario2/app/controllers/ads_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../home/providers/calendar_providers.dart';
import '../providers/crear_cuadrante_provider.dart';
import 'add_cuadrante_view.dart';

class CrearCuadranteView extends ConsumerWidget {
  const CrearCuadranteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: !(!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if ((!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 58.h,
          titleSpacing: 2.w,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.home,
              color: PRIMARY_COLOR,
              size: 26.sp,
            ),
            onPressed: () {
              ProviderScope.containerOf(context, listen: false)
                  .read(adsProvider.notifier)
                  .ensureHomeBanner();
              context.go('/home');
            },
          ),
          title: Text(
            'Cuadrantes',
            style: CustomTextStyle.appBarTitle(context: context),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: controller.submit()
          //         ? () async {
          //             //Todo carcgar primera pagina de calendario
          //
          //             showAlertLoadingDialog(context);
          //             await controller.cuadranteLoad();
          //           }
          //         : () => alertDialog(context),
          //     icon: controller.submit()
          //         ? Icon(
          //             Icons.done,
          //             color: Colors.green,
          //             size: 24.sp,
          //           )
          //         : Icon(
          //             Icons.done_outline,
          //             color: PRIMARY_COLOR.withValues(alpha: 0.4),
          //             size: 24.sp,
          //           ),
          //     key: controller.firstTime.value
          //         : key,
          //   )
          // ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'crearCuadrante',
          elevation: 2,
          backgroundColor: PRIMARY_COLOR,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          onPressed: () {
            ref.read(crearCuadranteProvider.notifier).resetForCreate();
            context.push('/add-cuadrante');
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Crear cuadrante'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 4.h),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .42),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            Text('Mis cuadrantes',
                                style: CustomTextStyle.textCuadranteMenu.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                )),
                            const Spacer(),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                MyCustomDialog.myConfirmDialogBody(
                                    circularColor: Colors.redAccent,
                                    context: context,
                                    title: 'Eliminar TODOS',
                                    desc: 'Si aceptas y pulsas ok eliminaras,'
                                        '\ntodos los cuadrantes creados.'
                                        '\nY LOS TURNOS AÑADIDOS MANUALMENTE',
                                    onTapOK: () {
                                      ref
                                          .read(crearCuadranteProvider.notifier)
                                          .deleteAllCuadrante();
                                      Navigator.of(context).pop();
                                    },
                                    onTapCancel: () =>
                                        Navigator.of(context).pop());
                              },
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: Colors.red.withValues(alpha: .10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.r),
                                ),
                              ),
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                size: 22.sp,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Consumer(builder: (context, ref, child) {
                          return Container(
                            height: 200.h,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: ref
                                  .watch(crearCuadranteProvider)
                                  .cuadrantesNameList
                                  .length,
                              itemBuilder: (context, index) {
                                final name = ref
                                    .watch(crearCuadranteProvider)
                                    .cuadrantesNameList[index];

                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Card(
                                    color: Theme.of(context).colorScheme.surface,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4)),
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Consumer(
                                          builder: (context, ref, child) {
                                            return IconButton(
                                              onPressed: () async {
                                                final preparado = await ref
                                                    .read(crearCuadranteProvider
                                                        .notifier)
                                                    .prepareEdit(name);

                                                if (!context.mounted) return;

                                                if (!preparado) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'No se han encontrado datos para este cuadrante.',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                context.push('/add-cuadrante');
                                              },
                                              style: IconButton.styleFrom(
                                                foregroundColor: PRIMARY_COLOR,
                                                backgroundColor: PRIMARY_COLOR.withValues(alpha: .10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.r),
                                                ),
                                              ),
                                              icon: const Icon(Icons.edit_calendar_rounded),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          onPressed: () => ref
                                              .read(crearCuadranteProvider
                                                  .notifier)
                                              .deleteCuadrante(name),
                                          style: IconButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            backgroundColor: Colors.red.withValues(alpha: .08),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                          ),
                                          icon: const Icon(Icons.delete_outline_rounded),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              //   RadioListTile(
                              //     title: Text(controller.languages[index].name),
                              //     value: controller.languages[index].languageCode,
                              //     groupValue: controller.selectedLanguage.value.languageCode,
                              //     onChanged: (value) {
                              //       log('pressed: ${controller.languages[index].languageCode}');
                              //       controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
                              //     },
                              //   ),
                              // ),
                              // children: [
                              //   ...List.generate(
                              //     controller.languages.length,
                              //     (index) => RadioListTile(
                              //       title: Text(controller.languages[index].name),
                              //       value: controller.languages[index].languageCode,
                              //       groupValue: controller.selectedLanguage.value.languageCode,
                              //       onChanged: (value) {
                              //         controller.setSelectedShippingTypeIndex(controller.languages[index].languageCode);
                              //       },
                              //     ),
                              //     // ListTile(leading: ,trailing: ,)
                              //   ),
                              // ],
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  alertDialog(BuildContext context) {
    showAnimatedDialog(
      animationType: DialogTransitionType.scale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const BeautifulAlertDialog();
      },
    );
  }

  showAlertLoadingDialog(BuildContext context) {
    Widget okButton = Consumer(builder: (context, ref, child) {
      return TextButton(
        child: ref.watch(crearCuadranteProvider).cuadranteLoading
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(),
              )
            : const Text('Calendario'),
        onPressed: () async {
          ProviderScope.containerOf(context, listen: false)
              .read(adsProvider.notifier)
              .ensureHomeBanner();

          context.go('/home');
        },
      );
    });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Espera a que cargue el cuadrante"),
      content: const Text(
          "Cuando se haya cargado el cuadrante el boton se habilitara para llevarte a la pagina de calendario"),
      actions: [
        okButton,
      ],
    );
    showAnimatedDialog(
      context: context,
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 900),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
