// ignore_for_file: prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_constructors, depend_on_referenced_packages

import 'dart:io';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/state/list_coach_provider.dart';
import 'package:badminton_management_1/bbcontroll/state/list_learningprocess_provider.dart';
import 'package:badminton_management_1/bbcontroll/state/list_rollcallcoach_provider.dart';
import 'package:badminton_management_1/bbcontroll/state/list_rollcallstudent_provider.dart';
import 'package:badminton_management_1/bbcontroll/state/list_student_provider.dart';
import 'package:badminton_management_1/bbcontroll/state/list_tuitions_provider.dart';
import 'package:badminton_management_1/ccui/ccauth/first_view.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/firebase_options.dart';
import 'package:badminton_management_1/notification/fcm_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  tz.initializeTimeZones();
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('google_fonts/Roboto/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await FCMController().initToState().catchError((error) {
    print("Error initializing FCMController: $error");
  });
  HttpOverrides.global = MyHttpOverrides();

  runApp(MainApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  late FlutterLocalization localization;

  Locale _locale = const Locale('vi', 'VN');

  @override
  void initState() {
    localization = FlutterLocalization.instance;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ListStudentProvider()),
        ChangeNotifierProvider(
            create: (context) => ListRollcallcoachProvider()),
        ChangeNotifierProvider(
            create: (context) => ListRollcallStudentProvider()),
        ChangeNotifierProvider(
            create: (context) => ListLearningprocessProvider()),
        ChangeNotifierProvider(create: (context) => ListTuitionsProvider()),
        ChangeNotifierProvider(create: (context) => ListCoachProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
              textTheme: GoogleFonts.robotoTextTheme(),
              colorScheme:
                  ColorScheme.fromSeed(seedColor: AppColors.pageBackground)),
          home: FirstView()),
    );
  }
}
