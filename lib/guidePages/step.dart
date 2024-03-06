import 'package:flutter/material.dart';

class StepPage extends StatelessWidget{
  const StepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step-by-Step")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Instructions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBulletPoint("Find a bird – outside in your surroundings or seen from your window. This is your solarbird!"),
              buildBulletPoint("Observe its behavior at three separate time points: "),
              Text("        1. before totality\n"
                  "        2. during totality\n"
                  "        3. after totality"),
              buildBulletPoint("It does not have to be the same bird for every observation."),
              buildBulletPoint("At each time point, observe the bird for 30 seconds. You will be prompted to select the behaviors you observe the bird doing."),
              buildBulletPoint("After the 30 seconds, you will be provided a list of birds commonly found near you to identify your solarbird."),
              buildBulletPoint("If you don’t see a bird, determine if you hear one and identify it if possible."),
            ],),
              SizedBox(height: 16),

              Text(
                "Safety Reminders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBulletPoint("Do not touch or engage with any wild animals."),
                  buildBulletPoint("Use eclipse glasses."),
                  buildBulletPoint("Be cautious if using binoculars to observe birds (they are not required for observing and unsafe for viewing the eclipse)."),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Icon(
            Icons.brightness_1,
            size: 10,
            color: Color(0xFFF69A06), // Adjust bullet point color here
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white), // Adjust text color here
          ),
        ),
      ],
    );
  }
}


