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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
                        final location = filteredData[index2]['location'];
                        final contact = filteredData[index2]['contact'];
                        final sap_no = filteredData[index2]["sap_no"];
                        final name=filteredData[index2]["name"];
                        return Card(
                          elevation: 10,
                          color: Colors.white,//Color(0xffF0F0F0),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CircleAvatar(
                                          radius:
                                          28, // Adjust the size of the circular avatar
                                          backgroundColor: Color(0xffE7AD18),
                                          child: Image.asset(
                                            "assets/images/boss.png",
                                            width: 38,
                                            height: 38,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
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
                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffE7AD18),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(12.0), // Curved top left corner
                                                      bottomLeft: Radius.circular(12.0), // Curved bottom left corner
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text(
                                                      ' $sap_no ',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FontStyle.normal,
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width/1.55,
                                          child: Text(
                                            '$location',
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w200,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xff636465),
                                                fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          'ledger Balance: $ledger PKR.',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xff3B8D5A),
                                              fontSize: 12),
                                        ),
                                        Text(
                                          'Contact #: $contact',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xff9b9b9b),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Card(
                                        color: Color(0xffFFF3D4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            'In Progress',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xffE7AD18),
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Waiting For Approval',
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w300,
                                            fontStyle: FontStyle.normal,
                                            color: Color(0xff9b9b9b),
                                            fontSize: 12),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        height: 20,
                                        child: ElevatedButton(
                                          child: Text(
                                            'Shortage',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 11,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              primary: Color(0xff12283D),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              )),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  color: Colors.white54,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 30,),
                                                      Icon(
                                                        FontAwesomeIcons.cameraRetro,
                                                        color: Color(0xff12283d),
                                                        size: 160,
                                                      ),
                                                      Text(
                                                        'Click Here To Upload Photos',
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 16,
                                                          fontStyle: FontStyle.normal,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(18.0),
                                                        child: SizedBox(
                                                          height: 50,
                                                          child: TextFormField(

                                                            onFieldSubmitted: (value) {
                                                              print(value);

                                                            },
                                                            keyboardType: TextInputType.number,
                                                            style: GoogleFonts.poppins(
                                                              color: Color(0xffa8a8a8),
                                                              fontWeight: FontWeight.w300,
                                                              fontSize: 16,
                                                              fontStyle: FontStyle.normal,
                                                            ),
                                                            decoration: InputDecoration(
                                                              hintStyle: GoogleFonts.poppins(
                                                                color: Color(0xffa8a8a8),
                                                                fontWeight: FontWeight.w300,
                                                                fontSize: 16,
                                                                fontStyle: FontStyle.normal,
                                                              ),
                                                              labelStyle: GoogleFonts.poppins(
                                                                color: Color(0xffa8a8a8),
                                                                fontWeight: FontWeight.w300,
                                                                fontSize: 16,
                                                                fontStyle: FontStyle.normal,
                                                              ),
                                                              filled: true,
                                                              fillColor: Color(0xffF1F4FF),
                                                              hintText: 'Recieved',
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderSide:
                                                                  BorderSide(width: 2, color: Color(0xff3b5fe0)),
                                                                  borderRadius:
                                                                  BorderRadius.all(Radius.circular(10))),
                                                              border: OutlineInputBorder(
                                                                  borderSide:
                                                                  BorderSide(width: 2, color: Color(0xffF1F4FF)),
                                                                  borderRadius:
                                                                  BorderRadius.all(Radius.circular(10))),
                                                              labelText: 'Recieved Qty',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 20),
                                                        child: MaterialButton(
                                                          onPressed: () {

                                                          },
                                                          child: Text(
                                                            'Add Shortage',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily: 'SFUIDisplay',
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white),
                                                          ),
                                                          color: Color(0xff12283d),
                                                          elevation: 0,
                                                          minWidth: 350,
                                                          height: 60,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      TextButton.icon(
                                        // <-- TextButton
                                        onPressed: () {},
                                        icon: Icon(
                                          FluentIcons.drawer_arrow_download_24_regular,
                                          size: 16.0,
                                          color: Color(0xff12283D),
                                        ),
                                        label: Text(
                                          'Invoice',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xff12283D),
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  */
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
