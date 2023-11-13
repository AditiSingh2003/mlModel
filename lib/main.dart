import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

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
  late List _output;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', // Replace with your model file
        labels: 'assets/labels.txt', // Replace with your labels file
      );
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future imageClassification(File? image) async {
    if (image == null) {
      // Handle the case when no image is selected
      setState(() {
        _output = [];
        _loading = false;
      });
      return;
    }

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _output = recognitions!;
        _loading = true;
      });
      print(recognitions);
    } catch (e) {
      print("Error running model: $e");
    }
  }

  Future _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await imageClassification(_image);
    }
  }

  Future _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await imageClassification(_image);
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classification Example'),
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
            _loading
                ? Column(
                    children: <Widget>[
                      Text('Result:'),
                      for (var output in _output)
                        Text('${output['label']} ${(output['confidence'] * 100).toStringAsFixed(2)}%'),
                    ],
                  )
                : Text('Press buttons to classify an image.'),
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
