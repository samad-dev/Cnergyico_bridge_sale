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

class StockReconcilePage extends StatefulWidget {
  final String dealer_id;

  const StockReconcilePage({Key? key, required this.dealer_id}) : super(key: key);

  @override
  _StockReconcilePageState createState() => _StockReconcilePageState(dealer_id);
}

class _StockReconcilePageState extends State<StockReconcilePage> {
  final String dealer_id;

  _StockReconcilePageState(this.dealer_id);

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData1 = [];
  String number_of_nozzel= "0";
  String number_of_Tank= "0";
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    get_dealer_nozzles(dealer_id);
    get_dealer_Tank(dealer_id);
  }

  Future<List<Map<String, dynamic>>> get_dealer_nozzles(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_dealers_nozels.php?key=03201232927&dealer_id=$dealerId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData = List<Map<String, dynamic>>.from(data);
          number_of_nozzel= filteredData[filteredData.length - 1]["no_of_nozel"];
        });
        return resultList;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<List<Map<String, dynamic>>> get_dealer_Tank(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealerId';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData1 = List<Map<String, dynamic>>.from(data);
          number_of_Tank = "${filteredData1.length}";
        });
        return resultList;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<void> sendReconciliationData(String id, String oldReading, String newReading, String product) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/create/dealers_reconcilation.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id': '$user_id',
          'nozle_id': '$id',
          'product_id': '$product',
          'old_reading': oldReading.isNotEmpty ? oldReading : '0',
          'new_reading': newReading,
          'row_id': '',
        },
      );

      if (response.statusCode == 200) {
        // Handle success, if needed
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TaskDashboard()), // Replace OutletsPage with the actual page you want to navigate to
        );
        print('Data sent successfully');
        Fluttertoast.showToast(
          msg: 'Data sent successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // You can navigate back to the previous page here if needed
        // Navigator.of(context).pop();
      } else {
        // Handle errors, if needed
        print('Failed to send data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, if needed
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }


  void printReadingControllersValues() {
    if (checkNullReadings()) {
      bool allReadingsValid = true;

      for (int index = 0; index < readingControllers.length; index++) {
        String oldReading = filteredData[index]['new_reading'] ?? '0';
        String newReading = readingControllers[index].text;

        if (double.parse(newReading) < double.parse(oldReading)) {
          allReadingsValid = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid Reading'),
                content: Text('New reading cannot be smaller than the old reading for Nozzle ${index + 1}'),
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
          break; // Break out of the loop if any reading is invalid
        }
      }

      if (allReadingsValid) {
        // If all readings are valid, proceed to post data
        for (int index = 0; index < readingControllers.length; index++) {
          String oldReading = filteredData[index]['new_reading'] ?? '0';
          String newReading = readingControllers[index].text;

          sendReconciliationData(
            filteredData[index]['id'],
            oldReading,
            newReading,
            filteredData[index]['products'],
          );
        }
      }
    }
  }
  bool checkNullReadings() {
    for (int index = 0; index < readingControllers.length; index++) {
      if (readingControllers[index].text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Missing Reading'),
              content: Text('Reading of Nozzle ${index+1} is not taken. Please take its reading.'),
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
        return false; // Stop checking if one null reading is found
      }
    }
    return true; // All readings are non-empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Stock Reconcile',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      // Total Nozzles Card
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: Color(0xff3a833c),
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
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Nozzles',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xffffffff),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    ' $number_of_nozzel Nozzle',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xffc7c7c7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  OutlinedButton(
                                    child: Text(
                                      'View Reading',
                                      style: GoogleFonts.montserrat(
                                        color: Color(0xffc7c7c7),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          width: 1.0, color: Color(0xd5e0e0e0)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      // Total Tanks Card
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: Color(0xff3a833c),
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
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Tanks',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xffffffff),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '$number_of_Tank Tank',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xffc7c7c7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  OutlinedButton(
                                    child: Text(
                                      'View Dips',
                                      style: GoogleFonts.montserrat(
                                        color: Color(0xffc7c7c7),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
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
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StockReconcileTankPage(dealer_id: dealer_id)));
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: filteredData.length,
                  itemBuilder: (BuildContext context, int index2) {
                    if (filteredData.isNotEmpty && index2 < filteredData.length) {
                      final TextEditingController controller =
                      readingControllers.length > index2
                          ? readingControllers[index2]
                          : TextEditingController();
                      if (readingControllers.length <= index2) {
                        readingControllers.add(controller);
                      }

                      final id = filteredData[index2]['id'];
                      final name = filteredData[index2]['name'];
                      final no_of_nozzle = filteredData[index2]['no_of_nozzle'];
                      final products = filteredData[index2]["products"];
                      final product_name = filteredData[index2]["product_name"];
                      final created_by = filteredData[index2]["created_by"];
                      final old_reading =
                      filteredData[index2]["new_reading"] == null ? '0' : filteredData[index2]["new_reading"];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
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
                                      "Nozzle ${index2+1}: $product_name",
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
                                SizedBox(height: 10,),
                                Text(
                                  "Recent Reading: $old_reading ltr.",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w200,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 15,),
                                TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Current Reading',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    hintText: 'Enter current Reading',
                                  ),
                                  onChanged: (value) {
                                    print('Current Reading: $value');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                SizedBox(
                  height: 25,
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
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () {
                    printReadingControllersValues();
                  },
                  child: isLoading
                      ? CircularProgressIndicator() // Show loader
                      : Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
