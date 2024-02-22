import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LogTab extends StatefulWidget {
  const LogTab({Key? key}) : super(key: key);

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  List<String> observations = [
    'Observation 1',
    'Observation 2',
    'Observation 3',
    // Add your observations here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'User\'s Email ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
            child: Text(
              'user@example.com', // Replace with the user's email ID
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Observations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: observations.length,
              itemBuilder: (BuildContext context, int index) {
                final observation = observations[index];
                return ListTile(
                  title: Text(observation),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        observations.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    // Handle the click on the observation item
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
