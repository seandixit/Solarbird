import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({Key? key}) : super(key: key);

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  String currentLanguage = 'English'; // Change this to get current language dynamically

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('About'),
          bottom: PreferredSize(
            child: Divider(
              color: Colors.grey,
              height: 1,
            ),
            preferredSize: Size.fromHeight(1),
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('Project'),
              onTap: () {
                Navigator.pushNamed(context, '/projectpage');
              },
            ),
            ListTile(
              title: Text('Send Feedback'),
              onTap: () {
                Navigator.pushNamed(context, '/feedbackpage');
                // Add action for Send feedback
              },
            ),
            ListTile(
              title: Text('App Language'),
              subtitle: Text(currentLanguage),
              onTap: () {
                Navigator.pushNamed(context, '/languagepage');
                // Add action for App Language
              },
            ),
            ListTile(
              title: Text('Privacy Statement'),
              onTap: () {
                Navigator.pushNamed(context, '/privacypage');
                // Add action for Privacy statement
              },
            ),
            ListTile(
              title: Text('Acknowledgement'),
              onTap: () {
                Navigator.pushNamed(context, '/termspage');
                // Add action for Terms and Conditions
              },
            ),
          ],
        ),
      ),
    );
  }
}