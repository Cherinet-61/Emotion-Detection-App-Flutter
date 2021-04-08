import 'package:emotion_detection_app_flutter/Firebase/authenticate.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

//Image uploading page
main() {
  runApp(UploadPicture());
}

class UploadPicture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UploadPicture();
  }
}

class _UploadPicture extends State<UploadPicture> {
  @override
  AuthService _firebaseAuth = AuthService();
  File placeholderPictureAddress;
  List<Rect> rectArr = new List();
  ui.Image image;
  String smileText = "";
  _uploadFromGallery() async {
    placeholderPictureAddress =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(placeholderPictureAddress);
    FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
    ));

    List<Face> listOfFaces =
        await faceDetector.processImage(firebaseVisionImage);
    for (Face face in listOfFaces) {
      rectArr.add(face.boundingBox);
      setState(() {
        if (face.smilingProbability > 0.86) {
          smileText = 'Big smile with teeth😁, no wonder you are having a good day';
        } else if (face.smilingProbability > 0.8) {
          smileText = 'Big Smile😃';
        } else if (face.smilingProbability > 0.3) {
          smileText = 'Smile😀';
        } else
          smileText = 'I see no smile. \nSomething wrong?😳';
      });
    }
    var bytesFromImageFile = placeholderPictureAddress.readAsBytesSync();
    decodeImageFromList(bytesFromImageFile).then((img) {
      setState(() {
        image = img;
      });
    });
  }

  _uploadFromCamera() async {
    placeholderPictureAddress =
        await ImagePicker.pickImage(source: ImageSource.camera);
    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(placeholderPictureAddress);
    FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
    ));
    List<Face> listOfFaces =
        await faceDetector.processImage(firebaseVisionImage);
    for (Face face in listOfFaces) {
      rectArr.add(face.boundingBox);
      setState(() {
        if (face.smilingProbability > 0.86) {
          smileText = 'Big smile with teeth😁';
        } else if (face.smilingProbability > 0.8) {
          smileText = 'Big Smile😃';
        } else if (face.smilingProbability > 0.3) {
          smileText = 'Smile😀';
        } else
          smileText = 'I see no smile😳';
      });
    }
    var bytesFromImageFile = placeholderPictureAddress.readAsBytesSync();
    decodeImageFromList(bytesFromImageFile).then((img) {
      setState(() {
        image = img;
      });
    });

    setState(() {});
  }

  Widget _checkIfPathIsEmpty() {
    if (placeholderPictureAddress == null) {
      this.setState(() {});
      return Text("Please select an image to continue");
    } else {
      this.setState(() {});
      return Image.file(placeholderPictureAddress);
    }
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          actions: <Widget>[
            FlatButton.icon(
              onPressed: () async {
                await _firebaseAuth.userSignOut();
              },
              icon: Icon(Icons.person, color: Colors.red),
              label: Text(
                "Sign Out",
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 400,
                  height: 300,
                  child: _checkIfPathIsEmpty(),
                  alignment: Alignment.center,
                ),
                Text(
                  smileText,
                  style: TextStyle(color: Colors.blue, fontSize: 30),
                ),
                FittedBox(
                  child: SizedBox(
                    height: image == null ? height : image.height.toDouble(),
                    width: image == null ? width : image.width.toDouble(),
                    child: CustomPaint(
                      painter: Painter(rectArr, image),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          side: BorderSide(color: Colors.grey)),
                      onPressed: () {
                        _uploadFromCamera();
                      },
                      color: Colors.blue[50],
                      textColor: Colors.white,
                      splashColor: Colors.teal[100],
                      child: Text("Camera",
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          side: BorderSide(color: Colors.grey)),
                      onPressed: () {
                        _uploadFromGallery();
                      },
                      color: Colors.blue[50],
                      splashColor: Colors.teal[100],
                      textColor: Colors.white,
                      child: Text("Gallery",
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {
  Painter(@required this.rect, @required this.image);

  final List<Rect> rect;
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    if (image != null) {
      canvas.drawImage(image, Offset.zero, paint);
    }
    for (var i = 0; i <= rect.length - 1; i++) {
      canvas.drawRect(rect[i], paint);
    }
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }
}
