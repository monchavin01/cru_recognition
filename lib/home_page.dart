import 'dart:io';

import 'package:cru_recognition/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import 'models/data.dart';

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
  List _outputs;
  String _result;
  String index;
  String indexTrim;

  DataModel getDatamodel() {
    return dataModel;
  }

  @override
  void initState() {
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  Future pickImage(FileType fileType) async {
    if (fileType == FileType.Camera) {
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
      if (pickedFile == null) return null;
      setState(() {
        try {
          _loading = true;
          _image = File(pickedFile.path);
        } catch (e) {
          print(e);
        }
      });
    } else if (fileType == FileType.Gallery) {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return null;
      setState(() {
        try {
          _loading = true;
          _image = File(pickedFile.path);
        } catch (e) {
          print(e);
        }
      });
      // if (image == null) return null;
      // setState(() {
      //   try {
      //     _loading = true;
      //     _image = File(image.path);
      //   } catch (e) {
      //     print(e);
      //   }
      // });
    }
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      try {
        _loading = false;
        _outputs = output;
        _result = _outputs[0]["label"].toString();
        print(_outputs[0]["confidence"]);
        index = _result.substring(0, 2);
        indexTrim = index.trim();
        print(indexTrim);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Stack(children: [
          Positioned(top: 0, child: _buildPhotoTop()),
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
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
                ),
                height: Get.height * 0.6,
                width: Get.width,
                child: _buildContext()),
          ),
          Positioned(
            right: 20.0,
            top: 80.0,
            child: FloatingActionButton(
              backgroundColor: Color(0xFFFFBB24),
              onPressed: () {
                _showPicker(context);
              },
              tooltip: 'add photo',
              child: Icon(Icons.add_a_photo),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 300),
          child: _buildLayoutShowImage(),
        ),
      ]),
    );
  }

  Widget _buildLayoutShowImage() {
    return Container(
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _image,
                fit: BoxFit.fill,
              ),
            )
          : Image.asset("assets/logo.png"),
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 2,
            color: Color(0xFF303030).withOpacity(0.25),
          )
        ],
      ),
      height: Get.height * 0.2,
      width: Get.width * 0.3,
    );
  }

  Widget _buildContext() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: SingleChildScrollView(
          child: _outputs != null
              ? _outputs[0]["confidence"] > 0.90
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: Get.width * 0.5,
                              child: Text(
                                mockData[int.tryParse(indexTrim)]["title"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 72,
                        ),
                        Text(mockData[int.tryParse(indexTrim)]["description"]),
                        SizedBox(height: 16),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                                mockData[int.tryParse(indexTrim)]["map"]))
                      ],
                    )
                  : Container(
                      child: Padding(
                        padding: EdgeInsets.only(top: 180.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "ไม่สามารถระบุได้",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                    )
              : Container()),
    );
  }

  Widget _buildPhotoTop() {
    return Container(
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
          : Container(
              height: Get.width,
              width: Get.width,
              child: Image.file(
                _image,
                fit: BoxFit.fill,
              ),
            ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Photo Library'),
                    onTap: () {
                      pickImage(FileType.Gallery);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                    onTap: () {
                      pickImage(FileType.Camera);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

enum FileType {
  Gallery,
  Camera,
  Video,
}
