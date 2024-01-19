import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'Task_Dashboard.dart';
import 'outlets_list.dart';
import 'package:intl/intl.dart';

class CasualVisitPage extends StatefulWidget {
  final String dealer_id;
  final String dealer_name;

  const CasualVisitPage({Key? key, required this.dealer_id, required this.dealer_name}) : super(key: key);

  @override
  CasualVisitPageState createState() => CasualVisitPageState(dealer_id,dealer_name);
}

class CasualVisitPageState extends State<CasualVisitPage> {
  final String dealer_id;
  final String dealer_name;

  CasualVisitPageState(this.dealer_id, this.dealer_name);

  String result='';
  TextEditingController _descriptionController = TextEditingController();

  Future<void> SendCasualVisit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_casual_visits.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id':'$user_id',
          'description':'${_descriptionController.text.toString()}',
          'dealer_id':'$dealer_id',
          'row_id': '',
        },
      );

      if (response.statusCode == 200) {
        result = response.body;
        print("result $result");
        if(result == "1") {
          print('Data sent successfully');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Outlets()),);
          Fluttertoast.showToast(
            msg: 'Data sent successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        // Handle errors, if needed
        print('Failed to send data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, if needed
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Casual Visit',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child:Column(
              children: [
                Card(
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dealer_name,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/2, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                  child: TextButton(
                    onPressed: () {
                      if (_descriptionController.text.isNotEmpty) {
                        SendCasualVisit();
                        print(_descriptionController.text.toString());
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: const Text('please give a Description'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0), // Adjust the value for curved border
                      ),
                      backgroundColor: Constants.secondary_color, // Background color
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontWeight: FontWeight.bold, // Bold text
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
