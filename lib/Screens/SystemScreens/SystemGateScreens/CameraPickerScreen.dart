import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_face/image_face.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/SytemScanner.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  File imagePath;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;
  int numberOfFacesDetected = -1;
  @override
  void initState() {
    super.initState();
    numberOfFacesDetected = -1;
    image = null;
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
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
                top: 200.h,
                left: 20.w,
                right: 20.w,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Container(
                        height: 20,
                        child: AutoSizeText(
                          "برجاء التقاط صورة للتسجيل",
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                )),
        image != null
            ? Container()
            : Positioned(
                bottom: 5,
                right: 5,
                child: InkWell(
                  onTap: () async {
                    // Take the Picture in a try / catch block. If anything goes wrong,
                    // catch the error.
                    try {
                      // Ensure that the camera is initialized.
                      await _initializeControllerFuture;

                      // Construct the path where the image should be saved using the
                      // pattern package.

                      final path = join(
                        (await getTemporaryDirectory()).path,
                        '${DateTime.now()}.jpg',
                      );

                      await _controller
                          .takePicture(path); // File imgFile = File(img.path);
                      // If the picture was taken, display it on a new screen.
                      File img = File(path);
                      if (Platform.isIOS) {
                        bool _has = await ImageFace.hasFace(img);
                        if (_has) {
                          numberOfFacesDetected = 1;
                        } else {
                          numberOfFacesDetected = 0;
                        }
                      } else if (Platform.isAndroid) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
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
                        setState(() {
                          image = File(newPath);
                        });
                      }

                      await testCompressAndGetFile(
                          file: img, targetPath: newPath);

                      print("=====Compressed==========");
                      if (numberOfFacesDetected == 1) {
                        Fluttertoast.showToast(
                            msg: "تم التعرف علي الوجة بنجاح",
                            backgroundColor: Colors.green,
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_LONG);
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SystemScanPage(
                                  path: newPath,
                                ),
                              ));
                        });

                        _controller.dispose();
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
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    height: 80.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black),
                    child: Icon(
                      Icons.camera_alt,
                      size: 45,
                      color: Colors.orange,
                    ),
                  ),
                )),
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
