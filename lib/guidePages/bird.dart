import 'package:flutter/material.dart';

class BirdPage extends StatelessWidget{
  const BirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bird Bootcamp")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Bird Watching 101",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Careful Observation is the First Step in Discovery",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top:10.0, bottom:10, right:4),
                child: Text(
                  "Behavioral biologists compile and describe behaviors they observe in animals. This comprehensive list of behaviors is called an ethogram.",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      TableCell(child: Center(child: Text("ETHOGRAM", style: TextStyle(fontWeight: FontWeight.bold)))),
                      TableCell(child: Center(child: Text("Behavior", style: TextStyle(fontWeight: FontWeight.bold)))),
                      TableCell(child: Center(child: Text("Definition", style: TextStyle(fontWeight: FontWeight.bold)))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Flying"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Soaring in the sky; Moving through the air"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Swimming"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Moving along a body of water"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Singing / Calling"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Vocalizing; Making sound"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Walking"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Moving along the ground"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Sitting"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Stationary on an object or structure (wire, fence, roof)"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Eating"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Taking food from a bird feeder or foraging on the ground"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Perched (alone)"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Stationary in a tree or bush by itself"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),
                    TableRow(children: [
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Perched (with other birds)"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Stationary in a tree or bush with at least 1 other bird"))),
                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(""))),
                    ]),

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "Some of these behaviors can be happening at the same time.\nFor example, a bird could be perched in a tree and singing.",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:16, top: 12.0),
                child: Text(
                  "List of Birds",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10),
                child: Text(
                  "Common birds found near you",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

