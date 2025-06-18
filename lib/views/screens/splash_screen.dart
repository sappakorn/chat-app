import 'package:app/services/firebase_api.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      await FirebaseApi().initNotification();
      Future.delayed(const Duration(seconds: 2), () {
        Get.off(() => LoginPage(), transition: Transition.noTransition);
      });
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final spinkit = SpinKitFadingCircle(
      color: Colors.white,
      size: 50.0,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/splashScreenBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/splashScreenLogo.png',
              width: 400,
              height: 400,
            ),
            Transform.translate(
              offset: Offset(0, -120),
              child: Text(
                'MBKMALL',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -120),
              child: Text(
                'Live Chat',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50),
            spinkit,
          ],
        ),
      ),
    );
  }
}
