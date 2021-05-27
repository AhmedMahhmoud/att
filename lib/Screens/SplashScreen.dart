import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/ChangePasswordScreen.dart';
import 'package:qr_users/Screens/ErrorScreen.dart';
import 'package:qr_users/Screens/HomePage.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Screens/errorscreen2.dart';
import 'package:qr_users/Screens/loginScreen.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Screens/intro.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;

  Future checkSharedUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userData = (prefs.getStringList('userData') ?? null);
    print(userData);
    if (userData == null || userData.isEmpty) {
      print('null');
      await reverse("", 1);
    } else {
      print('not null');
      var value = await login(userName: userData[0], password: userData[1]);
      print('not null------$value');
      reverse(userData[0], value);
    }
  }

  Future<int> login({String userName, String password}) async {
    Provider.of<UserData>(context, listen: false).getCurrentLocation();
    Provider.of<ShiftApi>(context, listen: false).getCurrentLocation();

    return Provider.of<UserData>(context, listen: false)
        .loginPost(userName, password, context)
        .catchError(((e) {
      print(e);
    }));
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cachedUserData = (prefs.getStringList('allUserData') ?? null);
    if (cachedUserData == null || cachedUserData.isEmpty) {
      print('null');

      // Navigator.of(context).pushReplacement(
      //     new MaterialPageRoute(builder: (context) => PageIntro()));
    } else {
      print('not null');
      print(cachedUserData[4]);
      Provider.of<UserData>(context, listen: false).cachedUserData =
          cachedUserData;
    }
  }

  AnimationController animationController;
  reverse(String userName, value) {
    //Reverse animation Function

    setState(() {
      animationController.reverse();
      Timer(new Duration(milliseconds: 2000), () async {
//        checkSharedUserData();
        if (userName != "") {
          if (Provider.of<UserData>(context, listen: false).changedPassword ==
              false) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(value, userName),
                ));
          } else {
            if (value > 0) {
              print(value);
              print("aa");

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return ErrorScreen2(child: NavScreenTwo(0));
                // return ShowCaseWidget(
                //   onStart: (index, key) {
                //     log('onStart: $index, $key');
                //   },
                //   onComplete: (index, key) {
                //     log('onComplete: $index, $key');
                //   },
                //   builder: Builder(builder: (context) => NavScreen(0)),
                //   autoPlay: false,
                //   onFinish: () {
                //     Provider.of<PermissionHan>(context, listen: false)
                //         .showHome = false;
                //     Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => NavScreenTwo(0)));
                //   },
                //   autoPlayDelay: Duration(seconds: 3),
                //   autoPlayLockEnable: false,
                // );
              }));

              getUserData();
            } else if (value == 0) {
              print("normal user");
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Container(child: ErrorScreen2(child: HomePage())),
                  ));
              getUserData();
            } else if (value == -1) {
              await getUserData();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (context) =>
                      ErrorScreen("لا يوجد اتصال بالانترنت", true)));
            } else if (value == -2) {
              Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(builder: (context) => LoginScreen()));
            } else if (value == -3) {
              await getUserData();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (context) => ErrorScreen(
                      "خطأ فى بيانات الحساب\nمن فضلك راجع مدير النظام", true)));
            } else if (value == -4) {
              await getUserData();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (context) => ErrorScreen(
                      "خطأ فى بيانات الحساب\nالخدمة متوقفة حاليا\nمن فضلك راجع مدير النظام",
                      true)));
            } else {
              Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(builder: (context) => PageIntro()));
            }
          }
        } else {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => PageIntro()));
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // filterList();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    //start Animation
    animationController.forward();

    new Timer(new Duration(milliseconds: 3000), () async {
      await checkSharedUserData();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: !isLoading
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: <Widget>[
                  FadeTransition(
                    opacity: animationController.drive(
                      CurveTween(curve: Curves.fastOutSlowIn),
                    ),
                    child: Stack(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                            child: Container(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: Image.asset('resources/smartlogo.png')),
                          height: 190,
                          width: 190,
                        )),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 500.w,
                              child: Lottie.asset("resources/fire.json",
                                  fit: BoxFit.fitWidth),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 140.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          height: 130.h,
                                          child: Image.asset(
                                            'resources/TDSlogo.png',
                                            fit: BoxFit.fitHeight,
                                          )),
                                    ],
                                  ),
                                  // Text(
                                  //   "AMH Group احدى شركات ",
                                  //   style: TextStyle(color: Colors.orange),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
    );
  }
}