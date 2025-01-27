import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FileUploadButton extends StatefulWidget {
  @override
  _FileUploadButtonState createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  bool _isProcessing = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  Future<void> _showFilePickerDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please select a PDF or Excel file to upload'),
              SizedBox(height: 16),
              if (_selectedFileName != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Selected: $_selectedFileName',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFileName = null;
                            _selectedFile = null;
                          });
                          Navigator.pop(context);
                          _showFilePickerDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'xlsx', 'xls'],
                  );

                  if (result != null) {
                    setState(() {
                      _selectedFileName = result.files.single.name;
                      _selectedFile = result.files.single;
                    });
                    Navigator.pop(context);
                    _showFilePickerDialog();
                  }
                },
                icon: Icon(Icons.file_upload),
                label: Text('Choose File'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Upload'),
              onPressed: _selectedFile == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _uploadFile();
                    },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create form data
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          _selectedFile!.path!,
          filename: _selectedFile!.name,
        ),
      });

      // Make API call
      final response = await Dio().post(
        dotenv.env['UPLOAD_API_URL']!,
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _selectedFileName = null;
        _selectedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _showFilePickerDialog,
      icon: _isProcessing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(Icons.upload_file),
      label: Text(_isProcessing ? 'Processing...' : 'Upload File'),
    );
  }
}