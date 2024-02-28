import 'package:eclipse/aboutPages/language.dart';
import 'package:eclipse/aboutPages/privacy.dart';
import 'package:eclipse/aboutPages/terms.dart';
import 'package:eclipse/guidePages/bird.dart';
import 'package:eclipse/guidePages/practice.dart';
import 'package:eclipse/guidePages/step.dart';
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
// TODO: if outside america, dont care about getting top 10
// TODO: bolden "Max Coverage:..."
class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  late SharedPreferences _prefs;
  String? _emailId;
  String? _name;
  bool? _NA_verification;

  String? temp_emailid;
  String? temp_name;
  bool temp_NA_verification = false;
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
      _name = _prefs.getString('name') ?? '';
      _NA_verification = _prefs.getBool('NA_verification') ?? false;
    });
  }
  // Function to save data to SharedPreferences
  Future<void> _saveData() async {
    _emailId = temp_emailid;
    _name = temp_name;
    _NA_verification = temp_NA_verification;
    _prefs.setString('emailid', _emailId ?? "");
    _prefs.setString('name', _name ?? "");
    _prefs.setBool('NA_verification', _NA_verification!);
  }

  PageController controller=PageController(
    initialPage: 0,
  );
  List<Widget> _list = <Widget>[
    new Center(child: new home.HomeTab()),
    new Center(child: new guide.GuideTab()),
    new Center(child: null),
    new Center(child: new log.LogTab()),
    new Center(child: new about.AboutTab()),
    new Center(child: observation.observation()),
  ];

  @override
  Widget build(BuildContext context) {
    double bottomNavigationBarHeight = MediaQuery.of(context).size.height * 0.1;


    if (_NA_verification != null && !_NA_verification!) { // return consent/emailid screen
      return MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(''),
          ),
          body: Builder( // Use Builder widget to get a context within the MaterialApp
            builder: (BuildContext context) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image(image: AssetImage('lib/sources/mainlogo.png'), height: 330, width: 330),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                      child: Text(
                        'Insert email address here if you would like to be notified of the research results',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 50.0,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                      child: Text(
                        'Insert your first and last name if you would like to be acknowledged in the expected scientific publication',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 50.0,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              temp_name = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'First and Last Name',
                          ),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                      title: RichText(
                        text: TextSpan(
                          text: 'By checking this box, you verify that you are currently located in North America',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black, // Color for the text without the asterisk
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red, // Color for the asterisk
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: temp_NA_verification,
                      onChanged: (value) {
                        setState(() {
                          temp_NA_verification = value!;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        width: double.infinity, // Width spans the whole screen
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!temp_NA_verification) {
                              // If not from North America, show dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Alert"),
                                  content: Text("Must be from North America to continue"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),

                              );
                            } else {
                              await _saveData(); // Save data to SharedPreferences
                              setState(() {}); // Rebuild UI
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0), // Rectangular shape
                            ),
                          ),
                          child: Text('Submit'),
                        ),
                      ),)
                  ],
                ),
              );
            },
          ),
        ),
      );



    }
    else{
    return MaterialApp(
      routes: {
        '/projectpage': (context) => const ProjectPage(),
        '/feedbackpage': (context) => const FeedbackPage(),
        '/languagepage': (context) => const LanguagePage(),
        '/privacypage': (context) => const PrivacyPage(),
        '/termspage': (context) => const TermsPage(),
        '/birdpage': (context) => const BirdPage(),
        '/steppage': (context) => const StepPage(),
        '/practicepage': (context) => const PracticeStep(),

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
          child: const Icon(Icons.camera_alt_rounded, color: Colors.black,),
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