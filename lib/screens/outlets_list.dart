import 'dart:convert';

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
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class Outlets extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _OutletsState createState() => _OutletsState();
}


class _OutletsState extends State<Outlets> {
  //created variable:
  List<Map<String, dynamic>> outlets_list = [];
  List<Map<String, dynamic>> filteredData = [];
  @override
  void initState() {
    super.initState();
    Outlets_list();
  }

  Future<void> Outlets_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        outlets_list = List<Map<String, dynamic>>.from(data);
        filteredData = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
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
            'Outlets',
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
                              fontSize: 16
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index2) {
                        final ledger = filteredData[index2]['acount'];
                        final dealer_id = filteredData[index2]['id'];
                        final location = filteredData[index2]['location'];
                        final contact = filteredData[index2]['contact'];
                        final sap_no = filteredData[index2]["sap_no"];
                        final name=filteredData[index2]["name"];
                        return Card(
                          elevation: 10,
                          color: Color(0xffe9e9e9),//Color(0xffF0F0F0),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /*
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: CircleAvatar(
                                              radius:
                                              28, // Adjust the size of the circular avatar
                                              backgroundColor: Constants.secondary_color,
                                              child: ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn,
                                                ),
                                                child: Image.asset(
                                                  "assets/images/boss.png",
                                                  width: 38,
                                                  height: 38,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      */
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child:
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.only(top:16),
                                                          width: MediaQuery.of(context).size.width/2.39,
                                                          child: Text(
                                                            '$name',
                                                            style: GoogleFonts.montserrat(
                                                                fontWeight: FontWeight.w600,
                                                                fontStyle: FontStyle.normal,
                                                                color: Color(0xff12283D),
                                                                fontSize: 16),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Icon(Icons.graphic_eq)
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child:
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/1.8,
                                                          child: Text(
                                                            '$location',
                                                            style: GoogleFonts.montserrat(
                                                                fontWeight: FontWeight.w200,
                                                                fontStyle: FontStyle.normal,
                                                                color: Colors.black54,
                                                                fontSize: 12),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: GestureDetector(
                                                              child: Text("Details"),
                                                            onTap: (){
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: Text('Details:'),
                                                                    content: Container(
                                                                      height: MediaQuery.of(context).size.width/1.5,
                                                                        width: MediaQuery.of(context).size.width/1.2,
                                                                        child:
                                                                        Column(
                                                                          mainAxisAlignment:MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Name: ',
                                                                              style: GoogleFonts.montserrat(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FontStyle.normal,
                                                                                  color: Color(0xff12283D),
                                                                                  fontSize: 16),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left:12.0),
                                                                              child: Container(
                                                                                width: MediaQuery.of(context).size.width/2,
                                                                                child: Text(
                                                                                  '$name',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'location: ',
                                                                              style: GoogleFonts.montserrat(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FontStyle.normal,
                                                                                  color: Color(0xff12283D),
                                                                                  fontSize: 16),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left:12.0),
                                                                              child: Container(
                                                                                width: MediaQuery.of(context).size.width/1.5,
                                                                                child: Text(
                                                                                  '$location',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 2,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  'Phone Number : ',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                Text(
                                                                                  '$contact',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  'SAP Number : ',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                Text(
                                                                                  '$sap_no',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  'Ledger: ',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                Text(
                                                                                  'Rs.$ledger',
                                                                                  style: GoogleFonts.montserrat(
                                                                                      fontStyle: FontStyle.normal,
                                                                                      color: Color(0xff12283D),
                                                                                      fontSize: 16),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context); // Close the dialog
                                                                        },
                                                                        child: Text('OK'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,  // Set the color of the divider
                                    height: 20,           // Set the height of the divider
                                    thickness: 2,          // Set the thickness of the divider
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Add your button press logic here
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 4.0,
                                            primary: Constants.secondary_color, // Set the button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0), // Set your preferred border radius here
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(FluentIcons.arrow_download_16_filled, color: Colors.white), // Download icon
                                              SizedBox(width: 8.0), // Add some space between icon and text
                                              Text(
                                                'Download Ledger',
                                                style: TextStyle(color: Colors.white),
                                              ), // Button text
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id:dealer_id)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 4.0,
                                            backgroundColor: Constants.secondary_color,// Set the button color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0), // Set your preferred border radius here
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Stock Reconcile',style: TextStyle(color: Colors.white)),// Button text
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                  }
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
                    label: 'Orders',
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
