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
import 'outlets_list.dart';

class Quantity_check extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const Quantity_check({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name,required this.formId}) : super(key: key);

  @override
  Quantity_checkState createState() => Quantity_checkState(dealer_id,inspectionid,dealer_name,formId);
}

class Quantity_checkState extends State<Quantity_check> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  Quantity_checkState(this.dealer_id,this.inspectionid, this.dealer_name, this.formId);

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData1 = [];
  List<Map<String, dynamic>> data = [];
  String number_of_nozzel= "0";
  String number_of_Tank= "0";
  List<TextEditingController> resultControllers = [];
  List<TextEditingController> totalControllers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> result = [];
  List<dynamic> dealersData = [];
  int dispenserNum = 0;
  int nozzelNum = 1;

  @override
  void initState() {
    super.initState();
    // get_dealer_nozzles(dealer_id);
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
          TextEditingController controller = resultControllers[nozzleIndex];
          String reading = controller.text;
          TextEditingController controller1 = totalControllers[nozzleIndex];
          String reading1 = controller1.text;

          // Check if the reading controller has a value
          if (reading1.isEmpty || reading.isEmpty) {
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
            double ResultReading = double.parse(reading);
            double TotalReading = double.parse(reading1);
            if(areAllFieldsFilled()==true) {
              sendReconciliationData(
                index,
                nozzle['id'],
                ResultReading.toString(),
                TotalReading.toString(),
                nozzle['products'],
                nozzle['dispenser_id'],
              );
            }
              print('Nozzle${i + 1}: $nozzleName, Reading: $reading, Reading1: $reading1 ');
          }
          nozzleIndex++; // Increment the overall nozzle index
          if (readingIssueDetected) {
            break;
          }
        }
      }
    }
  }
  Future<void> sendReconciliationData(int index,String id, String oldReading, String newReading, String product, String dispenser_id) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var dpt_id = prefs.getString("department_id");
    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/dealer_inspection_quantity_check.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id': '$user_id',
          'task_id': inspectionid,
          'dispenser_id':dispenser_id,
          'nozle_id': id,
          'form_id': formId,
          'dealer_id':dealer_id,
          'product_id': product,
          'result': oldReading.isNotEmpty ? oldReading : '0',
          'totalizer': newReading,
          'row_id': '',
          'dpt_id': '$dpt_id',
        },
      );

      if (response.statusCode == 200) {
        if(dealersData.length-1 == index){
          await poststaus();
          print("poststatus work");
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
        else if(lastDispenserHasNozzles() == false){
          if(dealersData.length-2 == index){
            await poststaus();
            print("poststatus work");
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
    }
    else {
      print(response.reasonPhrase);
    }
  }
  bool areAllFieldsFilled() {
    for (int i = 0; i < resultControllers.length; i++) {
      if (resultControllers[i].text.isEmpty || totalControllers[i].text.isEmpty) {
        // If any field is empty, return false
        return false;
      }
    }
    return true;
  }
  bool lastDispenserHasNozzles() {
    if (dealersData.isNotEmpty) {
      final lastDispenser = dealersData.last;
      return lastDispenser['nozels'] != null && lastDispenser['nozels'].isNotEmpty;
    }
    return false;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Quantity Check',
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
                    dispenserNum++;
                    nozzelNum = 1; // Reset for each dispenser

                    return Card(
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'DU${dispenserNum}: ${dealerData['name']}',
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
                                    final TextEditingController controller = TextEditingController();
                                    final TextEditingController controller1 = TextEditingController();
                                    resultControllers.add(controller);
                                    totalControllers.add(controller1);
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
                                            child: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Results:',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                hintText: 'Enter reading ',
                                              ),
                                              onChanged: (value) {
                                                print('Reading for Nozzle ${nozzle['id']}: $value');
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0 ,left: 8.0),
                                            child: TextField(
                                              controller: controller1,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Totalyzer:',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                hintText: 'Enter reading ',
                                              ),
                                              onChanged: (value) {
                                                print('Reading for Nozzle ${nozzle['id']}: $value');
                                              },
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
                      : () {
                    printNozzleValues();
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