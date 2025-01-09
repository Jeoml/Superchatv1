import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:learnings1/blocs/voice_bloc/voice_bloc.dart';
import 'package:learnings1/screens/lottieanimation.dart';
import 'package:learnings1/screens/supportpage.dart';
import 'package:learnings1/widgets/chat_slider.dart';
import 'package:learnings1/widgets/curved_design.dart';
import 'package:lottie/lottie.dart';
// import 'package:typeset/typeset.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
// import 'package:learnings1/widgets/document/file_picker.dart';
// import 'package:learnings1/widgets/pdf_upload_icon.dart';
import '../models/user_message.dart';
import '../models/bot_message.dart';
import '../services/token_service.dart';
import 'package:learnings1/widgets/voice_chat/voice_index.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
  }
  final TextEditingController _controller = TextEditingController();
  final List<dynamic> messages = [];
  final ScrollController _scrollcontroller = ScrollController();
  String currentEndpoint = 'chat';
  FilePickerResult? _selectedFile;
  bool _isCanceled = false;
  String? receivedToken; // Make sure to initialize this with your actual token

  void _addMessage(Map<String, String> message) {
    setState(() {
      if (message['sender'] == 'user') {
        messages.add(UserMessage(
          text: message['text']!,
          timestamp: DateTime.now(),
        ));
      } else {
        messages.add(BotMessage(
          text: message['text']!,
          timestamp: DateTime.now(),
        ));
      }
    });
    Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
  }

//   Future<void> _uploadPDFFile() async {
//   if (_selectedFile == null) {
//     setState(() {
//       _addMessage({
//         'text': 'No file selected',
//         'sender': 'bot'
//       });
//     });
//     return;
//   }

//   final apiUrl = Uri.parse('https://suitable-jolly-falcon.ngrok-free.app/upload');
  
//   try {
//     setState(() => _controller.text = 'Please Wait');
    
//     final token = await requestToken();
//     if (token == null) {
//       _handleAuthError();
//       return;
//     }

//     final file = _selectedFile!.files.single;
//     final request = http.MultipartRequest('POST', apiUrl);
    
//     request.headers['Authorization'] = 'Bearer $token';
    
//     final multipartFile = http.MultipartFile.fromBytes(
//       'files',
//       await file.bytes!,
//       filename: file.name,
//       contentType: MediaType('application', file.extension?.toLowerCase() ?? 'pdf'),
//     );

//     request.files.add(multipartFile);

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (!mounted) return;

//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       setState(() {
//         _addMessage({
//           'text': 'File uploaded successfully',
//           'sender': 'bot'
//         });
//       });
//       _controller.clear();
//     } else {
//       print('Upload failed with status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       setState(() {
//         _addMessage({
//           'text': 'Upload failed: ${response.statusCode}',
//           'sender': 'bot'
//         });
//       });
//     }
//   } catch (e) {
//     print('Upload error: $e');
//     if (!mounted) return;
//     _handleUploadError(e);
//   }
// }

Future<void> _uploadPDFFile() async {
  if (_selectedFile == null) return;

  final apiUrl = Uri.parse('https://suitable-jolly-falcon.ngrok-free.app/upload');
  
  try {
    // Show loading indicator
    if (!mounted) return;
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return const Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
      return Center(
        child: SizedBox(
        width: 250,
        height: 250,
        child: Image.asset('assets/lottie/blocks.gif'),
        ),
      );
      },
    );
    
    final token = await requestToken();
    if (token == null) {
      // Hide loading indicator before showing error
      if (mounted) Navigator.of(context).pop();
      _handleAuthError();
      return;
    }

    final file = _selectedFile!.files.single;
    final bytes = await file.bytes;
    if (bytes == null) {
      // Hide loading indicator if no bytes found
      if (mounted) Navigator.of(context).pop();
      print('No bytes found in file');
      return;
    }

    var uri = Uri.parse('https://suitable-jolly-falcon.ngrok-free.app/upload');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile(
        'files',
        Stream.value(bytes),
        bytes.length,
        filename: file.name,
      ),
    );

    final response = await request.send();
    final responseStr = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseStr');

    // Hide loading indicator after getting response
    if (mounted) Navigator.of(context).pop();

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        _addMessage({
          'text': "file successfully uploaded in ${jsonDecode(responseStr)['time'].toStringAsFixed(2)} seconds",
          'sender': 'bot'
        });
      });
      _controller.clear();
    } else {
      setState(() {
        _addMessage({
          'text': 'Upload failed: ${response.statusCode}\nDetails: $responseStr',
          'sender': 'bot'
        });
      });
    }
  } catch (e) {
    if (mounted) Navigator.of(context).pop();
    
    print('Upload error: $e');
    if (!mounted) return;
    _handleUploadError(e);
  }
}

void _handleUploadError(dynamic error) {
  print('Error details: $error');
  setState(() {
    _addMessage({
      'text': 'An error occurred during upload. Please try again.',
      'sender': 'bot'
    });
  });
}

void _handleAuthError() {
  setState(() {
    _addMessage({
      'text': 'Session expired. Please log in again to continue.',
      'sender': 'bot'
    });
  });
}

Future<void> _pickFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'csv', 'wav'],
      withData: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result);
    }
  } catch (e) {
    print('File picking error: $e');
    setState(() {
      _addMessage({
        'text': 'Error selecting file',
        'sender': 'bot'
      });
    });
  }
}
  void _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isNotEmpty) {
      final userMessage =
          UserMessage(text: userText, timestamp: DateTime.now());
      setState(() {
        messages.add(userMessage);
      });
      Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
      _controller.clear();
      final responseText = await chatHandler(userText, currentEndpoint);
      final botMessage =
          BotMessage(text: responseText, timestamp: DateTime.now());
      setState(() {
        messages.add(botMessage);
      });
      Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollcontroller.hasClients) {
      _scrollcontroller.animateTo(
        _scrollcontroller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(dynamic message) {
    if (message is UserMessage) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 90),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            // child: Text(message.text, style: TextStyle(color: Colors.white)),
            child: MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
            p: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          ),
        ),
      );
    } else if (message is BotMessage) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 70),
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            // child: Text(message.text, style: TextStyle(color: Colors.black)),
          child: MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
            p: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SupportPage())),
            icon: Icon(Icons.dehaze_rounded),
          ),
          title: const Text('Superchat LLC', style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          elevation: 0, // Add this line to remove the shadow
            actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
              if (value == 'clear_chat') {
                final token = await requestToken();
                if (token == null) {
                _handleAuthError();
                return;
                }
                try {
                final response = await http.delete(
                  Uri.parse('https://suitable-jolly-falcon.ngrok-free.app/clear_chat'),
                  headers: {
                  'Authorization': 'Bearer $token',
                  },
                );

                if (response.statusCode == 200) {
                  final responseBody = jsonDecode(response.body);
                  final message = responseBody['message'] ?? 'Chat history cleared successfully.';
                  messages.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                  );
                  setState(() {
                  messages.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to clear chat history. Status: ${response.statusCode}')),
                  );
                }
                } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('An error occurred: $e')),
                );
                }
              }
              },
              itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                value: 'clear_chat',
                child: Text('Clear Chat'),
                ),
              ];
              },
            ),
            ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollcontroller,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(messages[index]);
                },
              ),
            ),
            Column(
              children: [
                SlidingSegmentControl(
                  onEndpointChanged: (String newEndpoint) {
                    setState(() {
                      currentEndpoint = newEndpoint;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.2),
                      //     spreadRadius: 1,
                      //     blurRadius: 5,
                      //     offset: Offset(0, 2),
                      //   ),
                      // ],
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 16.0,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 12.0,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          // splashRadius: 20.0,
                        ),
                        // IconButton(
                        //   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LottieAnimation())),
                        //   icon: const Icon(
                        //     Icons.waves,
                        //     color: Colors.black,
                        //     size: 24.0,
                        //   ),
                        //   // splashRadius: 20.0,
                        // ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.attach_file_rounded,
                              color: Colors.black,
                              size: 24.0,
                            ),
                            // splashRadius: 20.0,
                            onPressed: () async {
                              await _pickFile();
                              await _uploadPDFFile();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}