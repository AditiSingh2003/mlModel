import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;

  Future _getImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  setState(() {
    _image = pickedFile != null ? File(pickedFile.path) : null;
  });
}

Future _getImageFromCamera() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

  setState(() {
    _image = pickedFile != null ? File(pickedFile.path) : null;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(
                    _image!,
                    height: 200,
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  child: Text('Pick Image from Gallery'),
                ),
                ElevatedButton(
                  onPressed: _getImageFromCamera,
                  child: Text('Take Picture'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
