import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/HomePage.dart';

import 'package:qr_users/Screens/intro.dart';
import 'package:qr_users/widgets/RoundedAlert.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_pickers/image_pickers.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:async';

class ChangePasswordScreen extends StatefulWidget {
  final int userType;
  final String userName;

  ChangePasswordScreen(this.userType, this.userName);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  TextEditingController _rePasswordController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  var isLoading = false;
  File img;
  GalleryMode _galleryMode = GalleryMode.image;
  List<Media> _listImagePaths = List();

  Future<void> selectImages() async {
    DateTime uploadTime = DateTime.now();
    Navigator.pop(context);

    try {
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return RoundedLoadingIndicator();
      //     });

      _galleryMode = GalleryMode.image;
      _listImagePaths = await ImagePickers.pickerPaths(
        galleryMode: _galleryMode,
        showGif: true,
        selectCount: 1,
        showCamera: true,
        cropConfig: CropConfig(enableCrop: true, height: 1, width: 1),
        compressSize: 500,
        uiConfig: UIConfig(
          uiThemeColor: Colors.orange,
        ),
      );
      _listImagePaths.forEach((media) {
        print(media.path.toString());
      });

      img = File(_listImagePaths[0].path);
      final path = Path.join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpg',
      );
      await testCompressAndGetFile(file: img, targetPath: path).then((value) {
        setState(() {
          isLoading = true;
        });
      });
      await Provider.of<UserData>(context, listen: false)
          .updateProfileImgFile(path)
          .then((value) {
        print("value = $value");
        if (value == "success") {
          setState(() {
            isLoading = false;
          });
          // Duration d = DateTime.now().difference(uploadTime);
          // Timer(d, () async {
          //   // Navigator.pop(context);
          // });
          Fluttertoast.showToast(
              msg: "تم التعديل بنجاح",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else if (value == "noInternet") {
          Fluttertoast.showToast(
              msg: "خطأ في التعديل: لا يوجد اتصال بالانترنت",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
          // Navigator.pop(context);
        } else {
          Fluttertoast.showToast(
              msg: "خطأ في التعديل",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
          // Navigator.pop(context);
        }
      });
      print("done!");
    } on PlatformException {}
  }

  Future<void> cameraPick() async {
    Navigator.pop(context);
    try {
      await ImagePickers.openCamera(
              cropConfig: CropConfig(enableCrop: true, width: 1, height: 1))
          .then((Media media) {
        _listImagePaths.clear();
        _listImagePaths.add(media);
      });

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RoundedLoadingIndicator();
          });
      // print(img.lengthSync());
      img = File(_listImagePaths[0].path);
      final path = Path.join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpg',
      );
      await testCompressAndGetFile(file: img, targetPath: path);

      await Provider.of<UserData>(context, listen: false)
          .updateProfileImgFile(path)
          .then((value) {
        if (value == "success") {
          // print(value);

          Fluttertoast.showToast(
              msg: "تم التعديل بنجاح",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else if (value == "noInternet") {
          Fluttertoast.showToast(
              msg: "خطأ في التعديل: لا يوجد اتصال بالانترنت",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else {
          Fluttertoast.showToast(
              msg: "خطأ في التعديل",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        }
      });

      Navigator.pop(context);
      print("done!");
    } catch (e) {
      print(e);
    }
  }

  Future<File> testCompressAndGetFile({File file, String targetPath}) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
    );

    return result;
  }

  void _showAddPhoto() {
    RoundedDialog _dialog = new RoundedDialog(
      cameraOnPressedFunc: () => cameraPick(),
      galleryOnPressedFunc: () => selectImages(),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _dialog;
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var _passwordVisible = true;
  var _repasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(builder: (context, userData, child) {
      return Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      title: "برجاء اختيار صورة شخصية",
                      headerImage: Container(
                        height: 140.h,
                        child: CachedNetworkImage(
                          imageUrl: userData.user.userImage,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.orange)),
                          ),
                          errorWidget: (context, url, error) =>
                              Provider.of<UserData>(context, listen: true)
                                  .changedWidget,
                        ),
                      ),
                      onPressed: () {
                        _showAddPhoto();
                        // _onImageButtonPressed(ImageSource.gallery);
                      },
                    ),
                    Container(
                      height: 20,
                      child: AutoSizeText(
                        "برجاء ادخال كلمة مرور ",
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: ScreenUtil()
                                .setSp(16, allowFontScalingSelf: true),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _profileFormKey,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'مطلوب';
                                      } else if (text.length >= 8 &&
                                          text.length <= 12) {
                                        Pattern pattern =
                                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                                        RegExp regex = new RegExp(pattern);
                                        if (!regex.hasMatch(text)) {
                                          return ' كلمة المرور يجب ان تتكون من احرف ابجدية كبيرة و صغيرة \n وعلامات ترقيم(!@#\$&*~) و رقم';
                                        } else {
                                          return null;
                                        }
                                      } else {
                                        return "كلمة المرور ان تكون اكثر من 8 احرف و اقل من 12";
                                      }
                                    },
                                    controller: _passwordController,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).nextFocus(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    obscureText: _passwordVisible,
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                      hintText: 'كلمة المرور',
                                      fillColor: Colors.white,
                                      suffixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                        FocusScope.of(context).requestFocus();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.0.h,
                              ),
                              Stack(
                                children: [
                                  TextFormField(
                                    onFieldSubmitted: (v) async {
                                      FocusScope.of(context).unfocus();
                                      await changePass();
                                    },
                                    controller: _rePasswordController,
                                    textInputAction: TextInputAction.done,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    validator: (text) {
                                      if (text != _passwordController.text) {
                                        return 'كلمة المرور غير متماثلتين';
                                      }
                                      return null;
                                    },
                                    obscureText: _repasswordVisible,
                                    decoration:
                                        kTextFieldDecorationWhite.copyWith(
                                      hintText: 'تأكيد كلمة المرور',
                                      fillColor: Colors.white,
                                      suffixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _repasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Update the state i.e. toogle the state of passwordVisible variable
                                      setState(() {
                                        _repasswordVisible =
                                            !_repasswordVisible;
                                        FocusScope.of(context).requestFocus();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await changePass();
                                },
                                child: Container(
                                  width: 230.w,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.orange),
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Container(
                                      height: 20,
                                      child: AutoSizeText(
                                        'حفظ',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(18,
                                                allowFontScalingSelf: true)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future changePass() async {
    if (_profileFormKey.currentState.validate()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RoundedLoadingIndicator();
          });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        var msg = await Provider.of<UserData>(context, listen: false)
            .changePassword(_passwordController.text);

        print(msg);
        Navigator.pop(context);
        if (msg == "success") {
          try {
            if (Platform.isIOS) {
              final storage = new FlutterSecureStorage();
              final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
              var data = await deviceInfoPlugin.iosInfo;
              String chainValue = await storage.read(key: "deviceMac");

              print(
                  "saving to the keychain mac : ${data.identifierForVendor}"); //UUID for iOS
              if (chainValue == "" || chainValue == null) {
                print("dddd");
                await storage
                    .write(key: "deviceMac", value: data.identifierForVendor)
                    .whenComplete(
                        () => print("item added to keychain successfully !"))
                    .catchError((e) {
                  print(e);
                });
              }
            }
          } catch (e) {
            print(e);
          }

          prefs.setStringList(
              'userData', [widget.userName, _passwordController.text]);
          if (widget.userType == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
          } else if (widget.userType > 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PageIntro(
                    userType: 1,
                  ),
                ));
          }

          Fluttertoast.showToast(
              msg: "تم الحفظ بنجاح",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
        } else {
          Fluttertoast.showToast(
              gravity: ToastGravity.CENTER,
              msg: "خطأ في حفظ البيانات",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true));
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class RoundedDialog extends StatelessWidget {
  final Function cameraOnPressedFunc;
  final Function galleryOnPressedFunc;

  RoundedDialog({this.cameraOnPressedFunc, this.galleryOnPressedFunc});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          height: 170.h,
          width: 300.w,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: cameraOnPressedFunc,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          size: ScreenUtil()
                              .setSp(40, allowFontScalingSelf: true),
                          color: Colors.orange,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          height: 20,
                          child: AutoSizeText(
                            "التقاط صورة",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(18, allowFontScalingSelf: true)),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  InkWell(
                    onTap: galleryOnPressedFunc,
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.image,
                            size: ScreenUtil()
                                .setSp(40, allowFontScalingSelf: true),
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Container(
                            height: 20,
                            child: AutoSizeText(
                              "اختر صورة من المعرض",
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: ScreenUtil()
                                      .setSp(18, allowFontScalingSelf: true)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  SizedBox(
                    width: 150.0.w,
                    child: Material(
                      elevation: 5.0,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.0),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        minWidth: 130.w,
                        height: 30.h,
                        child: Container(
                          height: 20,
                          child: AutoSizeText(
                            "الغاء",
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(17, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
