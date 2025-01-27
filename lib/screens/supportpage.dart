import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learnings1/services/token_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

void _launchPhone(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

void _launchEmail(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ElevatedButton(
              //   onPressed: () async {
              //     try {
              //       final response = await http.delete(
              //         Uri.parse(
              //             'CLEAR_CHAT_API_URL'),
              //             headers: {
              //               'Authorization': 'Bearer $token',
              //             },
              //       );

              //       if (response.statusCode == 200) {
              //         final responseBody = jsonDecode(response.body);

              //         // Ensure the message key exists in the response
              //         final message = responseBody['message'] ??
              //             'Chat history cleared successfully.';
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(content: Text(message)),
              //         );
              //       } else {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //               content: Text(
              //                   'Failed to clear chat history. Status: ${response.statusCode}')),
              //         );
              //       }
              //     } catch (e) {
              //       // Handle any unexpected errors, such as network issues
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('An error occurred: $e')),
              //       );
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.teal,
              //     foregroundColor: Colors.white,
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //     textStyle: TextStyle(fontSize: 16),
              //   ),
              //   child: Text('Clear Chat History'),
              // ),

              const Text(
                'Contact Us',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.call, color: Colors.teal),
                title: const Text('Call Customer Support'),
                subtitle: const Text('+91 000 000 0000 (Mon-Fri, 9 AM - 6 PM)'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _launchPhone('tel:+910000000000');
                },
              ),
              // const Divider(),
              // ListTile(
              //   leading: const Icon(Icons.email, color: Colors.teal),
              //   title: const Text('Email Us'),
              //   subtitle: const Text('supportsuperchat@gmail.com'),
              //   trailing: const Icon(Icons.arrow_forward_ios),
              //   onTap: () {
              //       _launchEmail('mailto:supportsuperchat@gmail.com');
              //   },
              // ),
              const Divider(),
              const SizedBox(height: 30),
              const Text(
                'Frequently Asked Questions (FAQs)',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              _buildFAQTile(
                'What should I do if my payment was debited but the chatbot service is still not available?',
                'If your payment has been successfully processed and you are unable to access the chatbot service, please contact our support team immediately for assistance.',
              ),
              _buildFAQTile(
                'What should I do if the screen froze after making a payment?',
                'In case of a frozen screen, try refreshing the page or restarting the app. If the issue persists, contact customer support with your payment details.',
              ),
              _buildFAQTile(
                'For how long is the chatbot service available after payment?',
                'The chatbot service is available for one month from the date of payment. You can renew your subscription anytime.',
              ),
              _buildFAQTile(
                'Can I get a refund if I am not satisfied with the service?',
                'Refunds are subject to our refund policy. Please contact customer support to discuss your situation.',
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
