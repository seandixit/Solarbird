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
  "flying" : false,
  "ground" : false,
  "tree" : false,
  "singing" : false,
  "eating" : false,
  "sleeping" : false,
  "lat" : null,
  "lang" : null,
  "bird" : null,


  "practice" : false,
};


class Observation extends StatefulWidget {
  const Observation({super.key});

  @override
  State<Observation> createState() => _ObservationState();
}

class _ObservationState extends State<Observation> {
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;
  bool checkbox4 = false;
  bool checkbox5 = false;
  bool checkbox6 = false;
  bool checkbox7 = false;
  bool checkbox8 = false;
  bool checkbox9 = false;


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
        GridView.count(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        //   GridView.builder(
        //   shrinkWrap: true,
        //   itemCount: birds.length,
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, ),
        //     itemBuilder: (BuildContext context, int index){
        //       return Expanded(
        //           child:Card(
        //             child: InkResponse(
        //               child: Column(children: [Text(birds.elementAt(index).elementAt(0)),birds.elementAt(index).elementAt(1)])
        //         ),
        //       ));
        //
        // }),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: birds.length,
              itemBuilder: (BuildContext context, int index){
              return ListTile(
                  title: Text(birds.elementAt(index).elementAt(0)),
                  leading: Image.asset('lib/sources/photos/american-robin.jpg', fit: BoxFit.fill,),
                  tileColor: selectedIndex == index ? Colors.blue : null,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  }
              );

              }),
          ElevatedButton(onPressed: () {observationData.update("bird", (value) => birds.elementAt(selectedIndex).elementat(0)); submit(); Navigator.pop(context);}, child: Text("Submit Observation"))
        ]
      ),
    );
  }

  void submit() {
    db.collection("data").add(observationData);
    if (kDebugMode) {
      print(observationData);
    }
    //TODO compile all data
  }
}


List birds = [
  ["Don't Know",Image.asset('lib/sources/photos/x.png')],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
  ["American Robin",Image.asset("lib/sources/photos/american-robin.jpg")],
];