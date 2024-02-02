import 'package:flutter/material.dart';


class ObserveTab extends StatefulWidget {
  const ObserveTab({Key? key}) : super(key: key);

  @override
  State<ObserveTab> createState() => _ObserveTabState();
}

class _ObserveTabState extends State<ObserveTab> {

  List<Widget> pages = <Widget>[
    home(key: PageStorageKey<String>('home'),),
    question2(key: PageStorageKey<String>('q2'),)
  ];
  int currentTab = 1;
  final PageStorageBucket _bucket = PageStorageBucket();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: PageStorage(
            bucket: _bucket,
            child: pages[currentTab],
          ),
    ));
  }
}

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("place holder for progress bar"),
                  ElevatedButton(onPressed: () {}, child: Text("I see a bird.")),
                  ElevatedButton(onPressed: () {}, child: Text("I dont see a bird."))
                ],
              )),
        ));
  }
}




class question2 extends StatefulWidget {
  const question2({super.key});

  @override
  State<question2> createState() => _question2State();
}

class _question2State extends State<question2> {
  double _currentSliderValue = 1;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Use the slider to select the size of the bird you saw"),
                  Image.asset('lib/sources/bird_shapes.jpg'),
                  Slider(
                      value: _currentSliderValue,
                      max: 100,
                      divisions: 4,
                      label: sliderDisplay(_currentSliderValue.round()),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      })
                ])));
  }
}

sliderDisplay(int value){
  switch (value) {
    case 0:
      return "Tiny";
    case 25:
      return "Small";
    case 50:
      return "Medium";
    case 75:
      return "large";
    case 100:
      return "Largest";
  }
}