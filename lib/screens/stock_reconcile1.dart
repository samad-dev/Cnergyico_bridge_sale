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
  final String inspectionid;
  final String dealer_name;

  const StockReconcilePage({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name}) : super(key: key);

  @override
  _StockReconcilePageState createState() => _StockReconcilePageState(dealer_id,inspectionid,dealer_name);
}

class _StockReconcilePageState extends State<StockReconcilePage> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;

  _StockReconcilePageState(this.dealer_id,this.inspectionid, this.dealer_name);

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData1 = [];
  List<Map<String, dynamic>> data = [];
  String number_of_nozzel= "0";
  String number_of_Tank= "0";
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> result = [];

  @override
  void initState() {
    super.initState();
    // get_dealer_nozzles(dealer_id);
    fetchData(dealer_id);
  }
  /*
  Future<List<Map<String, dynamic>>> get_dealer_nozzles(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealerId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData = List<Map<String, dynamic>>.from(data);
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
  */
  Future<List<Map<String, dynamic>>> fetchData(dealer_id) async {
    final String apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealer_id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> result = [];

        for (dynamic item in data) {
          result.add({
            'id': item['id'],
            'name': item['name'],
            'nozels': List<Map<String, dynamic>>.from(item['nozels'] ?? []), // Ensure 'nozels' is not null
          });
        }

        return result;
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data');
      }
    } catch (error) {
      // Handle any errors that might occur.
      print(error);
      throw Exception('Failed to load data');
    }
  }

  Future<void> sendReconciliationData(int index,String id, String oldReading, String newReading, String product) async {
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
          'nozle_id': id,
          'product_id': product,
          'old_reading': oldReading.isNotEmpty ? oldReading : '0',
          'new_reading': newReading,
          'row_id': '',
          'task_id':inspectionid,
          'dealer_id':dealer_id,
        },
      );

      if (response.statusCode == 200) {
        if(filteredData.length-1 == index){
          sendstatus();
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
  Future<void> sendstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/update_inspections_status.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'task_id':'$inspectionid',
          'row_id': '',
          'table_name':'dispensing_status'
        },
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: dealer_id,inspectionid: inspectionid,dealer_name: dealer_name)),);
        Fluttertoast.showToast(
          msg: 'Data sent successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
            index,
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
        backgroundColor: Constants.primary_color,
        title: Text(
          'Dispensing Unit Meter Reading',
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
            child: Column(
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: result.length,
                  itemBuilder: (BuildContext context, int index2) {
                    final item = data[index2];
                    if (data.isNotEmpty && index2 < item.length) {
                      final TextEditingController controller =
                      readingControllers.length > index2
                          ? readingControllers[index2]
                          : TextEditingController();
                      if (readingControllers.length <= index2) {
                        readingControllers.add(controller);
                      }

                      final id = data[index2]['id'];
                      final name = data[index2]['name'];
                      print("hellow dunya $id and $name");

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
                                      "DU$id : $name",
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
                    sendstatus();
                    printReadingControllersValues();
                  },
                  child: isLoading
                      ? CircularProgressIndicator() // Show loader
                      : Text('Submit',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
