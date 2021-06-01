import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/ErrorScreen.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens//MembersScreens/UsersScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/SitesScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime currentBackPressTime;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future getDaysOff() async {
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    await Provider.of<DaysOffData>(context, listen: false)
        .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvier = Provider.of<CompanyData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DirectoriesHeader(
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.0),
                      child: Lottie.asset("resources/settings1.json",
                          repeat: false),
                    ),
                  ),
                  "الاعدادات"),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "الاعدادات",
              //       style: TextStyle(
              //           fontSize: 26,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.orange),
              //     )
              //   ],
              // ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        ServiceTile(
                            title: "المواقع",
                            subTitle: "ادارة المواقع",
                            icon: Icons.location_on,
                            onTap: () async {
                              var bool = await userDataProvider
                                  .isConnectedToInternet();
                              if (bool) {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => SitesScreen(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => ErrorScreen(
                                        "لا يوجد اتصال بالانترنت", false),
                                  ),
                                );
                              }
                              print("المواقع");
                            }),
                        ServiceTile(
                            title: "المناوبات",
                            subTitle: "ادارة المناوبات",
                            icon: Icons.alarm,
                            onTap: () async {
                              var bool = await userDataProvider
                                  .isConnectedToInternet();
                              if (bool) {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => ShiftsScreen(0, -1),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => ErrorScreen(
                                        "لا يوجد اتصال بالانترنت", false),
                                  ),
                                );
                              }
                              print("المناوبات");
                            }),
                        ServiceTile(
                            title: "المستخدمين",
                            subTitle: "ادارة المستخدمين",
                            icon: Icons.person,
                            onTap: () async {
                              var bool = await userDataProvider
                                  .isConnectedToInternet();
                              if (bool) {
                                Provider.of<SiteData>(context, listen: false)
                                    .setSiteValue("كل المواقع");
                                Provider.of<SiteData>(context, listen: false)
                                    .setDropDownIndex(0);
                                if (Provider.of<SiteData>(context,
                                        listen: false)
                                    .sitesList
                                    .isEmpty) {
                                  await Provider.of<SiteData>(context,
                                          listen: false)
                                      .getSitesByCompanyId(comProvier.com.id,
                                          userProvider.user.userToken, context)
                                      .then((value) async {
                                    print("Got Sites");
                                  });
                                }
                                await Provider.of<ShiftsData>(context,
                                        listen: false)
                                    .findMatchingShifts(
                                        Provider.of<SiteData>(context,
                                                listen: false)
                                            .sitesList[Provider.of<SiteData>(
                                                    context,
                                                    listen: false)
                                                .dropDownSitesIndex]
                                            .id,
                                        false);
                                Provider.of<SiteData>(context, listen: false)
                                    .fillCurrentShiftID(Provider.of<ShiftsData>(
                                            context,
                                            listen: false)
                                        .shiftsBySite[Provider.of<SiteData>(
                                                context,
                                                listen: false)
                                            .dropDownSitesIndex]
                                        .shiftId);
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) =>
                                        UsersScreen(-1, false),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => ErrorScreen(
                                        "لا يوجد اتصال بالانترنت", false),
                                  ),
                                );
                              }
                              print("الموظفين");
                            }),
                        ServiceTile(
                            title: "ايام الاجازات",
                            subTitle: "ادارة ايام الاجازات",
                            icon: Icons.calendar_today_rounded,
                            onTap: () async {
                              var bool = await userDataProvider
                                  .isConnectedToInternet();
                              if (bool) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return RoundedLoadingIndicator();
                                    });
                                await getDaysOff();
                                Navigator.pop(context);
                                showVacationsDetails();
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (context) => ErrorScreen(
                                        "لا يوجد اتصال بالانترنت", false),
                                  ),
                                );
                              }
                              print("الموظفين");
                            }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  showVacationsDetails() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    Container(
                      height: 460.h,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            DirectoriesHeader(
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40.0),
                                child: Lottie.asset("resources/shifts.json",
                                    repeat: false),
                              ),
                              "ايام الاجازات للشركة",
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: ListView.builder(
                                      itemCount: Provider.of<DaysOffData>(
                                              context,
                                              listen: true)
                                          .weak
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        print(index);
                                        return CustomRow(
                                            model: Provider.of<DaysOffData>(
                                                    context,
                                                    listen: true)
                                                .weak[index],
                                            onTap: () {
                                              int i = 0;
                                              if (Provider.of<DaysOffData>(
                                                          context,
                                                          listen: false)
                                                      .weak[index]
                                                      .isDayOff ==
                                                  true) {
                                                Provider.of<DaysOffData>(
                                                        context,
                                                        listen: false)
                                                    .toggleDayOff(index);
                                              } else {
                                                Provider.of<DaysOffData>(
                                                        context,
                                                        listen: false)
                                                    .weak
                                                    .forEach((element) {
                                                  if (element.isDayOff ==
                                                      true) {
                                                    i++;
                                                  }
                                                });

                                                if (i < 2) {
                                                  Provider.of<DaysOffData>(
                                                          context,
                                                          listen: false)
                                                      .toggleDayOn(index);
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "لا يمكن اخيار اكثر من يومين",
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.red,
                                                      textColor: Colors.black,
                                                      fontSize: ScreenUtil().setSp(
                                                          16,
                                                          allowFontScalingSelf:
                                                              true));
                                                }
                                              }
                                            });
                                      })),
                            ),
                            Container(
                              width: 100.w,
                              child: RounderButton("حفظ", () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return RoundedLoadingIndicator();
                                    });

                                var userProvider = Provider.of<UserData>(
                                    context,
                                    listen: false);
                                var comProvider = Provider.of<CompanyData>(
                                    context,
                                    listen: false);
                                var msg = await Provider.of<DaysOffData>(
                                        context,
                                        listen: false)
                                    .editDaysOffApi(comProvider.com.id,
                                        userProvider.user.userToken, context);
                                if (msg == "Success") {
                                  Fluttertoast.showToast(
                                      msg: "تم التعديل بنجاح",
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true));
                                  Navigator.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "خطا في التعديل",
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.black,
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true));
                                }
                                Navigator.pop(context);
                              }),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.orange,
                            size: ScreenUtil()
                                .setSp(25, allowFontScalingSelf: true),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  Future<bool> onWillPop() {
    //If user on home Screen
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  ServiceTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          icon,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: Text(
          title,
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          subTitle,
          textAlign: TextAlign.right,
        ),
        leading: Icon(
          Icons.chevron_left,
          size: ScreenUtil().setSp(40, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  final Day model;
  final Function onTap;
  CustomRow({this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 12.0, right: 12.0, top: 3.0, bottom: 3.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              model.dayName,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                  fontWeight: FontWeight.w600),
            ),
            this.model.isDayOff == true
                ? Icon(
                    Icons.radio_button_checked,
                    color: Colors.orange,
                  )
                : Icon(Icons.radio_button_unchecked),
          ],
        ),
      ),
    );
  }
}
