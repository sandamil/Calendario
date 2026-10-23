import 'package:calendario2/app/controllers/ads_provider.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  void _open(BuildContext context, String route) {
    if (route == '/home') {
      ProviderScope.containerOf(context, listen: false).read(adsProvider.notifier).ensureHomeBanner();
    }
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final items = <_MenuItemData>[
      _MenuItemData('Notas', 'Organiza tus recordatorios', Icons.sticky_note_2_rounded, '/notas'),
      _MenuItemData('Cuadrantes', 'Gestiona tus calendarios de turnos', Icons.calendar_month_rounded, '/crear-cuadrante'),
      _MenuItemData('Tipos de turno', 'Configura horarios y colores', Icons.work_history_rounded, '/crear-turno'),
      _MenuItemData('Ajustes', 'Personaliza la aplicación', Icons.tune_rounded, '/ajustes'),
      _MenuItemData('Ayuda', 'Tutoriales y contacto', Icons.help_outline_rounded, '/ayuda'),
      _MenuItemData('Informes', 'Resumen de días, turnos y horas', Icons.analytics_rounded, '/informes'),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Volver al calendario', icon: Icon(Icons.arrow_back_rounded, color: PRIMARY_COLOR, size: 25.sp), onPressed: () => _open(context, '/home')),
        title: const Text('Menú'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760 ? 3 : 2;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Todo en un solo lugar', style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w800, color: text)),
                SizedBox(height: 5.h),
                Text('Accede rápidamente a las herramientas de Calendario.', style: TextStyle(fontSize: 13.sp, color: text.withValues(alpha: .62))),
                SizedBox(height: 20.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12.w, mainAxisSpacing: 12.h, childAspectRatio: columns == 3 ? 1.15 : 1.04),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _MenuCard(item: item, onTap: () => _open(context, item.route));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onTap});
  final _MenuItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .4)),
            boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: .045), blurRadius: 16, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 46.w, height: 46.w, decoration: BoxDecoration(color: PRIMARY_COLOR.withValues(alpha: .15), borderRadius: BorderRadius.circular(15.r)), child: Icon(item.icon, color: PRIMARY_COLOR, size: 25.sp)),
              const Spacer(),
              Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: text)),
              SizedBox(height: 4.h),
              Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5.sp, height: 1.25, color: text.withValues(alpha: .62))),
            ],
          ),
        ),
      ),
    );
  }
}
