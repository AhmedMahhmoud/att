import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/services/DaysOff.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'dart:ui' as ui;
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'MembersScreens/UsersScreen.dart';
import 'SettingsScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanySettings extends StatefulWidget {
  @override
  _CompanySettingsState createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<CompanySettings> {
  @override
  Widget build(BuildContext context) {
    Future getDaysOff() async {
      var userProvider = Provider.of<UserData>(context, listen: false);
      var comProvider = Provider.of<CompanyData>(context, listen: false);

      await Provider.of<DaysOffData>(context, listen: false)
          .getDaysOff(comProvider.com.id, userProvider.user.userToken, context);
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Header(nav: false),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: SmallDirectoriesHeader(
                Lottie.asset("resources/settings1.json", repeat: false),
                "دليل الأعدادات",
              ),
            ),
          ),
          ServiceTile(
              title: "العطلات الأسبوعية",
              subTitle: "ادارة العطلات الأسبوعية",
              icon: FontAwesomeIcons.calendarWeek,
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedLoadingIndicator();
                    });
                await getDaysOff();
                Navigator.pop(context);
                showVacationsDetails();
              }),
          ServiceTile(
              title: "العطلات الرسمية",
              subTitle: "ادارة العطلات الرسمية",
              icon: Icons.calendar_today_rounded,
              onTap: () async {}),
          ServiceTile(
              title: "اعدادات الخصومات",
              subTitle: "ادارة الخصومات",
              icon: Icons.money_off_csred_outlined,
              onTap: () async {}),
          ServiceTile(
              title: "الأجازات و المأموريات",
              subTitle: "ادارة الأجازات و المأموريات",
              icon: FontAwesomeIcons.streetView,
              onTap: () async {}),
        ],
      ),
    );
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
}
