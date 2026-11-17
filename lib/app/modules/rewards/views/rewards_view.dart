import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../components/ad_banner_slot.dart';
import '../../../controllers/ads_service.dart';
import '../providers/reward_wallet_provider.dart';

class RewardsView extends ConsumerStatefulWidget {
  const RewardsView({super.key});

  @override
  ConsumerState<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends ConsumerState<RewardsView> {
  bool _loadingAd = false;
  static const int _videoReward = 10;

  Future<void> _watchVideo() async {
    if (_loadingAd) return;
    setState(() => _loadingAd = true);
    final available = await CalendarioAds.showRewarded(
      onRewardEarned: (points) {
        unawaited(ref.read(rewardWalletProvider.notifier).addPoints(points));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Has ganado $points puntos!')),
          );
        }
      },
    );
    if (!mounted) return;
    setState(() => _loadingAd = false);
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El vídeo todavía no está disponible. Inténtalo de nuevo en unos segundos.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = ref.watch(rewardWalletProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/menu');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver al menú',
        ),
        title: const Text('Recompensas'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: wallet.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('No se pudo cargar el saldo: $error')),
                data: (data) => ListView(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
                  children: [
                    Container(
                      padding: EdgeInsets.all(22.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                          SizedBox(height: 14.h),
                          const Text(
                            'Tus puntos',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${data.balance}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Puntos disponibles',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Consigue puntos',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: theme.colorScheme.primary,
                                size: 30.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ver un vídeo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'Completa el anuncio para ganar $_videoReward puntos',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            FilledButton(
                              onPressed: _loadingAd ? null : _watchVideo,
                              child: _loadingAd
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Ver'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Más formas de conseguir puntos estarán disponibles próximamente.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Actividad reciente',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (data.history.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 22.h),
                        child: Text(
                          'Todavía no has conseguido puntos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...data.history.map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.play_arrow_rounded),
                          ),
                          title: const Text('Anuncio recompensado'),
                          subtitle: Text(
                            '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year} · ${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: Text(
                            '+${entry.points}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 12.h),
                    Text(
                      'Modo de prueba: los puntos se guardan en este dispositivo y no tienen valor económico.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AdBannerSlot(),
          ],
        ),
      ),
    );
  }
}
