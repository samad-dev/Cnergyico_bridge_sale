import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Create_Complaints extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _CreateComplaintState createState() => _CreateComplaintState();
}

class _CreateComplaintState extends State<Create_Complaints> {
  int hsd = 350;
  int hobc = 330;
  int pmg = 332;
  int hsdt = 0;
  int hobct = 0;
  int pmgt = 0;
  List data = [];
  String? _mySelection;
  TextEditingController hsdController = new TextEditingController();
  TextEditingController pmgController = new TextEditingController();
  TextEditingController hobcController = new TextEditingController();
  TextEditingController depotController = new TextEditingController();
  TextEditingController tlController = new TextEditingController();
  var _site = "Self";

  @override
  void initState() {
    super.initState();
    this.getDepot();
  }

  int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          //replace with our own icon data.
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Text(
          'Create Complaint',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Color(0xff12283D),
              fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 150,
                        child: TextFormField(

                          onTapOutside: (value) {
                            print(value);
                          },
                          controller: hsdController,
                          keyboardType: TextInputType.name,
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
                            hintText: 'First Name',
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
                            labelText: 'First Name',
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: 150,
                        child: TextFormField(
                          onFieldSubmitted: (value) {
                            print(value);
                            setState(() {
                              hsdt = int.parse(value) * 350;
                            });
                          },
                          onTapOutside: (value) {
                            print(value);
                          },
                          controller: hsdController,
                          keyboardType: TextInputType.name,
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
                            hintText: 'Last Name',
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
                            labelText: 'Last Name',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 13,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: hobcController,
                    keyboardType: TextInputType.emailAddress,
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
                      hintText: 'Email Address',
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
                      labelText: 'Email Address',
                    ),
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(

                    controller: hobcController,
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
                      hintText: 'Phone Number',
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
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(

                    controller: hobcController,
                    keyboardType: TextInputType.multiline,
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
                      hintText: 'Please Describe Briefly',
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
                      labelText: 'Please Describe Briefly',
                    ),
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: MaterialButton(
                    onPressed: () {
                      var amount = hsdt + pmgt + hobct;
                    },
                    child: Text(
                      'Create Complaint',
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
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<String> getDepot() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user_id = await sharedPreferences.getString("userId");
    var res = await http.get(Uri.parse(
        "http://151.106.17.246:8080/hascol/api/dealer_depot.php?accesskey=12345&user_id=3"));
    var resBody = json.decode(res.body);

    setState(() {
      data = resBody;
      print(data.length);
    });

    // print(data[0]["id"]);
    // print("Sapcode " + code.toString());

    return Future.value("Data download successfully");
  }
}
