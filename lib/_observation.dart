import 'package:flutter/material.dart';
import 'main.dart';

const List<String> numberofbirds = <String>['1', '2-10', '10+'];
const List<String> howbig = <String>['small', 'medium', 'large'];
const List<String> whereisit = <String>['on the ground', 'flying', 'in a tree'];
const List<String> species = <String>[
  'American Robin', 'Northern Cardinal','Blue Jay',"Steller's Jay",
'Mourning Dove', 'American Crow', 'European Starling', 'Northern Mockingbird', 'Black-billed Magpie',
'Dark-eyed Junco', 'Black-capped Chickadee', 'White-breasted Nuthatch','Tufted Titmouse', 'House Sparrow',
'House Wren', 'House Finch', 'American Goldfinch', 'Downy Woodpecker', 'Hairy Woodpecker', 'Red-bellied Woodpecker'];



class observation extends StatefulWidget {
  const observation({super.key});

  @override
  State<observation> createState() => _observationState();
}

class _observationState extends State<observation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {_navigateToSeeBird(context);}, child: Text("I see a bird")),
                ElevatedButton(onPressed: () {_navigateToObservation2(context);}, child: Text("I hear a bird")),
                ElevatedButton(onPressed: () {_navigateToObservation2(context);}, child: Text("testing"))
              ],
            )

        )
    );
  }

  void _navigateToSeeBird(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => seebird()));
  }

  void _navigateToHearBird(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => hearbird()));
  }

  void _navigateToObservation2(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => observation2()));
  }
}


class seebird extends StatefulWidget {
  const seebird({super.key});

  @override
  State<seebird> createState() => _seebirdState();
}

class _seebirdState extends State<seebird> {
  @override
  Widget build(BuildContext context) {
    return Text("a");
  }
}

class hearbird extends StatefulWidget {
  const hearbird({super.key});

  @override
  State<hearbird> createState() => _hearbirdState();
}

class _hearbirdState extends State<hearbird> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}







class observation2 extends StatefulWidget {
  const observation2({super.key});

  @override
  State<observation2> createState() => _observation2State();
}

class _observation2State extends State<observation2> {
  String dropdownValue1 = numberofbirds.first;
  String dropdownValue2 = howbig.first;
  String dropdownValue3 = whereisit.first;
  String dropdownValue4 = species.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text("How many Birds do you see?(pick one to observe)"),
            DropdownButton<String>(
              value: dropdownValue1,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue1 = value!;
                });
              },
              items: numberofbirds.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            Text("How big is the bird"),
            DropdownButton<String>(
              value: dropdownValue2,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue2 = value!;
                });
              },
              items: howbig.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            Text("Where is the bird"),
            DropdownButton<String>(
              value: dropdownValue3,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue3 = value!;
                });
              },
              items: whereisit.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            Text("What kind of bird is it? (leave blank if unsure)"),
            DropdownButton<String>(
              value: dropdownValue4,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue4 = value!;
                });
              },
              items: species.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {Navigator.pop(context);}, child: Text("Submit Observation"))
          ],
        ),
      ),
    );
  }
  void submit(){
    //TODO compile all data
  }
}
