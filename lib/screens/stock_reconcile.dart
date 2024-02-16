import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Task_Dashboard.dart';
import 'package:hascol_inspection/screens/stock_reconcile_Tank.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'Drawer/outlets_list.dart';

class StockReconcilePage extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const StockReconcilePage({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name, required this.formId}) : super(key: key);

  @override
  _StockReconcilePageState createState() => _StockReconcilePageState(dealer_id,inspectionid,dealer_name,formId);
}

class _StockReconcilePageState extends State<StockReconcilePage> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  _StockReconcilePageState(this.dealer_id,this.inspectionid, this.dealer_name, this.formId);

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData1 = [];
  List<Map<String, dynamic>> data = [];
  String number_of_nozzel= "0";
  String number_of_Tank= "0";
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> result = [];
  List<dynamic> dealersData = [];
  int dispenserNum = 0;
  int nozzelNum = 1;

  @override
  void initState() {
    super.initState();
    fetchData(dealer_id);
  }
  Future<void> fetchData(dealer_id) async {
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealer_id';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        dealersData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> sendReconciliationData(int index,String id, String oldReading, String newReading, String product, String dispenser_id) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/dealers_reconcilation.php';

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
          'dispenser_id':dispenser_id,
        },
      );

      if (response.statusCode == 200) {
        print("data send sucessfully");
        if(dealersData.length-1 == index){
          poststaus();
          print("api hit");
        }else if(dealersData.length-2 == index){
          if(dealersData[index+1]['nozels']==null || dealersData[index+1]['nozels'].isEmpty) {
            poststaus();
            print("api hit");
          }
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
  Future<void> poststaus() async {
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php';
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php'));
    request.fields.addAll({
      'task_id': inspectionid,
      'form_id': "$formId",
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.of(context).pushReplacement(
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
    }
    else {
      print(response.reasonPhrase);
    }
  }
  Future<void> printNozzleValues() async {
    int nozzleIndex = 0; // Track the overall nozzle index
    bool readingIssueDetected = false; // Flag to track if any reading issue is detected

    for (int index = 0; index < dealersData.length; index++) {
      final dealerData = dealersData[index];

      if (dealerData['nozels'] != null && dealerData['nozels'].isNotEmpty) {
        print('DU${index + 1}: ${dealerData['name']}');

        for (int i = 0; i < dealerData['nozels'].length; i++) {
          final nozzle = dealerData['nozels'][i];
          String nozzleName = nozzle['product_name'];
          TextEditingController controller = readingControllers[nozzleIndex];
          String reading = controller.text;

          // Check if the reading controller has a value
          if (reading == null || reading.isEmpty) {
            if (!readingIssueDetected) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Missing Reading'),
                    content: Text('DU${index + 1} Nozzle${i + 1}: $nozzleName, Reading: Not available'),
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
            print('Nozzle${i + 1}: $nozzleName, Reading: Not available');
            readingIssueDetected = true; // Set the flag to true
          } else {
            // Check if the reading is greater than or equal to the nozzle's new_reading
            double nozzleNewReading = double.parse(nozzle['new_reading'] ?? '0');
            double controllerReading = double.parse(reading);

            if (controllerReading >= nozzleNewReading) {
              print('Nozzle${i + 1}: $nozzleName, Reading: $reading');
              sendReconciliationData(
                index,
                nozzle['id'],
                nozzleNewReading.toString(),
                controllerReading.toString(),
                nozzle['products'],
                nozzle['dispenser_id'],
              );
              //ERROR HERE
            } else {
              if (!readingIssueDetected) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Invalid Reading'),
                      content: Text('DU${index + 1} Nozzle${i + 1}: $nozzleName, Reading: Invalid (less than new reading)'),
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
                readingIssueDetected = true; // Set the flag to true
              }
              print('Nozzle${i + 1}: $nozzleName, Reading: Invalid (less than new reading)');
            }
          }
          nozzleIndex++; // Increment the overall nozzle index
          if (readingIssueDetected) {
            break;
          }
          if (index == dealersData.length - 1 && i == dealerData['nozels'].length - 1) {
            await poststaus();
          }
        }
      }
    }
  }

  Future<bool> validateReadings() async {
    for (int index = 0; index < dealersData.length; index++) {
      final dealerData = dealersData[index];

      if (dealerData['nozels'] != null && dealerData['nozels'].isNotEmpty) {
        for (int i = 0; i < dealerData['nozels'].length; i++) {
          final nozzle = dealerData['nozels'][i];
          TextEditingController controller = readingControllers[(index * dealerData['nozels'].length + i).toInt()];
          String reading = controller.text;

          // Check if the reading controller has a value
          if (reading == null || reading.isEmpty) {
            // If any reading is empty, return false
            return false;
          } else {
            // Check if the reading is greater than or equal to the nozzle's new_reading
            double nozzleNewReading = double.parse(nozzle['new_reading'] ?? '0');
            double controllerReading = double.parse(reading);

            if (controllerReading < nozzleNewReading) {
              // If any reading is less than the nozzle's new_reading, return false
              return false;
            }
          }
        }
      }
    }

    // If all readings are valid, return true
    return true;
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
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: dealersData.length,
                  itemBuilder: (context, index) {
                    final dealerData = dealersData[index];
                    dispenserNum =1;
                    nozzelNum = 1; // Reset for each dispenser

                    return Card(
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${dealerData['name']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (dealerData['nozels'] != null &&
                              dealerData['nozels'].isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Nozzles',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Column(
                                  children: dealerData['nozels'].map<Widget>((nozzle) {
                                    final TextEditingController controller =
                                    TextEditingController();
                                    readingControllers.add(controller);
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              'Nozzle${nozzelNum++}: ${nozzle['product_name']}',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              'Last Reading: ${NumberFormat.decimalPattern('en').format(double.parse(nozzle['new_reading'] ?? "0"))} ltr.',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Present Reading:',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                hintText: 'Enter reading ',
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
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
                      : () async {
                    // Validate all fields have values and are greater than last reading
                    bool isValid = await validateReadings();

                    if (isValid) {
                      printNozzleValues();
                    } else {
                      // If any validation fails, show an error message or handle it as needed
                      print('Invalid readings. Please check and try again.');
                    }
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
