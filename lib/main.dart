import 'package:eclipse/aboutPages/language.dart';
import 'package:eclipse/aboutPages/privacy.dart';
import 'package:eclipse/aboutPages/terms.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  PageController controller=PageController(
    initialPage: 0,
  );
  List<Widget> _list = <Widget>[
    new Center(child: new home.HomeTab()),
    new Center(child: new guide.GuideTab()),         // TODO: fyi I replaced LearningTab for this
    new Center(child: null), // TODO fix that you can click on this
    new Center(child: new about.AboutTab()), // TODO: fyi I replaced ObserveTab for this
    new Center(child: observation.observation())
  ];

  @override
  Widget build(BuildContext context) {
    double bottomNavigationBarHeight = MediaQuery.of(context).size.height * 0.1;
    return MaterialApp(
      routes: {
        '/projectpage': (context) => const ProjectPage(),
        '/feedbackpage': (context) => const FeedbackPage(),
        '/languagepage': (context) => const LanguagePage(),
        '/privacypage': (context) => const PrivacyPage(),
        '/termspage': (context) => const TermsPage(),

      },
      home: Scaffold(
        body: Center(
          child: PageView(
            physics: const ClampingScrollPhysics(),
            controller: controller,
            children: _list,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () {controller.jumpToPage(5);}, // TODO: "MAKE AN OBSERVATION"
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt, color: Colors.black,),
        ),

        bottomNavigationBar: SizedBox(
          height: bottomNavigationBarHeight,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: TextStyle(color: Colors.black),
            selectedLabelStyle: TextStyle(color: Colors.black),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.location_circle),
                label: "Eclipse",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                label: "Guide",
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for the middle
                label: "", // No label for the empty space
              ),

              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.list_dash),
                label: "Log",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.info),
                label: "About",
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedFontSize: 15.0,
            unselectedFontSize: 15.0,
            iconSize: 30.0,
            backgroundColor: Colors.grey[200],
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      controller.jumpToPage(index);
    });
  }


}