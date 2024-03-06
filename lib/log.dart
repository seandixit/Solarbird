import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogTab extends StatefulWidget {
  const LogTab({Key? key}) : super(key: key);

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  String? _emailId;
  bool? _consent2;
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Function to load data from SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailId = (prefs.getString('emailid') ?? '').isEmpty ? 'Email ID not provided' : prefs.getString('emailid');
      _name = (prefs.getString('name') ?? '').isEmpty ? 'Name not Provided' : prefs.getString('name');

    });

    print(_emailId);
  }

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
        bottom: PreferredSize(
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
          preferredSize: Size.fromHeight(1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'User Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
            child: Text(
              _emailId ?? "Email ID not provided", // Replace with the user's email ID
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
            child: Text(
              _name ?? "Name not Provided", // Replace with the user's email ID
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
                  title: Text(observation), // TODO: If there are no observations, show button

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
