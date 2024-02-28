import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GuideTab extends StatefulWidget {
  const GuideTab({Key? key}) : super(key: key);

  @override
  State<GuideTab> createState() => _GuideTabState();
}

class _GuideTabState extends State<GuideTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align buttons to start from the top
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
        RoundedButton(
          icon: CupertinoIcons.book_fill,
          title: 'Bird Bootcamp',
          subtitle: 'Learn about birds and how to observe \nthem',
          onPressed: () {
            Navigator.pushNamed(context, '/birdpage');// Add action for Bird Bootcamp button
          },),
            SizedBox(height: 20),
            RoundedButton(
              icon: CupertinoIcons.flowchart_fill,
              title: 'Step-by-Step',
              subtitle: 'Instructions for submitting an observation',
              onPressed: () {
                // Add action for Step-by-Step button
                Navigator.pushNamed(context, '/steppage');
              },

            ),
            SizedBox(height: 20),
            RoundedButton(
              icon: CupertinoIcons.camera_fill,
              title: 'Practice Submission',
              subtitle: 'Try it out before the big day!',
              onPressed: () {
                Navigator.pushNamed(context, '/practicepage');
                // Add action for Bird Bootcamp button
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const RoundedButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon), // Placeholder logo
          SizedBox(width: 16), // Add spacing between icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(subtitle),
            ],
          ),
        ],
      ),
    );
  }
}


