import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_mac/get_mac.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/AttendScanner.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/drawer.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_info/device_info.dart';

var cron1;
var cron2;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    print(userDataProvider.user.userType);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
          onTap: () async {},
          child: Scaffold(
            backgroundColor: Colors.white,
            drawer: userDataProvider.user.userType == 0 ? DrawerI() : null,
            body: Container(
                padding: EdgeInsets.only(bottom: 15.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userDataProvider.user.userType == 0
                        ? Header(
                            nav: true,
                          )
                        : Container(),
                    Expanded(
                      child: Center(
                        child: Lottie.asset("resources/qrlottie.json",
                            repeat: true),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          child: RoundedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanPage(),
                                ),
                              );
                            },
                            title: "سجل الأن",
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    ///check if he pressed back twich in the 2 seconds duration
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "اضغط مره اخرى للخروج من التطبيق",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.orange,
        fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
      );
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(false);
    }
  }
}