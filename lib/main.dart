import 'package:eclipse/aboutPages/language.dart';
import 'package:eclipse/aboutPages/privacy.dart';
import 'package:eclipse/aboutPages/terms.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// TODO: if consent1 not signed, keep showing
// TODO: check if valid email id
class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  late SharedPreferences _prefs;
  String? _emailId;
  bool? _consent1;
  bool? _consent2;

  String? temp_emailid;
  bool temp_consent1 = false;
  bool temp_consent2 = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // Function to load data from SharedPreferences
  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // Initialize variables with data from SharedPreferences or default values
      _emailId = _prefs.getString('emailid') ?? '';
      _consent1 = _prefs.getBool('consent1') ?? false;
      _consent2 = _prefs.getBool('consent2') ?? false;
    });
  }
  // Function to save data to SharedPreferences
  Future<void> _saveData() async {
    _emailId = temp_emailid;
    _consent1 = temp_consent1;
    _consent2 = temp_consent2;
    await _prefs.setString('emailid', _emailId!);
    await _prefs.setBool('consent1', _consent1!);
    await _prefs.setBool('consent2', _consent2!);
  }

  PageController controller=PageController(
    initialPage: 0,
  );
  List<Widget> _list = <Widget>[
    new Center(child: new home.HomeTab()),
    new Center(child: new guide.GuideTab()),         // TODO: fyi I replaced LearningTab for this
    new Center(child: null),
    new Center(child: new log.LogTab()),
    new Center(child: new about.AboutTab()),
    new Center(child: observation.observation()),
  ];

  @override
  Widget build(BuildContext context) {
    double bottomNavigationBarHeight = MediaQuery.of(context).size.height * 0.1;

    if (_emailId?.isEmpty ?? true) { // return consent/emailid screen
      return MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: Text('Consent Screen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Please provide your email and consent',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40.0, // Adjust width here
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        temp_emailid = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                ),
              ),
              CheckboxListTile(
                title: Text('By checking this box, you agree to sharing your observations to IU for research purposes only.'),
                value: temp_consent1,
                onChanged: (value) {
                  setState(() {
                    temp_consent1 = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('By checking this box, you agree to being sent updates on research carried out involving your observations.'),
                value: temp_consent2,
                onChanged: (value) {
                  setState(() {
                    temp_consent2 = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveData(); // Save data to SharedPreferences
                  setState(() {}); // Rebuild UI
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ));
    }
    else{
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
  }}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      controller.jumpToPage(index);
    });
  }


}