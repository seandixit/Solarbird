import 'dart:ui';

import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget{
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SolarBird Privacy Notice"),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0), // Add some spacing between the title and location message
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2), // Add padding to both left and right
                child: Align(
                  alignment: Alignment.centerRight, // Align to the left
                  child: Text(
                    "Effective: 2024-01-01",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Overview",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "At Indiana University (IU), we are committed to protecting the privacy and confidentiality of personal information entrusted to us. By accessing and using IU's services, you acknowledge and consent to the practices described in our global privacy statement here: https://privacy.iu.edu/privacy/global.html. For additional information outlining how IU collects, uses, and safeguards personal information obtained specifically through our app, please also review the information below. Continued use of our app indicates consent to the collection, use, and disclosure of this information as described in this notice. Visitors to other IU apps or websites should review the privacy notices for the sites they visit, as other units at the university may collect and use visitor information in different ways. IU is not responsible for the content of other apps or websites or for the privacy practices of apps or websites outside the scope of this notice.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Changes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "Because Internet technologies continue to evolve rapidly, IU may make appropriate changes to this notice in the future. Any such changes will be consistent with our commitment to respecting visitor privacy, and will be clearly posted in a revised privacy notice.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Collection and Use",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "Passive/Automatic Collection:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "In addition to any information outline in the global statement, our server and/or app collects the following: Your IP address, the date and time of visit, and GPS coordinates",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "This technical information is retained in detail for up to 3650 days. Some technical information is retained in aggregate for up to 3650 days.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Active/Manual/Voluntary Collection:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "In addition to the technical information about your visit described above (or cookies, described below), we may ask you to provide information voluntarily, such as through forms or other manual input. We might ask for you to provide this information in order to make products and services available to you, to maintain and manage our relationship with you, including providing associated services or to better understand and serve your needs. This information is generally retained as long as you continue to maintain a relationship with us. Your providing this information is wholly voluntary. However, not providing the requested information (or subsequently asking that the data be removed) may affect our ability to deliver the products or service for which the information is needed. Providing the requested information indicates your consent to the collection, use, and disclosure of this information as described in this notice. Information we may actively collect could include: the email addresses of those who communicate with us via email, name, information volunteered by the visitor, such as preferences, survey information and/or app registrations, and observed bird behavior.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Information Used For Contact:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "If you supply us with your email address, you will only receive the information for which you provided us your address.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Information Sharing:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "We may share aggregate, non-personally identifiable information with other entities or organizations. Except as described in the IU Privacy statement, we will not share any information with any other entities or organizations for any reason. Except as provided in the Disclosure of Information section below, we do not attempt to use the technical information discussed in this section to identify individual visitors.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Cookies:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "For more information on how we use cookies, please review the IU Privacy statement. Our app does not use cookies to store information about your actions or choices on pages associated with our site.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Children:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "This app is not directed to children under 13 years of age, does not sell products or services intended for purchase by children, and does not knowingly collect or store any personal information, even in aggregate, about children under the age of 13. We encourage parents and teachers to be involved in children's Internet explorations. It is particularly important for parents to guide their children when they are asked to provide personal information online.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Use of Third Party Services:",
            style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic,),
          ),
          Text(
            "Our app does not utilize web analytics services beyond what is noted in the IU Privacy statement.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Security",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "Due to the rapidly evolving nature of information technologies, no transmission of information over the Internet can be guaranteed to be completely secure. While Indiana University is committed to protecting user privacy, IU cannot guarantee the security of any information users transmit to university sites, and users do so at their own risk.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "We have appropriate security measures in place in our physical facilities to protect against the loss, misuse, or alteration of information that we have collected from you on our app.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "Once we receive user information, we will use reasonable safeguards consistent with prevailing industry standards and commensurate with the sensitivity of the data being stored to maintain the security of that information on our systems.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "We will comply with all applicable federal, state and local laws regarding the privacy and security of user information.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Links to non-university apps or sites",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "Indiana University is not responsible for the availability, content, or privacy practices of non-university apps or sites. Non-university apps or sites are not bound by this privacy notice policy and may or may not have their own privacy policies.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Privacy Notice Changes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "From time to time, we may use visitor information for new, unanticipated uses not previously disclosed in our privacy notice. We will post the policy changes to our app to notify you of these changes and provide you with the ability to opt out of these new uses. If you are concerned about how your information is used, you should check back at our app periodically. Visitors may prevent their information from being used for purposes other than those for which it was originally collected by sending us an email at the listed address.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Supplemental Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "Email addresses are not required information; by supplying your email address, you opt into receiving occasional emails that disseminate the results of this research study. They are securely stored and will never be shared with third parties or used for any other purposes beyond disseminating the research results. Names are not required information; by supplying your name and providing valid bird behavior observations, you opt in to be acknowledged in a forthcoming scientific publication. They are securely stored and will never be shared with third parties or used for any other purposes beyond acknowledgement of your contributions. IP addresses are securely stored for internal use in data validation and quality control; they are not shared publicly in any form, including in scientific datasets or publications. GPS coordinates and observation times are securely stored for internal use in scientific data analysis (including but not limited to correlating observations with eclipse phase, temperature, cloud coverage, barometric pressure, and other non-identifying variables of scientific interest). GPS coordinates will never be shared with third parties or used for other purposes. Bird observations are not personally identifying, and will be shared as open data and in scientific publications.",
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Contact Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            "If you have questions or concerns about this policy, please contact us. \n\n  Indiana University\n  ATTN: Liz Aguilar\n  107 S Indiana Ave\n  Bloomington, IN\n  47405\n  scihouse@indiana.edu\n\nIf you feel as though this app’s privacy practices differ from the information stated, you may contact us at the listed email address.",
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            "If you feel that this app is not following its stated policy and communicating with the owner of this app does not resolve the matter, or if you have general questions or concerns about privacy or information technology policy at Indiana University, please contact the chief privacy officer through the University Information Policy Office, 812-855-UIPO, privacy@iu.edu.",
            style: TextStyle(fontSize: 16.0),
          )

          // Include the rest of the privacy notice here...
        ],
      ),
    );
  }
}