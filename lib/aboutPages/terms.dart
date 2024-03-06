import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget{
  const TermsPage({super.key});

  // TODO: ludy logo on top/bottom
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acknowledgements")),
      body: ListView(
        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
        children: const [
          AcknowledgmentItem(
            title: 'Funding and Support',
            description:
            'Indiana Space Grant Consortium (INSGC)\nNational Science Foundation (NSF)\nCollege of Arts & Sciences\nLuddy School of Informatics, Computing, and Engineering',
          ),
          AcknowledgmentItem(
            title: 'Privacy and Disclosures',
          ),
          AcknowledgmentItem(
            title: 'Rosvall Lab',
          ),
          AcknowledgmentItem(
            title: 'Land Acknowledgement',
            description:
            'Indigenous Name: “We wish to acknowledge and honor the Indigenous communities native to this region, and recognize that Indiana University Bloomington is built on Indigenous homelands and resources. We recognize the myaamiaki, Lënape, Bodwéwadmik, and saawanwa people as past, present, and future caretakers of this land.”\nAnglicized Form: “We wish to acknowledge and honor the Indigenous communities native to this region, and recognize that Indiana University Bloomington is built on Indigenous homelands and resources. We recognize the Miami, Delaware, Potawatomi, and Shawnee people as past, present, and future caretakers of this land.”',
          ),
          AcknowledgmentItem(
            title: 'Other thank yous',
            description:
            'We thank Catherine... for insightful...'
          ),


          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image(image: AssetImage('lib/sources/insgclogo.png'), height: 65),
                Image(image: AssetImage('lib/sources/nsflogo.png'), height: 80),
                Image(image: AssetImage('lib/sources/luddylogo.png'), height: 65),
                Image(image: AssetImage('lib/sources/iulogo.jpg'), height: 65),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AcknowledgmentItem extends StatelessWidget {
  final String title;
  final String? description;

  const AcknowledgmentItem({
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description != null) ...[
            SizedBox(height: 8),
            Text(description!),
          ],
        ],
      ),
    );
  }
}