import 'package:flutter/material.dart';

class ProjectPage extends StatelessWidget{
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Community Science",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0),
            Text(
              "Engage the public and show the importance of being a community scientist\n",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("How this will enhance solar eclipse experience"),
            Text("Contribute to real science"),
            Text("Data will be analyzed and results shared with participants"),
            SizedBox(height: 20),
            Text(
              "Research",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0),
            Text(
              "Learn more about animal behavior during a solar eclipse\n",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("What we know:"),
            Text("Eclipses can change environmental cues that impact animal behavior"),
            Text("Most notably the shift in light as we reach totality"),
            Text("Even if it’s cloudy and we can’t see the eclipse, it will get dark and animals will respond"),
            Text("Common responses to eclipses depend on whether an animal is nocturnal (active at night) or diurnal (active during the day)"),
            Text("Animals may think it’s nighttime or perceive as an oncoming storm"),
            Text("Data on animal responses remains limited, so there’s still a lot to learn"),
            SizedBox(height: 20),
            Text(
              "Capitalize on important period for birds\n",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Migration and territorial establishment"),
            Text("April will be the start of peak bird migration"),
            Text("Can ask research questions, such as:"),
            Text("Do birds change their behavior over the course of the eclipse?"),
            Text("To what degree do behaviors differ along the path of the eclipse?"),
          ],
        ),
      ),
    );
  }
}

