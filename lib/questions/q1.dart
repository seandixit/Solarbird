import 'package:flutter/material.dart';

class Tab extends StatefulWidget {
  const Tab({Key? key}) : super(key: key);

  @override
  State<Tab> createState() => _ObserveTabState();
}

class _ObserveTabState extends State<Tab> {
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
          Slider(
              value: _currentSliderValue,
              max: 5,
              divisions: 5,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              })
        ])));
  }
}
