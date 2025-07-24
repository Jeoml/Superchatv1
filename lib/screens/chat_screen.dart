import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:learnings1/blocs/voice_bloc/voice_bloc.dart';
import 'package:learnings1/screens/lottieanimation.dart';
import 'package:learnings1/screens/supportpage.dart';
import 'package:learnings1/services/shaderanimation.dart';
import 'package:learnings1/widgets/chat_slider.dart';
import 'package:learnings1/widgets/curved_design.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/user_message.dart';
import '../models/bot_message.dart';
import '../services/token_service.dart';
import 'package:learnings1/widgets/voice_chat/voice_index.dart';

// --------- Added imports for clipboard and Markdown building --------- //
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;

// A custom builder to handle code blocks with a copy button
class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBlockBuilder(this.context);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final codeText = element.textContent;

    // Basic syntax highlighting using regex
    final regex = RegExp(
      r'(\b(class|final|var|int|double|String|bool|const|extends|implements|return|if|else|for|while|switch|case|break|continue|new|void)\b)|' // Keywords
      // r'(".*?"|\'.*?\')|' // Strings
      r'(/\*[\s\S]*?\*/|//.*?$)|' // Comments
      r'(\b\d+\b)|' // Numbers
      r'([{}();,<>.\[\]])', // Operators and punctuation
      multiLine: true,
      caseSensitive: false,
    );

    List<TextSpan> spans = [];
    int start = 0;

    for (final match in regex.allMatches(codeText)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: codeText.substring(start, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }

      String? style;
      if (match.group(1) != null) {
        style = 'keyword';
      } else if (match.group(3) != null) {
        style = 'string';
      } else if (match.group(4) != null) {
        style = 'comment';
      } else if (match.group(5) != null) {
        style = 'number';
      } else if (match.group(6) != null) {
        style = 'operator';
      }

      TextStyle textStyle;
      switch (style) {
        case 'keyword':
          textStyle = const TextStyle(color: Colors.blue);
          break;
        case 'string':
          textStyle = const TextStyle(color: Colors.green);
          break;
        case 'comment':
          textStyle = const TextStyle(color: Colors.grey);
          break;
        case 'number':
          textStyle = const TextStyle(color: Colors.orange);
          break;
        case 'operator':
          textStyle = const TextStyle(color: Colors.purple);
          break;
        default:
          textStyle = const TextStyle(color: Colors.white);
      }

      spans.add(TextSpan(
        text: match.group(0),
        style: textStyle,
      ));

      start = match.end;
    }

    if (start < codeText.length) {
      spans.add(TextSpan(
        text: codeText.substring(start),
        style: const TextStyle(color: Colors.white),
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText.rich(
                  TextSpan(children: spans),
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 14.0,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                  tooltip: 'Copy code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: codeText));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard!')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          imagePath: 'assets/user.png',
        ));
      } else {
        messages.add(BotMessage(
          text: message['text']!,
          timestamp: DateTime.now(),
          imagePath: 'assets/logo.png',
        ));
      }
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _uploadPDFFile() async {
    if (_selectedFile == null) return;

    final apiUrl =
        Uri.parse(dotenv.env['UPLOAD_API_URL']!);

    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset('assets/lottie/fileloading.json'),
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

      var uri =
          Uri.parse(dotenv.env['UPLOAD_API_URL']!);
      var request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        if (mounted) Navigator.of(context).pop();
        _handleAuthError();
        return;
      }
      request.fields['question'] = _controller.text.trim(); // Add question field
      request.files.add(
        http.MultipartFile(
          'file', // Use 'file' as the field name
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
            'text':
                "file successfully uploaded in ${jsonDecode(responseStr)['time'].toStringAsFixed(2)} seconds",
            'sender': 'bot',
          });
        });
        _controller.clear();
      } else {
        setState(() {
          _addMessage({
            'text':
                'Upload failed: ${response.statusCode}\nDetails: $responseStr',
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
        _addMessage({'text': 'Error selecting file', 'sender': 'bot'});
      });
    }
  }

  void _sendMessage() async {
  final userText = _controller.text.trim();
  if (userText.isNotEmpty) {
    print('=== DEBUG: _sendMessage START ===');
    print('Debug: User text: "$userText"');
    print('Debug: Current endpoint: "$currentEndpoint"');
    
    // 1. Add the user's message
    final userMessage = UserMessage(
      text: userText,
      timestamp: DateTime.now(),
      imagePath: 'assets/user.png',
    );
    setState(() {
      messages.add(userMessage);
    });
    
    // Clear the input field
    _controller.clear();
    
    // Scroll to bottom after adding user message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // 2. Add a temporary "bot is typing..." message
    final BotMessage typingIndicator = BotMessage(
      text: "Bot is typing...",
      timestamp: DateTime.now(),
      imagePath: 'assets/logo.png',
    );
    setState(() {
      messages.add(typingIndicator);
    });

    // Scroll to bottom after adding typing indicator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      // 3. Call your chatHandler for the real response
      print('Debug: About to call chatHandler...');
      final responseText = await chatHandler(userText, currentEndpoint);
      print('Debug: chatHandler returned: "$responseText"');

      // 4. Check if widget is still mounted before calling setState
      if (mounted) {
        print('Debug: Widget is mounted, updating UI...');
        setState(() {
          // Remove the typing indicator
          messages.removeWhere((msg) => msg == typingIndicator);
          
          // Add the real bot reply
          final botMessage = BotMessage(
            text: responseText,
            timestamp: DateTime.now(),
            imagePath: 'assets/logo.png',
          );
          messages.add(botMessage);
        });
        print('Debug: UI updated successfully');

        // Scroll to bottom after adding bot response
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        print('Debug: Widget is not mounted, skipping UI update');
      }
      
      print('=== DEBUG: _sendMessage END SUCCESS ===');
    } catch (e, stackTrace) {
      print('=== DEBUG: _sendMessage ERROR ===');
      print('Debug: Error type: ${e.runtimeType}');
      print('Debug: Error message: $e');
      print('Debug: StackTrace: $stackTrace');
      print('Debug: Request body - token: $token');
      
      // Handle error - remove typing indicator and show error message
      if (mounted) {
        setState(() {
          messages.removeWhere((msg) => msg == typingIndicator);
          
          final errorMessage = BotMessage(
            text: "Error: $e\n\nPlease check the console for more details and try again.",
            timestamp: DateTime.now(),
            imagePath: 'assets/logo.png',
          );
          messages.add(errorMessage);
        });

        // Scroll to bottom after adding error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
      print('=== DEBUG: _sendMessage END ERROR ===');
    }
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
  // --------------- Modified this method to handle code blocks --------------- //
  // Updated _buildMessage to accept BuildContext
  Widget _buildMessage(BuildContext ctx, dynamic message) {
    if (message is UserMessage) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 90),
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(0),
              ),
              // border: Border.all(color: Colors.black),
            ),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14, color: Colors.white),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              builders: {
                // For triple-backtick blocks
                'pre': CodeBlockBuilder(ctx),
              },
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
              color: Colors.green[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: const Radius.circular(0),
                bottomRight: const Radius.circular(15),
              ),
              // border: Border.all(color: Colors.black),
            ),
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14, color: Colors.black),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              builders: {
                // For triple-backtick blocks
                'pre': CodeBlockBuilder(ctx),
              },
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ------------------------------------------------------------------------ //

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SupportPage())),
            icon: const Icon(Icons.dehaze_rounded),
          ),
          title: const Text('Superchat LLC',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'clear_chat') {
                  final token = await requestToken();
                  if (token == null) {
                    _handleAuthError();
                    return;
                  }
                  final clearChatApiUrl = dotenv.env['CLEAR_CHAT_API_URL'];
                  if (clearChatApiUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CLEAR_CHAT_API_URL is not set in the environment variables.')),
                    );
                    return;
                  }
                  try {
                    final response = await http.delete(
                      Uri.parse(clearChatApiUrl),
                      headers: {
                        'Authorization': 'Bearer $token',
                      },
                    );

                    if (response.statusCode == 200) {
                      final responseBody = jsonDecode(response.body);
                      final message = responseBody['message'] ??
                          'Chat history cleared successfully.';
                      messages.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      setState(() {
                        messages.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to clear chat history. Status: ${response.statusCode}')),
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
                // Pass BuildContext from itemBuilder
                itemBuilder: (context, index) {
                  return _buildMessage(context, messages[index]);
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                    ],
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: Colors.black,
                        size: 24.0,
                      ),
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
