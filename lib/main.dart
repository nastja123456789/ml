import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import '../constants.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MachineLearningApp(),
  ),
);

class MachineLearningApp extends StatefulWidget {
  const MachineLearningApp({Key key}) : super(key: key);

  @override
  _MachineLearningAppState createState() => _MachineLearningAppState();
}

class _MachineLearningAppState extends State {

  File _image;
  List _result;

  @override
  void initState() {
    super.initState();
    loadModel().then((ouput) {
      setState(() {});
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _image != null ? testImage(size, _image) : titleContent(size),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              galleryOrCamera(Icons.camera, ImageSource.camera),
              galleryOrCamera(Icons.photo_album, ImageSource.gallery),
            ]),
            SizedBox(height: 50),

            _result != null
                ? Text(
              "${_result[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container(child: Text("пустое место")),

            SizedBox(height: 45),
            Text(
              'androidride.com',
              style: TextStyle(
                fontWeight: bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  detectDogOrCat(File image) async {
      var result = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _result = result;
      });
  }

  _getImage(ImageSource imageSource) async {
//accessing image from Gallery or Camera.
    var image = await ImagePicker.pickImage(source: imageSource);
//image is null, then return
    if (image == null) return;

    setState(() {
      _image = File(image.path);

    });
    detectDogOrCat(image);
  }

  Widget testImage(size, image) {
    return Container(
      height: size.height * 0.55,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(
            image,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  MaterialButton galleryOrCamera(IconData icon, ImageSource imageSource) {
    return MaterialButton(
      padding: EdgeInsets.all(14.0),
      elevation: 5,
      color: Colors.grey[300],
      onPressed: () {
        _getImage(imageSource);
      },
      child: Icon(
        icon,
        size: 20,
        color: Colors.grey[800],
      ),
      shape: CircleBorder(),
    );
  }
}

Container titleContent(Size size) {
  return Container(
//contains 55% of the screen height.
    height: size.height * 0.55,
    width: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/pets.jpg"),
        fit: BoxFit.cover,
//black overlay filter
        colorFilter: filter,
      ),
    ),
    child: Center(
      child: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          Text(
            'Dogs Vs Cats',
            style: GoogleFonts.roboto(
              fontSize: 40,
              color: Colors.white,
              fontWeight: bold,
            ),
          ),
          Text(
            'Flutter Machine Learning App',
            style: GoogleFonts.openSansCondensed(
              fontWeight: bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
