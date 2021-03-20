import 'dart:io';

import 'package:cru_recognition/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_modern/image_picker_modern.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DataModel dataModel;
  bool _loading;
  File _image;
  final picker = ImagePicker();

  DataModel getDatamodel() {
    return dataModel;
  }

  Future pickImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      try {
        _loading = true;
        _image = File(image.path);
      } catch (e) {
        print(e);
      }
    });
    // classifyImage(_image);
  }

  //   enum FileType {
  //   Gallery,
  //   Camera,
  //   Video,
  // }
  // final imagePicker = ImagePicker();
  //   PickedFile pickedFile;
  //   if (fileType == FileType.Camera) {
  //     // Camera Part
  //     pickedFile = await imagePicker.getImage(
  //       source: ImageSource.camera,
  //       maxWidth: 480,
  //       maxHeight: 640,
  //       imageQuality: 25, // pick your desired quality
  //     );
  //     setState(() {
  //       if (pickedFile != null) {
  //         _storedFile = File(pickedFile.path);
  //       } else {
  //         print('No image selected.');
  //         return;
  //       }
  //     });
  //   } else if (fileType == FileType.Gallery) {
  //     // Gallery Part
  //     pickedFile = await imagePicker.getImage(
  //       source: ImageSource.gallery,
  //       maxWidth: 480,
  //       maxHeight: 640,
  //       imageQuality: 25,
  //     );
  //       } else {
  //         print('No image selected.');
  //         return;
  //       }
  //     });
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned(
          top: 0,
          child: Container(
            child: _image == null
                ? Container(
                    height: Get.width,
                    width: Get.width,
                    child: Center(
                        child: Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 20.0),
                    )),
                  )
                : Image.file(
                    _image,
                    width: Get.width,
                    height: Get.width,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  color: Color(0xFF303030).withOpacity(0.25),
                )
              ],
              color: Color(0xFFFFBB24),
              borderRadius: BorderRadius.circular(32),
            ),
            height: Get.height * 0.6,
            width: Get.width,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // dataModel.title,
                      'title',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text('location :'),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text('contact :'),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text('major :'),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text('description :'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          child: Container(height: 64, width: 32, color: Colors.red),
        ),
        Positioned(
          right: 20.0,
          top: 80.0,
          child: FloatingActionButton(
            backgroundColor: Color(0xFFFFBB24),
            onPressed: () {
              pickImage();
            },
            tooltip: 'add photo',
            child: Icon(Icons.add_a_photo),
          ),
        ),
      ]),
    );
  }
}
