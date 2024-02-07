import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';


import 'learning.dart' as learning;
import 'observe2.dart' as observe;
import 'started.dart' as started;
import 'home.dart' as home;
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
    new Center(child: new learning.LearningTab()),
    new Center(child: new started.StartedTab()),
    new Center(child: new observe.ObserveTab())
  ];

  @override
  Widget build(BuildContext context) {
    double bottomNavigationBarHeight = MediaQuery.of(context).size.height * 0.1;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PageView(
            physics: const ClampingScrollPhysics(),
            controller: controller,
            children: _list,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {}, // TODO: "MAKE AN OBSERVATION"
          tooltip: 'Increment',
          child: Icon(Icons.add),
          shape: CircleBorder(),
        ),

        bottomNavigationBar: SizedBox(
          height: bottomNavigationBarHeight,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: TextStyle(color: Colors.black),
            selectedLabelStyle: TextStyle(color: Colors.black),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: "Home",
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
                label: "List",
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
