import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class LearningTab extends StatefulWidget {
  const LearningTab({Key? key}) : super(key: key);

  @override
  State<LearningTab> createState() => _LearningTabState();
}

class _LearningTabState extends State<LearningTab> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Icon(CupertinoIcons.pen,
          size: 150)
        ),
      ),
    );
  }
}
