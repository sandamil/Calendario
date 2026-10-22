import 'package:flutter/material.dart';

import '../../../data/local/app_storage.dart';
import '../../../../config/util/constant.dart';
import '../../../routes/app_router.dart';

/// Resuelve la ruta inicial sin mostrar una pantalla ni una animación.
/// Se conserva para respetar el flujo de primera instalación/onboarding.
class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    try {
      final firstOpen = await AppStorage.read(key: APP_FIRST_TIME_OPEN);
      appRouter.go(firstOpen.isEmpty ? '/boarding' : '/home');
    } catch (error, stackTrace) {
      debugPrint('[STARTUP] No se pudo resolver la ruta inicial: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) appRouter.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
