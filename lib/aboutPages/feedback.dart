import 'package:flutter/material.dart';

// TODO: send feedback to firebase
class FeedbackPage extends StatelessWidget{
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your Feedback:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              TextField(
                maxLines: 8, // adjust as needed
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9E9E9E), width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF69A06), width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Add your feedback submission logic here
                  // For example, you can get the feedback text using a TextEditingController
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFF69A06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('Submit', style: TextStyle(fontSize: 16.0)),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Contact info: sedixit@iu.edu',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

