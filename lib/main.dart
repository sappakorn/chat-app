import 'package:app/bindings/auth_binding.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/auth/login.dart';
import 'package:app/firebase_options.dart';
import 'package:app/views/pages/home/home_screen.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:app/views/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put(AuthLoginService());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        primarySwatch: Colors.red,
      ),
      darkTheme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(),
        brightness: Brightness.dark,
      ),
      initialRoute: '/splashScreen',
      initialBinding: AuthBinding(),
      getPages: [
        GetPage(name: '/splashScreen', page: () => SplashScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
      ],
    );
  }
}
