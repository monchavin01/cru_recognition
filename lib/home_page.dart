import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
        index = _result.substring(0, 2);
        indexTrim = index.trim();
        titleFormat();
      } catch (e) {
        print(e);
      }
    });
  }

  String titleFormat() {
    List<String> value = _outputs[0]["label"].toString().split(" ");
    return value[1].replaceAll("-", " ");
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
            right: Get.width / 15,
            top: Get.width / 6,
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
        Positioned(
          left: Get.width / 13,
          top: Get.width / 1.5,
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
              ? _outputs[0]["confidence"] > 0.6
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Get.height * 0.05,
                        ),
                        Text(
                          'คำอธิบาย',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(mockData[int.tryParse(indexTrim)]["description"]),
                        // Text(mockData[int.tryParse(indexTrim)]["floor"]),
                        SizedBox(height: 16),
                        Column(
                          children: [
                            Text(
                              'รายการจองห้องเรียน',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            for (var i in mockData[int.tryParse(indexTrim)]
                                ["floor"])
                              _buildFloorReserve(i)
                          ],
                        ),
                        // _buildFloorReserve(mockData[int.tryParse(indexTrim)]["floor"]),
                        SizedBox(height: 16),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                                mockData[int.tryParse(indexTrim)]["map"])),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.only(top: 180.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "ไม่สามารถระบุสถานที่ได้ \n ลองเปลี่ยนมุมถ่ายดูนะ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      ],
                    )
              : Container()),
    );
  }

  Widget _buildFloorReserve(indexs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ชั้น $indexs',
          style: TextStyle(fontSize: 16),
        ),
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("reservation-classroom")
              .doc(titleFormat())
              .collection(indexs.toString())
              .orderBy("date", descending: false)
              .get(),
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? Center(child: CircularProgressIndicator())
                : snapshot.data.documents.length > 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        // controller: _controller, //new line
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return _buildScheduleList(context, index, snapshot);
                        },
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(' ไม่มีการจอง'),
                        alignment: Alignment.topLeft,
                      );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleList(
      BuildContext context, index, AsyncSnapshot snapshot) {
    DocumentSnapshot data = snapshot.data.docs[index];
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[500], spreadRadius: 0.2, blurRadius: 2),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ห้อง'),
                SizedBox(width: 16),
                Text(data.data()['roomNumber'])
              ],
            ),
            Row(
              children: [
                Text('วิชา'),
                SizedBox(width: 16),
                Text(data.data()['subject'])
              ],
            ),
            Row(
              children: [
                Text('วันที่'),
                SizedBox(width: 16),
                Text(data.data()['date'])
              ],
            ),
            Row(
              children: [
                Text('เวลา'),
                SizedBox(width: 16),
                Text(data.data()['timeFromSchedule']),
                SizedBox(width: 16),
                Text('ถึง'),
                SizedBox(width: 16),
                Text(data.data()['timeToSchedule'])
              ],
            ),
          ],
        ),
      ),
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
