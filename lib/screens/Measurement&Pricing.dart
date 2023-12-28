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

class MPricing extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  const MPricing({Key? key, required this.dealer_id,required this.inspectionid, required this.dealer_name}) : super(key: key);
  @override
  MPricingState createState() => MPricingState(dealer_id,inspectionid,dealer_name);
}

class MPricingState extends State<MPricing> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;

  MPricingState(this.dealer_id, this.inspectionid, this.dealer_name);

  final TextEditingController appreciationController = TextEditingController();
  final TextEditingController measuresController = TextEditingController();
  final TextEditingController warningController = TextEditingController();
  final TextEditingController ograPmgController = TextEditingController();
  final TextEditingController ograHsdController = TextEditingController();
  final TextEditingController pumpPmgController = TextEditingController();
  final TextEditingController pumpHsdController = TextEditingController();
  final TextEditingController variancePmgController = TextEditingController();
  final TextEditingController varianceHsdController = TextEditingController();

  bool isLoading = false;
  List<dynamic> dealersData = [];
  List<Map<String, dynamic>> dispenserDataList = [];
  int dispenserNum = 0;
  int nozzelNum = 1;

  @override
  void initState() {
    super.initState();
    fetchData(dealer_id);
  }



  Future<void> fetchData(dealer_id) async {
    final String apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealer_id';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        dealersData = json.decode(response.body);
        dispenserDataList = List.generate(dealersData.length, (index) => {});
      });
    } else {
      throw Exception('Failed to load data');
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
          'table_name':'measurement_status'
        },
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
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
  Future<void> send_MPData() async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/create/dealers_inspection_measurement_pricing.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'dealer_id':dealer_id,
          'row_id': '',
          'appreation': appreciationController.text.toString(),
          'measure_taken': measuresController.text.toString(),
          'warning': warningController.text.toString(),
          'pmg_ogra_price': ograPmgController.text.toString(),
          'pmg_pump_price': pumpPmgController.text.toString(),
          'pmg_variance': variancePmgController.text.toString(),
          'hsd_ogra_price': ograHsdController.text.toString(),
          'hsd_pump_price': pumpHsdController.text.toString(),
          'hsd_variance': varianceHsdController.text.toString(),
          'dispenser_measre': json.encode(dispenserDataList),
          'user_id': '$user_id',
          'task_id': inspectionid,
        },
      );
      if (response.statusCode == 200) {
        sendstatus();
      } else {
        // Handle errors, if needed
        print('Failed to send data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, if needed
      print('Error: $e');
    }
  }
  bool validateFields() {
    if (appreciationController.text.isEmpty ||
        measuresController.text.isEmpty ||
        warningController.text.isEmpty ||
        ograPmgController.text.isEmpty ||
        ograHsdController.text.isEmpty ||
        pumpPmgController.text.isEmpty ||
        pumpHsdController.text.isEmpty ||
        variancePmgController.text.isEmpty ||
        varianceHsdController.text.isEmpty) {
      // Display an error message or handle it in any way you prefer
      Fluttertoast.showToast(
        msg: 'Please fill in all the fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    for (int index = 0; index < dealersData.length; index++) {
      if (dealersData[index]['nozels'] != null && dealersData[index]['nozels'].isNotEmpty)
        if (dispenserDataList[index]['pmg_accurate'] == null ||
          dispenserDataList[index]['pmg_shortage'] == null ||
          dispenserDataList[index]['hsd_accurate'] == null ||
          dispenserDataList[index]['hsd_shortage'] == null) {
        Fluttertoast.showToast(
          msg: 'Please fill in all fields',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }
    return true;
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Measurement & Pricing',
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
                          if (dealerData['nozels'] != null && dealerData['nozels'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PMG: "),
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        //controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Accurate (Y/N)',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                          onChanged: (value) {
                                            // Update the corresponding data in the list
                                            dispenserDataList[index]['dispenser_id'] = dealerData['id'];
                                            dispenserDataList[index]['pmg_accurate'] = value;
                                          }
                                      ),
                                    ),
                                    SizedBox(width: 10), // Adjust the spacing between text fields
                                    Expanded(
                                      child: TextField(
                                        //controller: controller,
                                        decoration: InputDecoration(
                                          labelText: 'Shortage %',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                          onChanged: (value) {
                                            // Update the corresponding data in the list
                                            dispenserDataList[index]['pmg_shortage'] = value;
                                          }
                                      ),
                                    ),
                                  ],
                                  ),
                                  SizedBox(
                                      height: 10
                                  ),
                                  Text("HSD: "),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          //controller: controller,
                                          decoration: InputDecoration(
                                            labelText: 'Accurate (Y/N)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                            onChanged: (value) {
                                              // Update the corresponding data in the list
                                              dispenserDataList[index]['hsd_accurate'] = value;
                                            }
                                        ),
                                      ),
                                      SizedBox(width: 10), // Adjust the spacing between text fields
                                      Expanded(
                                        child: TextField(
                                          //controller: controller,
                                          decoration: InputDecoration(
                                            labelText: 'Shortage %',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                            onChanged: (value) {
                                              // Update the corresponding data in the list
                                              dispenserDataList[index]['hsd_shortage'] = value;
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 10
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: appreciationController,
                          decoration: InputDecoration(
                            labelText: 'Appreciation of the dealer if Correct:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: measuresController,
                          decoration: InputDecoration(
                            labelText: 'Measures taken to overcome shortage',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: warningController,
                          decoration: InputDecoration(
                            labelText: 'Warning:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text("OGRA Price:"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ograPmgController,
                                decoration: InputDecoration(
                                  labelText: 'PMG',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Adjust the spacing between text fields
                            Expanded(
                              child: TextField(
                                controller: ograHsdController,
                                decoration: InputDecoration(
                                  labelText: 'HSD',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text("Pump Price:"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: pumpPmgController,
                                decoration: InputDecoration(
                                  labelText: 'PMG',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Adjust the spacing between text fields
                            Expanded(
                              child: TextField(
                                controller: pumpHsdController,
                                decoration: InputDecoration(
                                  labelText: 'HSD',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text("Variance:"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: variancePmgController,
                                decoration: InputDecoration(
                                  labelText: 'PMG',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Adjust the spacing between text fields
                            Expanded(
                              child: TextField(
                                controller: varianceHsdController,
                                decoration: InputDecoration(
                                  labelText: 'HSD',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () {
                    print("hellow world 1: $dispenserDataList");
                    if (validateFields()) {
                      send_MPData();
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
