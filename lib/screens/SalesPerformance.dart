import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Task_Dashboard.dart';
import 'package:hascol_inspection/screens/stock_reconcile_Tank.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'outlets_list.dart';

class SalesPerformance extends StatefulWidget {
  @override
  SalesPerformanceState createState() => SalesPerformanceState();
}

class SalesPerformanceState extends State<SalesPerformance> {

  SalesPerformanceState();
  
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Sales Performances',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Color(0xff12283D),
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xff12283d),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                Card(
                  color: Color(0xffe8e8e8),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "PMG",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                color: Color(0xff12283D),
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.filter_alt_outlined),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text(
                          "Target for the Month: 7000",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w200,
                            fontStyle: FontStyle.normal,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          "Actual To Date: 4500",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w200,
                            fontStyle: FontStyle.normal,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          "Variances: ${7000-4500}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w200,
                            fontStyle: FontStyle.normal,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 15,),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Reason for Variation',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15
                ),
               
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4.0,
                    backgroundColor: Constants.secondary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: Size(200, 50), // Set your preferred width and height
                  ),
                  child: Text("Start"),
                  onPressed: (){
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
