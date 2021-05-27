import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/NavSceen.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/constants.dart';
import 'package:qr_users/services/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/report_data.dart';

class UserAttendanceReportScreen extends StatefulWidget {
  final String name;
  final int siteId;
  // getUserReportUnits
  UserAttendanceReportScreen({this.name, this.siteId});

  @override
  _UserAttendanceReportScreenState createState() =>
      _UserAttendanceReportScreenState();
}

class _UserAttendanceReportScreenState
    extends State<UserAttendanceReportScreen> {
  TextEditingController _dateController = TextEditingController();

  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Member>> key = new GlobalKey();

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";

  String selectedId = "";
  Site siteData;
  DateTime yesterday;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var now = DateTime.now();

    toDate = DateTime(now.year, now.month, now.day - 1);
    fromDate = DateTime(toDate.year, toDate.month - 1, toDate.day + 1);

    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    String fromText = " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    String toText = " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";

    if (widget.name != "") {
      _nameController.text = widget.name;
      print("widget.siteId${widget.siteId}");
      siteIdIndex = widget.siteId;
    } else {
      getMembersData();
      Provider.of<ReportsData>(context, listen: false).userAttendanceReport =
          new UserAttendanceReport([], 0, 0, "0", -1);
    }
  }

  getMembersData() async {
    print("inside");
    var userProvider = Provider.of<UserData>(context, listen: false);
    var comProvider = Provider.of<CompanyData>(context, listen: false);

    if (userProvider.user.userType == 2) {
      siteId = userProvider.user.userSiteId;
      siteData = await Provider.of<SiteData>(context, listen: false)
          .getSpecificSite(siteId, userProvider.user.userToken);
      await Provider.of<MemberData>(context, listen: false)
          .getAllSiteMembers(siteId, userProvider.user.userToken);
    } else {
      if (Provider.of<SiteData>(context, listen: false).sitesList.isEmpty) {
        await Provider.of<SiteData>(context, listen: false)
            .getSitesByCompanyId(
                comProvider.com.id, userProvider.user.userToken)
            .then((value) async {
          print("Got Sites");
        });
      }
      siteId = Provider.of<SiteData>(context, listen: false).sitesList[0].id;

      await Provider.of<MemberData>(context, listen: false)
          .getAllSiteMembers(siteId, userProvider.user.userToken);
    }
  }

  int getSiteId(String siteName) {
    var list = Provider.of<SiteData>(context, listen: false).sitesList;
    int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].name) {
        return i;
      }
    }
    return -1;
  }

  int siteId = 0;
  int siteIdIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    return Consumer<ReportsData>(
      builder: (context, reportsData, child) {
        return WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Header(
                          nav: false,
                        ),
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallDirectoriesHeader(
                                Lottie.asset("resources/report.json",
                                    repeat: false),
                                "تقرير حضور مستخدم",
                              ),
                              Container(
                                  child: FutureBuilder(
                                      future: Provider.of<ReportsData>(context,
                                              listen: true)
                                          .futureListener,
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Container();
                                          case ConnectionState.done:
                                            return reportsData
                                                            .userAttendanceReport
                                                            .isDayOff ==
                                                        0 ||
                                                    reportsData
                                                            .userAttendanceReport
                                                            .userAttendListUnits
                                                            .length !=
                                                        0
                                                ? XlsxExportButton(
                                                    reportType: 2,
                                                    title: "تقرير حضور مستخدم",
                                                    day: _dateController.text,
                                                    userName:
                                                        _nameController.text,
                                                    site: userDataProvider.user
                                                                .userType ==
                                                            2
                                                        ? siteData.name
                                                        : Provider.of<SiteData>(
                                                                context)
                                                            .sitesList[
                                                                siteIdIndex]
                                                            .name,
                                                  )
                                                : Container();
                                          default:
                                            return Container();
                                        }
                                      }))
                            ],
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future:
                                  Provider.of<MemberData>(context, listen: true)
                                      .futureListener,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container(
                                      color: Colors.white,
                                      child: Center(
                                        child: Platform.isIOS
                                            ? CupertinoActivityIndicator(
                                                radius: 20,
                                              )
                                            : CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.orange),
                                              ),
                                      ),
                                    );
                                  case ConnectionState.done:
                                    return Column(
                                      children: [
                                        Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Theme(
                                              data: clockTheme1,
                                              child: Builder(
                                                builder: (context) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        final List<DateTime>
                                                            picked =
                                                            await DateRagePicker.showDatePicker(
                                                                context:
                                                                    context,
                                                                initialFirstDate:
                                                                    fromDate,
                                                                initialLastDate:
                                                                    toDate,
                                                                firstDate:
                                                                    new DateTime(
                                                                        2021),
                                                                lastDate:
                                                                    yesterday);
                                                        var newString = "";
                                                        setState(() {
                                                          fromDate =
                                                              picked.first;
                                                          toDate = picked.last;
                                                          // selectedDuration = kCalcDateDifferance(
                                                          //     fromDate.toString(), toDate.toString());
                                                          // selectedDuration += 1;
                                                          String fromText =
                                                              " من ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                          String toText =
                                                              " إلى ${DateFormat('yMMMd').format(toDate).toString()}";
                                                          newString =
                                                              "$fromText $toText";
                                                        });

                                                        if (_dateController
                                                                .text !=
                                                            newString) {
                                                          _dateController.text =
                                                              newString;

                                                          dateFromString =
                                                              apiFormatter
                                                                  .format(
                                                                      fromDate);
                                                          dateToString =
                                                              apiFormatter
                                                                  .format(
                                                                      toDate);

                                                          if (_nameController
                                                                      .text !=
                                                                  "" ||
                                                              Provider.of<UserData>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .user
                                                                      .userType ==
                                                                  2) {
                                                            var userToken =
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken;

                                                            await Provider.of<
                                                                        ReportsData>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getUserReportUnits(
                                                                    userToken,
                                                                    selectedId,
                                                                    dateFromString,
                                                                    dateToString);
                                                          }
                                                        }
                                                      },
                                                      child: Directionality(
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                        child: Container(
                                                          width: 330.w,
                                                          child: IgnorePointer(
                                                            child:
                                                                TextFormField(
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              controller:
                                                                  _dateController,
                                                              decoration: kTextFieldDecorationFromTO
                                                                  .copyWith(
                                                                      hintText:
                                                                          'المدة من / إلى',
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .calendar_today_rounded,
                                                                        color: Colors
                                                                            .orange,
                                                                      )),
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                              ),
                                            ),
                                          ],
                                        )),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Provider.of<UserData>(context,
                                                            listen: false)
                                                        .user
                                                        .userType ==
                                                    3 ||
                                                Provider.of<UserData>(context,
                                                            listen: false)
                                                        .user
                                                        .userType ==
                                                    4
                                            ? Container(
                                                width: 330.w,
                                                child: SiteDropdown(
                                                  edit: true,
                                                  list: Provider.of<SiteData>(
                                                          context)
                                                      .sitesList,
                                                  colour: Colors.white,
                                                  icon: Icons.location_on,
                                                  borderColor: Colors.black,
                                                  hint: "الموقع",
                                                  hintColor: Colors.black,
                                                  onChange: (value) {
                                                    // print()

                                                    siteIdIndex =
                                                        getSiteId(value);
                                                    if (siteId !=
                                                        Provider.of<SiteData>(
                                                                context,
                                                                listen: false)
                                                            .sitesList[
                                                                siteIdIndex]
                                                            .id) {
                                                      _nameController.text = "";
                                                      siteId =
                                                          Provider.of<SiteData>(
                                                                  context,
                                                                  listen: false)
                                                              .sitesList[
                                                                  siteIdIndex]
                                                              .id;

                                                      Provider.of<MemberData>(
                                                              context,
                                                              listen: false)
                                                          .getAllSiteMembers(
                                                              siteId,
                                                              Provider.of<UserData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .user
                                                                  .userToken);
                                                      setState(() {});
                                                    }
                                                    print(value);
                                                  },
                                                  selectedvalue: Provider.of<
                                                          SiteData>(context)
                                                      .sitesList[siteIdIndex]
                                                      .name,
                                                  textColor: Colors.orange,
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Container(
                                          width: 330.w,
                                          child: Directionality(
                                            textDirection: ui.TextDirection.rtl,
                                            child: searchTextField =
                                                AutoCompleteTextField<Member>(
                                              key: key,
                                              // onFocusChanged: (_) {
                                              //   setState(() {
                                              //     reportsData
                                              //             .userAttendanceReport =
                                              //         new UserAttendanceReport(
                                              //             [], 0, 0, "");
                                              //   });
                                              // },
                                              clearOnSubmit: false,
                                              controller: _nameController,
                                              suggestions:
                                                  Provider.of<MemberData>(
                                                          context)
                                                      .dropDownMembersList,
                                              style: TextStyle(
                                                  fontSize: ScreenUtil().setSp(
                                                      16,
                                                      allowFontScalingSelf:
                                                          true),
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                              decoration: kTextFieldDecorationFromTO
                                                  .copyWith(
                                                      hintStyle: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(16,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      hintText: 'الأسم',
                                                      prefixIcon: Icon(
                                                        Icons.person,
                                                        color: Colors.orange,
                                                      )),
                                              itemFilter: (item, query) {
                                                return item.name
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase());
                                              },
                                              itemSorter: (a, b) {
                                                return a.name.compareTo(b.name);
                                              },
                                              itemSubmitted: (item) async {
                                                if (_nameController.text !=
                                                    item.name) {
                                                  setState(() {
                                                    searchTextField
                                                        .textField
                                                        .controller
                                                        .text = item.name;
                                                  });
                                                  selectedId = item.id;
                                                  var userToken =
                                                      Provider.of<UserData>(
                                                              context,
                                                              listen: false)
                                                          .user
                                                          .userToken;

                                                  await Provider.of<
                                                              ReportsData>(
                                                          context,
                                                          listen: false)
                                                      .getUserReportUnits(
                                                          userToken,
                                                          item.id,
                                                          dateFromString,
                                                          dateToString);
                                                }
                                              },
                                              itemBuilder: (context, item) {
                                                // ui for the autocompelete row
                                                return Directionality(
                                                  textDirection:
                                                      ui.TextDirection.rtl,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 10,
                                                      bottom: 5,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 50.w,
                                                              height: 50.h,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      width:
                                                                          1.w,
                                                                      color: Colors
                                                                              .orange[
                                                                          700]),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(
                                                                          "https://attendanceback.tamauze.com/${item.userImageURL}"))),
                                                            ),
                                                            SizedBox(
                                                              width: 10.w,
                                                            ),
                                                            Container(
                                                              height: 20,
                                                              child:
                                                                  AutoSizeText(
                                                                item.name,
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(
                                                                        16,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Divider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        _nameController.text != ""
                                            ? Expanded(
                                                child: FutureBuilder(
                                                    future: Provider.of<
                                                                ReportsData>(
                                                            context)
                                                        .futureListener,
                                                    builder:
                                                        (context, snapshot) {
                                                      switch (snapshot
                                                          .connectionState) {
                                                        case ConnectionState
                                                            .waiting:
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Center(
                                                              child: Platform
                                                                      .isIOS
                                                                  ? CupertinoActivityIndicator()
                                                                  : CircularProgressIndicator(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      valueColor: new AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .orange),
                                                                    ),
                                                            ),
                                                          );
                                                        case ConnectionState
                                                            .done:
                                                          return reportsData
                                                                      .userAttendanceReport
                                                                      .isDayOff !=
                                                                  1
                                                              ? reportsData
                                                                          .userAttendanceReport
                                                                          .userAttendListUnits
                                                                          .length !=
                                                                      0
                                                                  ? Container(
                                                                      color: Colors
                                                                          .white,
                                                                      child: Directionality(
                                                                          textDirection: ui.TextDirection.rtl,
                                                                          child: Column(
                                                                            children: [
                                                                              DataTableHeader(),
                                                                              Expanded(
                                                                                  child: Container(
                                                                                child: ListView.builder(
                                                                                    itemCount: reportsData.userAttendanceReport.userAttendListUnits.length,
                                                                                    itemBuilder: (BuildContext context, int index) {
                                                                                      return DataTableRow(reportsData.userAttendanceReport.userAttendListUnits[index]);
                                                                                    }),
                                                                              )),
                                                                              DataTableEnd(
                                                                                absentsDays: reportsData.userAttendanceReport.totalAbsentDay.toString(),
                                                                                lateDays: reportsData.userAttendanceReport.totalLateDay.toString(),
                                                                                lateDuration: reportsData.userAttendanceReport.totalLateDuration,
                                                                              )
                                                                            ],
                                                                          )),
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              height: 20,
                                                                              child: AutoSizeText(
                                                                                "لا يوجد تسجيلات بهذا المستخدم",
                                                                                maxLines: 1,
                                                                                style: TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true), fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                      ],
                                                                    )
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              20,
                                                                          child:
                                                                              AutoSizeText(
                                                                            "لا يوجد تسجيلات: يوم اجازة",
                                                                            maxLines:
                                                                                1,
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )),
                                                                  ],
                                                                );
                                                        default:
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              valueColor:
                                                                  new AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .orange),
                                                            ),
                                                          );
                                                      }
                                                    }),
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        child: AutoSizeText(
                                                          "برجاء اختيار اسم مستخدم",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontSize: ScreenUtil()
                                                                  .setSp(16,
                                                                      allowFontScalingSelf:
                                                                          true),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                      ],
                                    );
                                  default:
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                    );
                                }
                              }),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            widget.name != ""
                                ? Navigator.pop(context)
                                : Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => NavScreenTwo(2)),
                                    (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> onWillPop() {
    widget.name != ""
        ? Navigator.pop(context)
        : Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => NavScreenTwo(2)),
            (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class DataTableRow extends StatelessWidget {
  final UserAttendanceReportUnit userAttendanceReportUnit;

  DataTableRow(this.userAttendanceReportUnit);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 160.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      userAttendanceReportUnit.date,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(14, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                        height: 50.h,
                        child: Center(
                          child: userAttendanceReportUnit.late == "-"
                              ? Container(
                                  height: 20,
                                  child: AutoSizeText(
                                    "-",
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(16,
                                            allowFontScalingSelf: true),
                                        color: Colors.black),
                                  ),
                                )
                              : Container(
                                  height: 20,
                                  child: AutoSizeText(
                                    userAttendanceReportUnit.late,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14,
                                            allowFontScalingSelf: true),
                                        color: Colors.red),
                                  ),
                                ),
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50.h,
                      child: Center(
                        child: userAttendanceReportUnit.timeIn == "-"
                            ? Container(
                                height: 20,
                                child: AutoSizeText(
                                  "غياب",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true),
                                      color: Colors.red),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    userAttendanceReportUnit.timeInIsPm == "am"
                                        ? Icons.wb_sunny
                                        : Icons.nightlight_round,
                                    size: ScreenUtil()
                                        .setSp(12, allowFontScalingSelf: true),
                                  ),
                                  Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      userAttendanceReportUnit.timeIn,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(14,
                                              allowFontScalingSelf: true),
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50.h,
                      child: Center(
                        child: userAttendanceReportUnit.timeOut == "-"
                            ? userAttendanceReportUnit.timeIn == "-"
                                ? Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      "",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                          color: Colors.red),
                                    ),
                                  )
                                : Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      "غياب",
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                          color: Colors.red),
                                    ),
                                  )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    userAttendanceReportUnit.timeOutIsPm == "am"
                                        ? Icons.wb_sunny
                                        : Icons.nightlight_round,
                                    size: ScreenUtil()
                                        .setSp(12, allowFontScalingSelf: true),
                                  ),
                                  Container(
                                    height: 20,
                                    child: AutoSizeText(
                                      userAttendanceReportUnit.timeOut,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(14,
                                              allowFontScalingSelf: true),
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DataTableEnd extends StatelessWidget {
  final absentsDays;
  final lateDays;
  final lateDuration;
  DataTableEnd({this.absentsDays, this.lateDays, this.lateDuration});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 50.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      'ايام الغياب:',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      absentsDays,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      'ايام التأخير:',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      lateDays,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      'مدة التأخير:',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Container(
                    height: 20,
                    child: AutoSizeText(
                      lateDuration,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Container(
                  width: 160.w,
                  height: 50.h,
                  child: Center(
                      child: Container(
                    height: 20,
                    child: AutoSizeText(
                      'التاريخ',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black),
                    ),
                  ))),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'التأخير',
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'حضور',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          child: Center(
                              child: Container(
                        height: 20,
                        child: AutoSizeText(
                          'انصراف',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.black),
                        ),
                      ))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}