import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/complaint.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/order_list.dart';
import 'package:hascol_inspection/screens/profile.dart';
import 'package:hascol_inspection/screens/task_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'create_order.dart';
import 'inspection.dart';

class Home extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  final double width = 7;
  int _selectedIndex = 0;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 48.0, left: 5, right: 5),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff12283D),
                  radius: 30,
                  child: Text(
                    'SB',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ), //Text
                ),
                SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Home,',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xff8A8A8A),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'Sales Bridge',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xff000000),
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                ),
                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: Icon(
                      Icons.add_box_rounded,
                      color: Color(0xff12283D),
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Create_Order()),
                      );
                      print("Pressed");
                    }),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You've got",
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 18,
                          color: Color(0xd8787676),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      Text(
                        '4 task today',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 18,
                          color: Color(0xff12283D),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  color: Color(0xff3a833c),//color: Color(0xff12283D),
                  elevation: 15,
                  child: SizedBox(
                    width: 165,
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: Color(0xff586776),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                              ),
                            ),
                          ), //Text
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Orders',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffffffff),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              Text(
                                '100 Orders',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xffc7c7c7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              OutlinedButton(
                                child: Text(
                                  'View Order',
                                  style: GoogleFonts.montserrat(
                                    color: Color(0xffc7c7c7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1.0, color: Color(0xd5e0e0e0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Create_Order()),
                                  );
                                },
                              )
                            ],
                          ),

                          //SizedBox
                          //T //SizedBox
                          //SizedBox
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  color: Color(0xff3a833c),//color: Color(0xff12283D),
                  elevation: 15,
                  child: SizedBox(
                    width: 165,
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: Color(0xff586776),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                FluentIcons.gas_pump_24_regular,
                                color: Colors.white,
                              ),
                            ),
                          ), //Text
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Outlets',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffffffff),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              Text(
                                '100 Outlets',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xffc7c7c7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              OutlinedButton(
                                child: Text(
                                  'View Outlets',
                                  style: GoogleFonts.montserrat(
                                    color: Color(0xffc7c7c7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1.0, color: Color(0xd5e0e0e0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Create_Order()),
                                  );
                                },
                              )
                            ],
                          ),

                          //SizedBox
                          //T //SizedBox
                          //SizedBox
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox,
                ),

                //
              ],
            ),
            SizedBox(
              height: 10,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: Color(0xfff9f9f9),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming',
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displayLarge,
                                fontSize: 18,
                                color: Color(0xff12283D),
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            Text(
                              'View All',
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displaySmall,
                                fontSize: 15,
                                color: Color(0xff727272),
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
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
                ),
              ),
            ),

          ],
        ),
      ),
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Tasks()),
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
