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

class Create_Order extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _CreateOrderState createState() => _CreateOrderState();
}

class _CreateOrderState extends State<Create_Order> {
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
          'Create Order',
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
            Card(
              color: Color(0xffF0F0F0),
              elevation: 15,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //CircleAvatar
                      const SizedBox(
                        height: 10,
                      ), //SizedBox
                      Text(
                        'Account Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xff000000),
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                        ),
                      ), //Text
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: Color(0xff12283D),
                              radius: 15,
                              child: Icon(
                                FontAwesomeIcons.cableCar,
                                color: Colors.white,
                                size: 15,
                              ) //Text
                              ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3,75,000 Rs.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'Updated On : ${formattedDate}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Color(0xff8A8A8A),
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ), //Column
                ),
              ), //SizedBox,
            ),
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
                        hintText: 'Quantity for HSD',
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
                        labelText: 'HSD',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "x",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hsd.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "=",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hsdt.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 13,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 150,
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        print(value);
                        setState(() {
                          hobct = int.parse(value) * 330;
                        });
                      },
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
                        hintText: 'Quantity for HOBC',
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
                        labelText: 'HOBC',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "x",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hobc.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "=",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hobct.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 13,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 150,
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        print(value);
                        setState(() {
                          pmgt = int.parse(value) * 332;
                        });
                      },
                      controller: pmgController,
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
                        hintText: 'Quantity for PMG',
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
                        labelText: 'PMG',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "x",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pmg.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "=",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pmgt.toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                    color: Color(0xff12283d),
                    style: BorderStyle.solid,
                    width: 0.80),
              ),
              child: DropdownButton(
                underline: Container(), //remove underline
                isExpanded: true,
                icon: Padding( //Icon at tail, arrow bottom is default icon
                    padding: EdgeInsets.only(left:20),
                    child:Icon(Icons.arrow_circle_down_sharp)
                ),
                iconEnabledColor: Color(0xff12283d),
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13),
                items: data.map((item) {
                  return DropdownMenuItem(
                    child: new Text(item['consignee_name'],style: GoogleFonts.poppins(
                      color: Color(0xffa8a8a8),
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                    ),),
                    value: item['id'].toString(),
                  );
                }).toList(),
                onChanged: (String? newVal) {
                  setState(() {
                    _mySelection = newVal!;
                    // print(_mySelection);
                  });
                },
                value: _mySelection,
                hint: Text("Select Depot",style: GoogleFonts.poppins(
                  color: Color(0xff000000),
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title:  Text('Self',style:GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Color(0xff12283D),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),),

                    leading: Radio(
                      fillColor: MaterialStateProperty.all(Color(0xff12283D)),
                      overlayColor:  MaterialStateProperty.all(Color(0xff12283D)),
                      value: "Self",
                      groupValue: _site,
                      onChanged: (value) {
                        setState(() {
                          _site = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('GC / Coco',style:GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Color(0xff12283D),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),),
                    leading: Radio(
                      fillColor: MaterialStateProperty.all(Color(0xff12283D)),
                      overlayColor:  MaterialStateProperty.all(Color(0xff12283D)),
                      value: "GC / Coco",
                      groupValue: _site,
                      onChanged: (value) {
                        setState(() {
                          _site = value!;
                        });
                      },
                    ),
                  ),
                ),

              ],
            ),
            if (_site == "Self")
              TextFormField(
                controller: tlController,
                keyboardType: TextInputType.text,
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
                  hintText: 'TL #',
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Color(0xff3b5fe0)),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Color(0xffF1F4FF)),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: 'Enter TL #',
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: MaterialButton(
                onPressed: () {
                  var amount = hsdt + pmgt + hobct;
                },
                child: Text(
                  'Create Order',
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
