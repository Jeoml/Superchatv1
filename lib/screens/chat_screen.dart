import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:learnings1/widgets/chat_slider.dart';
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

  Future<void> _uploadPDFFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
      return;
    }
    Uri apiUrl = Uri.parse('http://suitable-jolly-falcon.ngrok-free.app/upload');
    try {
      _controller.text = 'Please Wait';
      String? token = await requestToken();
      var request = http.MultipartRequest('POST', apiUrl);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        _selectedFile!.files.single.path!,
        contentType: MediaType('application', _selectedFile!.files.single.extension == 'csv' ? 'csv' : 'pdf'),
      ));
      request.headers['Content-Type'] = "multipart/form-data";
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully')),
        );
        _controller.clear();
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        setState(() {
          _addMessage({'text': jsonResponse.toString(), 'sender': 'bot'});
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed')),
        );
      }
    } catch (e) {
      setState(() {
        _addMessage({
          'text':
              'Hmmm ... it seems like you were logged out for quite a while. Please login again to access this service.',
          'sender': 'bot'
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login again to access this service')),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'wav'],
    );
    if (result != null && result.files.isNotEmpty) {
      _selectedFile = result;
    } else {
      print('No file selected');
    }
    setState(() {});
  }

  void _showPDFUploadDialog() {
    if (_isCanceled) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickFile();
                  setState(() {});
                },
                child: Text('Pick PDF'),
                style: TextButton.styleFrom(
                  foregroundColor: Color(Colors.blue.value),
                ),
              ),
              if (_selectedFile != null)
                Text(path.basename(_selectedFile!.files.single.path!)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _uploadPDFFile();
                  Navigator.of(context).pop();
                },
                child: Text('Confirm'),
                style: TextButton.styleFrom(
                  foregroundColor: Color(Colors.blue.value),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Color(Colors.blue.value),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Send'),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFEC5B68),
              ),
            ),
          ],
        );
      },
    );
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
          padding: const EdgeInsets.only(right: 12.0, left: 12),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message.text, style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    } else if (message is BotMessage) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message.text, style: TextStyle(color: Colors.black)),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () 
        {
          
        }, icon: Icon(Icons.dehaze_rounded)),
        title: const Text('Superchat LLC'),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
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
                        icon: Icon(
                          Icons.send_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 24.0,
                        ),
                        splashRadius: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 24.0,
                          ),
                          splashRadius: 20.0,
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
    );
  }
}
