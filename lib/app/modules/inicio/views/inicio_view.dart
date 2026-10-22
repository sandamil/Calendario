import 'package:calendario2/app/services/app_cycle_service.dart';
import 'package:calendario2/config/util/assets.dart';
import 'package:calendario2/config/util/typewriter/animated_text.dart';
import 'package:calendario2/config/util/typewriter/typewriter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InicioView extends StatefulWidget {
  const InicioView({Key? key}) : super(key: key);

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkRoute();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (!mounted) return;
    setState(() => _expanded = true);
  }

  Future<void> _checkRoute() async {
    await Future.delayed(const Duration(milliseconds: 1050));
    if (!mounted) return;
    await AppCycleService().checkFirstTimeAndRoute();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          repeatForever: true,
          animatedTexts: [
            TypewriterAnimatedText(
              'Ajatsoft\t\u00a9',
              speed: const Duration(microseconds: 50000),
              textStyle: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: _expanded ? width : width * 0.0001,
          height: _expanded ? width : width * 0.0001,
          child: Image.asset(AppAsset.logo('logo_app.png')),
        ),
      ),
    );
  }
}
