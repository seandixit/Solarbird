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
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PageView(
            physics: const ClampingScrollPhysics(),
            controller: controller,
            children: _list,),
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedLabelStyle: const TextStyle(color: Colors.black),
          selectedLabelStyle: const TextStyle(color: Colors.black),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.pen),
              label: "Learn",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.alt),
              label: "Getting started"
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: "Observation"
            )
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
