import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/SytemScanner.dart';
import "package:qr_users/widgets/headers.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

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
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        HeaderBeforeLogin(),
        Positioned(
            top: 200.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(15)),
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
        Positioned(
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

                  await _controller.takePicture(path);
                  // File imgFile = File(img.path);
                  // If the picture was taken, display it on a new screen.
                  File img = File(path);
                  print(img.lengthSync());

                  final newPath = join(
                    (await getTemporaryDirectory()).path,
                    '${DateTime.now()}.jpg',
                  );

                  await testCompressAndGetFile(file: img, targetPath: newPath);
                  print("=====Compressed==========");

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SystemScanPage(
                          path: newPath,
                        ),
                      ));
                  _controller.dispose();
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                height: 80.h,
                width: 80.w,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
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
