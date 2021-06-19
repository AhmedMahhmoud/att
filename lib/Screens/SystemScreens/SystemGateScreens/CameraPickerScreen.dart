import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:image_face/image_face.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/database.dart';
import 'package:qr_users/MLmodule/services/camera.service.dart';
import 'package:qr_users/MLmodule/services/facenet.service.dart';

import 'package:qr_users/MLmodule/services/ml_kit_service.dart';
import 'package:qr_users/MLmodule/widgets/FacePainter.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/SytemScanner.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:tflite/tflite.dart';

class CameraPicker extends StatefulWidget {
  final CameraDescription camera;

  const CameraPicker({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<CameraPicker>
    with WidgetsBindingObserver {
  // service injection
  // MLKitService _mlKitService = MLKitService();
  // CameraService _cameraService = CameraService();
  // FaceNetService _faceNetService = FaceNetService();

  // File imagePath;
  // Face faceDetected;
  // Size imageSize;
  // final DataBaseService _dataBaseService = DataBaseService();
  // bool _detectingFaces = false;
  // bool pictureTaked = false;
  // String predictedUserName = "";
  // Future _initializeControllerFuture;
  // bool cameraInitializated = false;
  // Future signUp(context) async {
  //   /// gets predicted data from facenet service (user face detected)
  //   // List predictedData = _faceNetService.predictedData;
  //   // String user = "بشمهندس احمد فرحان";
  //   // String password = "*";

  //   // / creates a new user in the 'database'
  //   // await _dataBaseService
  //   //     .saveData(user, password, predictedData)
  //   //     .whenComplete(() => print("SAved to Database successfully"));

  //   // / resets the face stored in the face net sevice
  //   // this._faceNetService.setPredictedData(null);
  // }
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  File imagePath;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;
  int numberOfFacesDetected = -1;
  // switchs when the user press the camera
  // bool _saving = false;
  // Color cameraColor;
  // // CameraController _controller;
  List _result;
  // String confiedence = "";
  String name = "";
  // String numbers = "";
  // List<Face> faces = [];
  // // bool isLoading = false;
  // ui.Image _image;
  // int numberOfFacesDetected = -1;
  // FacePainterr facePainterr;
  // // CameraController _controller;
  // // Future<void> _initializeControllerFuture;
  // // File imagePath;
  // // List<Face> _faces;
  // // String name = "";

  String confiedence = "";
  // // bool isLoading = false;
  // // ui.Image _image;
  // // int numberOfFacesDetected = -1;
  @override
  void initState() {
    super.initState();
    // loadModel();
    // print(imagePath);
    // _start();
    numberOfFacesDetected = -1;
    image = null;
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    //

    // _initializeControllerFuture = _cameraService.cameraController.initialize();
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
  }

  File image;
  applyModelOnImage(File file) async {
    try {
      var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      _result = res;
      String str = _result[0]["label"];
      name = str.substring(2);
      confiedence = _result != null
          ? (_result[0]["confidence"] * 100.0).toString().substring(0, 2) + "%"
          : "";
    } catch (e) {
      print(e);
    }
  }

  // _start() async {
  //   _initializeControllerFuture = _cameraService.startService(widget.camera);
  //   await _initializeControllerFuture;
  //   if (mounted)
  //     setState(() {
  //       cameraInitializated = true;
  //     });

  //   _frameFaces();
  // }

  // _frameFaces() {
  //   imageSize = _cameraService.getImageSize();

  //   _cameraService.cameraController.startImageStream((image) async {
  //     if (_cameraService.cameraController != null) {
  //       // if its currently busy, avoids overprocessing
  //       if (_detectingFaces) return;

  //       _detectingFaces = true;

  //       try {
  //         faces = (await _mlKitService.getFacesFromImage(image));
  //         print("Got facess : ${faces.length}");
  //         if (faces.length > 0) {
  //           if (mounted)
  //             setState(() {
  //               faceDetected = faces[0];
  //             });

  //           if (_saving) {
  //             // _faceNetService.setCurrentPrediction(image, faceDetected);
  //             if (mounted)
  //               setState(() {
  //                 _saving = false;
  //               });
  //           }
  //         } else {
  //           if (mounted)
  //             setState(() {
  //               faceDetected = null;
  //             });
  //         }

  //         _detectingFaces = false;
  //       } catch (e) {
  //         print(e);
  //         _detectingFaces = false;
  //       }
  //     }
  //   });
  // }

  // _loadImage(File file) async {
  //   final data = await file.readAsBytes();
  //   await decodeImageFromList(data).then(
  //     (value) => setState(() {
  //       _image = value;
  //       // isLoading = false;
  //     }),
  //   );
  // }

  // File image;
  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    // _cameraService.cameraController.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return imagePath == null
                  ? CameraPreview(_controller)
                  : isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          backgroundColor: Colors.orange,
                        ))
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: FittedBox(
                              fit: BoxFit.fill,
                              child: SizedBox(
                                width: _image.width.toDouble(),
                                height: _image.height.toDouble(),
                                child: CustomPaint(
                                  painter: FacePainter(_image, _faces),
                                ),
                              )),
                        );
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        HeaderBeforeLogin(),

        image != null
            ? Container()
            : Positioned(
                bottom: 5,
                right: 150.w,
                child: InkWell(
                    onTap: () async {
                      // Take the Picture in a try / catch block. If anything goes wrong,
                      // catch the error.

                      // Ensure that the camera is initialized.
                      await _initializeControllerFuture;
                      // print(Provider.of<FacePainterr>(context, listen: false)
                      //     .colorss);
                      // Construct the path where the image should be saved using the
                      // pattern package.

                      final path = join(
                        (await getTemporaryDirectory()).path,
                        '${DateTime.now()}.jpg',
                      );
                      await _controller.takePicture(path);
                      // _saving = true;
                      // await Future.delayed(Duration(milliseconds: 500));
                      // await _cameraService.cameraController.stopImageStream();
                      // await Future.delayed(Duration(milliseconds: 200));
                      // await _cameraService.cameraController.takePicture(path);

                      File img = File(path);
                      // await signUp(context);
                      // _dataBaseService.cleanDB();
                      await applyModelOnImage(img);
                      if (Platform.isIOS) {
                        bool _has = await ImageFace.hasFace(img);
                        if (_has) {
                          numberOfFacesDetected = 1;
                        } else {
                          numberOfFacesDetected = 0;
                        }
                      } else if (Platform.isAndroid) {
                        try {
                          setState(() {
                            isLoading = true;
                            // numberOfFacesDetected = faces.length;
                            // imagePath = File(img.path);
                            // // _faces = faces;
                            // numberOfFacesDetected = faces.length;
                            // _loadImage(File(img.path));
                          });
                          final image =
                              FirebaseVisionImage.fromFile(File(img.path));

                          final faceDetector = FirebaseVision.instance
                              .faceDetector(FaceDetectorOptions(
                                  mode: FaceDetectorMode.fast,
                                  enableLandmarks: true));

                          List<Face> faces =
                              await faceDetector.processImage(image);
                          if (mounted) {
                            setState(() {
                              numberOfFacesDetected = faces.length;
                              imagePath = File(img.path);
                              _faces = faces;
                              numberOfFacesDetected = _faces.length;
                              _loadImage(File(img.path));
                            });
                          }
                        } catch (e) {
                          print(e);
                        }
                      }

                      final newPath = join(
                        (await getTemporaryDirectory()).path,
                        '${DateTime.now()}.jpg',
                      );
                      if (Platform.isAndroid) {
                        if (mounted)
                          setState(() {
                            image = File(newPath);
                            print("model name : $name ");
                            print("confidence : $confiedence");
                          });
                      }

                      await testCompressAndGetFile(
                          file: img, targetPath: newPath);
                      _controller.dispose();
                      // _cameraService.cameraController.dispose();
                      print("=====Compressed==========");
                      if (name == "mobiles") {
                        Fluttertoast.showToast(
                            msg: "خطأ : برجاء التقاط صورة حقيقية",
                            backgroundColor: Colors.red,
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_LONG);
                        Navigator.pop(context);
                      } else if (numberOfFacesDetected == 1) {
                        if (mounted)
                          setState(() {
                            // predictedUserName = _faceNetService.predict();
                          });
                        // print(predictedUserName);

                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SystemScanPage(
                                  path: newPath,
                                ),
                              ));
                        });
                      } else if (numberOfFacesDetected > 1) {
                        Fluttertoast.showToast(
                            msg: "خطا : تم التعرف علي اكثر من وجة ",
                            backgroundColor: Colors.red,
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_LONG);
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                            msg: "برجاء تصوير وجهك بوضوح",
                            backgroundColor: Colors.red,
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_LONG);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image(
                          image: AssetImage("resources/imageface.jpeg"),
                        ),
                      ),
                    ))),
        Positioned(
          left: 4.0,
          top: 4.0,
          child: SafeArea(
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Color(0xffF89A41),
                size: 40,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        // Positioned(
        //   child: AppButton(
        //     text: "load data",
        //     color: Colors.orange,
        //     icon: Icon(Icons.save),
        //     onPressed: () async {
        //       print(faceDetected != null);
        //       if (faceDetected != null) {
        //         setState(() {
        //           predictedUserName = _faceNetService.predict();
        //         });
        //       }
        //     },
        //   ),
        //   bottom: 10,
        //   left: 10,
        // ),
        // Positioned(
        //   child: AppButton(
        //     text: "Save pic",
        //     color: Colors.orange,
        //     icon: Icon(Icons.save),
        //     onPressed: () async {
        //       // _dataBaseService.cleanDB();

        //     },
        //   ),
        //   bottom: 10,
        //   left: 10,
        // )
      ]),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.orange;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
