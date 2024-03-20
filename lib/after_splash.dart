import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eclipse/aboutPages/language.dart';
import 'package:eclipse/aboutPages/privacy.dart';
import 'package:eclipse/aboutPages/terms.dart';
import 'package:eclipse/guidePages/bird.dart';
import 'package:eclipse/guidePages/practice.dart';
import 'package:eclipse/guidePages/step.dart';
import 'package:eclipse/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import 'log.dart' as log;
import 'observation.dart' as observation;
import 'learning.dart' as learning;
import 'observation.dart';
import 'observe2.dart' as observe;
import 'started.dart' as started;
import 'home.dart' as home;
import 'about.dart' as about;
import 'guide.dart' as guide;
import 'aboutPages/project.dart';
import 'aboutPages/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AfterSplashPage());
}


class AfterSplashPage extends StatefulWidget {
  const AfterSplashPage({Key? key}) : super(key: key);

  @override
  State<AfterSplashPage> createState() => _AfterSplashPageState();
}

class _AfterSplashPageState extends State<AfterSplashPage> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    return MaterialApp(
      title: 'Splash Screen',
      home: const SplashScreen(),
    );
  }

}