import 'package:flutter/material.dart';

class PracticeStep extends StatelessWidget{
  const PracticeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Practice Submission",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Try out an observation to practice for the big eclipse day! \n"
                    "Go outside or look out a window to find a bird. \n"
                    "Observe its behavior, selecting the ones you see.\n"
                    "Use the list of birds to try and identify the species.",
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 16),
              Center( // Centering the button
                child: ElevatedButton(
                  onPressed: () {
// Add your onPressed logic here
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Color(0xFFF69A06)),
                  ),
                  child: Text('Practice Submission'),
                ),
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
            color: Colors.black54, // Adjust bullet point color here
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.black), // Adjust text color here
          ),
        ),
      ],
    );
  }
}