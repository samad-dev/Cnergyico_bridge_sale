import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/create_order.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'inspection.dart';

class Tasks extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 10,
          title: Text(
            'Tasks',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Color(0xff12283D),
                fontSize: 16),
          ),

        ),
        body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 5,
                    child: TextField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(FluentIcons.search_12_regular,
                              color: Color(0xff8d8d8d)),
                          hintText: 'Search...',
                          hintStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                              color: Color(0xff12283D),
                              fontSize: 16),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 10,
                    color: Color(0xffffffff),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Inspection at Hascol - Jauhar',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xff12283D),
                                  fontSize: 14),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock Reconcilation',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                                Text(
                                  'Details',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(height: 1, color: Color(0xffBFBFBF)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Wrap(
                                  children: [
                                    Icon(
                                      FluentIcons.clock_48_regular,
                                      size: 15,
                                      color: Color(0xff12283d),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '2023-09-25 05:30 PM',
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w200,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff737373),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: Text(
                                    'Start',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff12283D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),

                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Inspection()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Color(0xffffffff),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Inspection at Hascol - Jauhar',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xff12283D),
                                  fontSize: 14),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock Reconcilation',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                                Text(
                                  'Details',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(height: 1, color: Color(0xffBFBFBF)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Wrap(
                                  children: [
                                    Icon(
                                      FluentIcons.clock_48_regular,
                                      size: 15,
                                      color: Color(0xff12283d),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '2023-09-25 05:30 PM',
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w200,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff737373),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: Text(
                                    'Start',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff12283D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),

                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Inspection()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    color: Color(0xffffffff),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Inspection at Hascol - Jauhar',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xff12283D),
                                  fontSize: 14),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock Reconcilation',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                                Text(
                                  'Details',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xff737373),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(height: 1, color: Color(0xffBFBFBF)),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Wrap(
                                  children: [
                                    Icon(
                                      FluentIcons.clock_48_regular,
                                      size: 15,
                                      color: Color(0xff12283d),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '2023-09-25 05:30 PM',
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w200,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff737373),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: Text(
                                    'Start',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff12283D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),

                                  ),
                                  onPressed: () {

                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x8ca9a9a9),
                blurRadius: 20,
              ),
            ],
          ),
          child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              unselectedItemColor: Color(0xff8d8d8d),
              unselectedLabelStyle:
              const TextStyle(color: Color(0xff8d8d8d), fontSize: 14),
              unselectedFontSize: 14,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedIconTheme: IconThemeData(
                color: Color(0xff12283D),
              ),
              type: BottomNavigationBarType.shifting,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.home_32_regular,
                      size: 20,
                    ),
                    label: 'Home',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.weather_sunny_16_regular,
                      size: 20,
                    ),
                    label: 'Tasks',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                  icon: Icon(
                    FluentIcons.inprivate_account_16_regular,
                    size: 20,
                  ),
                  label: 'Profile',
                  backgroundColor: Colors.white,
                ),
              ],
              selectedItemColor: Color(0xff12283D),
              iconSize: 40,
              onTap: _onItemTapped,
              elevation: 15),
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // if (_selectedIndex == 1) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Orders()),
    //   );
    // }
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
    }
  }
}
