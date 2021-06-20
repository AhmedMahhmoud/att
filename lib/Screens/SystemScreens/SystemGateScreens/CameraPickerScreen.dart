import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_face/image_face.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/MLmodule/db/database.dart';
import 'package:qr_users/MLmodule/services/camera.service.dart';
import 'package:qr_users/MLmodule/services/facenet.service.dart';

import 'package:qr_users/MLmodule/services/ml_kit_service.dart';
import 'package:qr_users/MLmodule/widgets/FacePainter.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/MainCompanySettings.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/SytemScanner.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import "package:qr_users/MLmodule/services/UtilsScanner.dart";
import 'package:tflite/tflite.dart';
import 'package:qr_users/MLmodule/services/FaceDetectorPainter.dart';

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

  File imagePath;
  Face faceDetected;
  Size imageSize;

  String predictedUserName = "";

  bool cameraInitializated = false;
  bool isWorking = false;
  Size size;

  Color cameraColor;
  CameraController cameraController;
  FaceDetector faceDetector;
  List _result;
  String confiedence = "";
  String name = "";
  String numbers = "";
  Future _initializeControllerFuture;
  // bool isLoading = false;
  bool intialize = false;
  int numberOfFacesDetected = -1;

  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  initCamera() async {
    await _initializeControllerFuture;
    cameraController = CameraController(widget.camera, ResolutionPreset.medium);

    faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        enableTracking: true,
        mode: FaceDetectorMode.accurate));

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      bool intialize = true;
      Future.delayed(Duration(milliseconds: 200));

      cameraController.startImageStream((imageFromStream) {
        if (!isWorking) {
          isWorking = true;

          //implementar FaceDetection
          performDetectionOnStreamFrame(imageFromStream);
        }
      });
    });
  }

  List<Face> scannResult = [];
  performDetectionOnStreamFrame(CameraImage imageFromStream) {
    UtilsScanner.detect(
            image: imageFromStream,
            detectInImage: faceDetector.processImage,
            imageRotation: widget.camera.sensorOrientation)
        .then((dynamic result) {
      setState(() {
        scannResult = result;
      });
    }).whenComplete(() {
      isWorking = false;
    });
  }

  @override
  void initState() {
    super.initState();
    intialize = false;
    // loadModel();
    // print(imagePath);
    initCamera();

    //

    // _initializeControllerFuture = _cameraService.cameraController.initialize();
  }

  Widget buildResult() {
    if (scannResult == null ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      return Container();
    }

    final Size imageSize = Size(cameraController.value.previewSize.height,
        cameraController.value.previewSize.width);

    // customPainter
    CustomPainter customPainter =
        FaceDetectorPainter(imageSize, scannResult, cameraLensDirection);

    return CustomPaint(
      painter: customPainter,
    );
  }

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

  File image;
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
    cameraController?.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackWidgetChildren = [];
    size = MediaQuery.of(context).size;

    if (cameraController != null) {
      stackWidgetChildren.add(Positioned(
          left: 0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (cameraController.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: Stack(
                      children: [
                        CameraPreview(cameraController),
                      ],
                    ))
                : Container(),
          )));
    }
    stackWidgetChildren.add(Positioned(
        left: 0.0,
        width: size.width,
        height: size.height,
        child: buildResult()));
    stackWidgetChildren.add(Positioned(
        top: size.height - 250.h,
        left: 0,
        width: size.width,
        height: 450.h,
        child: scannResult.length == 1
            ? Container(
                margin: EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
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
                      ),
                      onTap: () async {
                        final path = join(
                          (await getTemporaryDirectory()).path,
                          '${DateTime.now()}.jpg',
                        );
                        // await _controller.takePicture(path);

                        await Future.delayed(Duration(milliseconds: 500));
                        await cameraController.stopImageStream();
                        await Future.delayed(Duration(milliseconds: 200));
                        await cameraController.takePicture(path);

                        File img = File(path);
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
                            if (mounted) {
                              setState(() {
                                numberOfFacesDetected = scannResult.length;
                                imagePath = File(img.path);
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
                        // _cameraService.cameraController.dispose();
                        cameraController.dispose();
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
                    )
                  ],
                ),
              )
            : Container()));

    return GestureDetector(
      child: Scaffold(
        body: image == null
            ? Stack(
                children: stackWidgetChildren,
              )
            : Stack(children: [
                Image(
                  image: FileImage(imagePath),
                  fit: BoxFit.fill,
                  height: double.infinity,
                ),
                HeaderBeforeLogin(),

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
      ),
    );
  }
}
