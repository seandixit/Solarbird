// TODO finish getting all data to submit, finish slider display



import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eclipse/observe2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selectable_box/selectable_box.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:eclipse/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Map<String, dynamic> observationData = <String, dynamic>{
  "flying": false,
  "ground": false,
  "tree": false,
  "singing": false,
  "eating": false,
  "sleeping": false,
  "lat": null,
  "lang": null,
  "bird": null,
  "practice": false,
};

List doing = [
  "Flying",
  "Swimming",
  "Singing",
  "On ground",
  "On wire, fence or building",
  "Eating",
  "Perched in tree/bush (alone)",
  "Perched in tree/bush (multiple birds)",
  "Other"
];

class Observation extends StatefulWidget {
  const Observation({super.key});

  @override
  State<Observation> createState() => _ObservationState();
}

class _ObservationState extends State<Observation> {
  List<bool> dataOut = List.filled(doing.length, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(child: Text("Watch the bird for:")),
        Countdown(
            seconds: 30,
            build: (_, double time) => Text(time.toInt().toString(),
                style: const TextStyle(fontSize: 100))),
        Center(child: Text("Check anything that the bird did")),
        GridView.builder(
            itemCount: doing.length,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (BuildContext context, int index) {
              return SelectableBox(
                  checkboxPadding: const EdgeInsets.all(0),
                  selectedIcon: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  unSelectedIcon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  onTap: () {
                    setState(() {
                      dataOut[index] = !dataOut[index];
                    });
                  },
                  isSelected: dataOut[index],
                  child: Center(child: Text(doing[index])));
            }),

        /* GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: [
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox1 = !checkbox1;
                  });
                  observationData.update("flying", (value) => checkbox1);
                },
                isSelected: checkbox1,
                child: Center(child: Text("Flying"))),
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox2 = !checkbox2;
                  });
                  observationData.update("ground", (value) => checkbox2);
                },
                isSelected: checkbox2,
                child: Center(child: Text("On the ground"))),
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox3 = !checkbox3;
                  });
                  observationData.update("tree", (value) => checkbox3);
                },
                isSelected: checkbox3,
                child: Center(child: Text("Sitting in a tree"))),
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox4 = !checkbox4;
                  });
                  observationData.update("singing", (value) => checkbox4);
                },
                isSelected: checkbox4,
                child: Center(child: Text("Singing"))),
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox5 = !checkbox5;
                  });
                  observationData.update("eating", (value) => checkbox5);
                },
                isSelected: checkbox5,
                child: Center(child: Text("Eating"))),
            SelectableBox(
                checkboxPadding: const EdgeInsets.all(0),
                selectedIcon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                unSelectedIcon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    checkbox6 = !checkbox6;
                  });
                  observationData.update("sleeping", (value) => checkbox6);
                },
                isSelected: checkbox6,
                child: Center(child: Text("Sleeping/In nest"))),
          ],
        ),
        */

        ElevatedButton(
            onPressed: () {
              _navigateToObservation2(context);
            },
            child: const Text("Continue"))
      ],
    )));
  }

  void _navigateToObservation2(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => observation2()));
  }
}

class observation2 extends StatefulWidget {
  const observation2({super.key});

  @override
  State<observation2> createState() => _observation2State();
}

class _observation2State extends State<observation2> {
  int selectedIndex = 0;
  double _currentSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Select the approximate size of the bird"),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Image.asset("lib/sources/bird sizes.png"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4),
                  activeTickMarkColor: Colors.red,
                  inactiveTickMarkColor: Colors.red,
                ),
                child: Slider(
                    value: _currentSliderValue,
                    max: 100,
                    divisions: 6,
                    label: sliderDisplay(_currentSliderValue.round()),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    }),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  submit();
                  Navigator.pop(context);
                },
                child: Text("Submit Observation"))
          ]),
    );
  }

  void submit() {
    db.collection("data").add(observationData);
    if (kDebugMode) {
      print(observationData);
    }
    //TODO compile all data

    //TODO add obscuration, gps, ip address, time, relative time +/- and delta
  }
}

sliderDisplay(int value) {
  int div = 6;
  if (value < 1) {
    return "Tiny";
  } else if (value < 15) {
    return "Small";
  } else if (value < 29) {
    return "Medium";
  } else if (value < 43) {
    return "large";
  } else if (value < 58) {
    return "Largest";
  } else if (value < 71) {
    return "Largest";
  } else if (value < 85) {
    return "Largest";
  } else if (value < 101) {
    return "Largest";
  }
}
