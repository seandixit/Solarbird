import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget{
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Language")),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('English'),
              onTap: () {
                // Add your logic to change the language to English
              },
            ),
          ],
        ),
      ),
    );
  }
}