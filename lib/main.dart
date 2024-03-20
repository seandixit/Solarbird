import 'package:awesome_notifications/awesome_notifications.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// TODO: Funding and support, put colleges under
// TODO: check if valid email id
// TODO: if outside america, dont care about getting top 10
// TODO: bolden "Max Coverage:..."
// TODO: make sure it works for different screen sizes
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
    new Center(child: observation.Observation()),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    double bottomNavigationBarHeight = MediaQuery.of(context).size.height * 0.08;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = screenHeight * 0.070; // 20% of screen height

    // TODO: CHANGE BACK
    if (_NA_verification != null && !_NA_verification!) { // return consent/emailid screen
      return MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF1E1B22),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Color(0xFF1E1B22),
        ),
          home: Scaffold(
            appBar: AppBar(
              title: Text(''),
              surfaceTintColor: Colors.transparent,
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Builder(
                      builder: (BuildContext context) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image(image: AssetImage('lib/sources/unlabelled_logo.jpg'), height: 325, width: 330),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                                child: Text(
                                  'Insert email address here if you would like to be notified of the research results',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                child: Container(
                                  height: 50.0,
                                  width: MediaQuery.of(context).size.width - 40.0, // Adjust width here
                                  child: TextField(
                                    cursorColor: Colors.white,
                                    onChanged: (value) {
                                      setState(() {
                                        temp_emailid = value;
                                      });
                                    },
                                    style: TextStyle(
                                      fontSize: 13.0, // Adjust the font size here
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      focusColor: Color(0xFFF69A06),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFF69A06), width: 2.0),
                                      ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                child: Container(
                                  height: 50.0,
                                  child: TextField(
                                    cursorColor: Colors.white,
                                    onChanged: (value) {
                                      setState(() {
                                        temp_name = value;
                                      });
                                    },
                                    style: TextStyle(
                                      fontSize: 13.0, // Adjust the font size here
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'First and Last Name',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      focusColor: Color(0xFFF69A06),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFF69A06), width: 2.0),
                                      ),
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
                                      color: Colors.white, // Color for the text without the asterisk
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
                                activeColor: Color(0xFFF69A06),
                                value: temp_NA_verification,
                                onChanged: (value) {
                                  setState(() {
                                    temp_NA_verification = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                    height: buttonHeight,
                    child: Container(
                      width: double.infinity, // Width spans the whole screen
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => super.widget,
                              ),
                            ); // Rebuild UI
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFFF69A06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0), // Rectangular shape
                          ),
                        ),
                        child: Text(
                                'Submit',
                                style: TextStyle(fontSize: 14),),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));



    }
    else{
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1B22),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1B22),
      ),
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
        body: Column( // Wrap Scaffold with Column
          children: [
            Expanded( // Wrap Scaffold's child with Expanded
              child: Center(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: _list,
                ),
              ),
            ),
            Container( // New Container for bottom navigation
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.black,
                selectedItemColor: Color(0xFFF69A06),
                unselectedItemColor: Colors.grey,
                selectedFontSize: 14,
                unselectedFontSize: 12,
                selectedLabelStyle: TextStyle(color: Colors.white),
                unselectedLabelStyle: TextStyle(color: Colors.grey),
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
                    icon: SizedBox.shrink(),
                    label: "",
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
                iconSize: 30.0,
                elevation: 0,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom:30),
          height: 60,
          width: 60,
          child: FloatingActionButton(
          backgroundColor: Color(0xFFFFD700),
          onPressed: () {
            controller.jumpToPage(5);
          },
          shape: const CircleBorder(),
          child: Image.asset('lib/sources/bino2.png', width: 90, height: 80),
        ),),
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