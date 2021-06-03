import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:animate_do/animate_do.dart';

import 'UsersScreen.dart';

class UserFullDataScreen extends StatefulWidget {
  @override
  _UserFullDataScreenState createState() => _UserFullDataScreenState();

  UserFullDataScreen(
      {this.user,
      this.onResetMac,
      this.onTapDelete,
      this.onTapEdit,
      this.siteIndex});
  final Member user;
  final int siteIndex;
  final Function onTapEdit;
  final Function onTapDelete;
  final Function onResetMac;
}

bool checkBoxVal = false;

class _UserFullDataScreenState extends State<UserFullDataScreen>
    with SingleTickerProviderStateMixin {
  void initState() {
    super.initState();
    animateController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(milliseconds: 200),
    );
  }

  AnimationController animateController;
  @override
  Widget build(BuildContext context) {
    var userType = Provider.of<UserData>(context, listen: false).user.userType;
    return Scaffold(
      body: Column(
        children: [
          Header(nav: false),
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: Color(0xffFF7E00),
                          ),
                        ),
                        child: Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  '$baseURL/${widget.user.userImageURL}',
                                ),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2, color: Color(0xffFF7E00))),
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        height: 20,
                        child: AutoSizeText(
                          widget.user.name,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: ScreenUtil()
                                  .setSp(14, allowFontScalingSelf: true),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                UserDataField(
                                  icon: Icons.title,
                                  text: widget.user.jobTitle,
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                UserDataField(
                                  icon: Icons.email,
                                  text: widget.user.email,
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                userType == 4
                                    ? UserDataField(
                                        icon: Icons.person,
                                        text: widget.user.normalizedName,
                                      )
                                    : Container(),
                                userType == 4
                                    ? SizedBox(
                                        height: 10.0.h,
                                      )
                                    : Container(),
                                UserDataField(
                                    icon: Icons.phone,
                                    text: plusSignPhone(widget.user.phoneNumber)
                                        .replaceAll(
                                            new RegExp(r"\s+\b|\b\s"), "")),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                UserDataField(
                                  icon: Icons.location_on,
                                  text: Provider.of<SiteData>(context,
                                          listen: true)
                                      .sitesList[widget.siteIndex]
                                      .name,
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                UserDataField(
                                    icon: Icons.query_builder,
                                    text: getShiftName()),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                UserDataField(
                                    icon: FontAwesomeIcons.moneyBill,
                                    text: "7000 جنية مصرى"),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "تاريخ اخر اذن",
                                      ),
                                      Text("لا يوجد ")
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0.h,
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "تاريخ التعيين",
                                      ),
                                      Text(DateFormat('yMMMd')
                                          .format(DateTime.now())
                                          .toString())
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "السماح للمستخدم بالتسجيل بالبطاقة",
                                      ),
                                      Pulse(
                                        duration: Duration(milliseconds: 800),
                                        controller: (controller) =>
                                            animateController = controller,
                                        manualTrigger: true,
                                        child: Checkbox(
                                          checkColor: Colors.white,
                                          activeColor: Colors.orange,
                                          value: checkBoxVal,
                                          onChanged: (value) {
                                            if (value == true) {
                                              animateController.repeat();
                                            }
                                            setState(() {
                                              print(animateController.value);
                                              checkBoxVal = value;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                                child:
                                    RounderButton("تعديل", widget.onTapEdit)),
                            SizedBox(
                              width: 20.w,
                            ),
                            Provider.of<UserData>(context, listen: false)
                                        .user
                                        .id ==
                                    widget.user.id
                                ? Container()
                                : Expanded(
                                    child: RounderButton(
                                        "حذف", widget.onTapDelete))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //   right: 5.0,
          //   top: 5.0,
          //   child: Container(
          //     width: 50.w,
          //     height: 50.h,
          //     child: InkWell(
          //       onTap: () {
          //         widget.onResetMac();
          //       },
          //       child: Icon(
          //         Icons.repeat,
          //         color: Colors.orange,
          //         size: 25,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  String getShiftName() {
    var list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (list[i].shiftId == widget.user.shiftId) {
        return list[i].shiftName;
      }
    }
    return "";
  }

  String plusSignPhone(String phoneNum) {
    int len = phoneNum.length;
    if (phoneNum[0] == "+") {
      return " ${phoneNum.substring(1, len)}+";
    } else {
      return "$phoneNum+";
    }
  }
}
