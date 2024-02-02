import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class StartedTab extends StatefulWidget {
  const StartedTab({Key? key}) : super(key: key);

  @override
  State<StartedTab> createState() => _StartedTabState();
}

class _StartedTabState extends State<StartedTab> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(width: MediaQuery.of(context).size.width * .75,child: Align(alignment: Alignment.center, child: Text("Getting started"),),),
            Container(margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width /8) ,child: Align(alignment: Alignment.centerLeft, child: Text('''
            hello
            here are the steps to use this app
            1. select the observation tab
            2. take a photo of the bird
            3. select what size bird you see
            4. describe what the bird is doing
            5. describe where the bird is
            5. can you hear the bird if so take a recording
            '''),),),
          ],
        )
      ),
    );
  }
}
