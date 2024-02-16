import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Task_Dashboard.dart';
import 'package:hascol_inspection/screens/stock_reconcile_Tank.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'Drawer/outlets_list.dart';

class StockVariation extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;

  const StockVariation({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name}) : super(key: key);
  @override
  StockVariationState createState() => StockVariationState(dealer_id,inspectionid,dealer_name);
}

class StockVariationState extends State<StockVariation> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;

  StockVariationState(this.dealer_id, this.inspectionid, this.dealer_name);
  
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> filteredData = [];
  List<int> hsdValues = [0,0,0,0,0,0,0];
  List<int> pmgValues = [0,0,0,0,0,0,0];
  bool hasHSD = false; // Set to false if the user doesn't have HSD
  bool hasPMG = false; // Set to false if the user doesn't have PMG
  String PMGID = '';
  String HSDID = '';


  @override
  void initState() {
    super.initState();
    TargetSales(dealer_id);
  }

  Future<void> DealerStockVariations(List<int> numbers, String product_id) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    int total_product_available_for_sale = (numbers[0]+numbers[1]);
    int book_stock = (total_product_available_for_sale - numbers[3]);
    int gain_loss = (numbers[5] - book_stock);

    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/create_dealer_stock_variations.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id': '$user_id',
          'dealer_id': dealer_id,
          'product_id': product_id,
          'row_id': '',
          'opening_stock':'${numbers[0]}',
          'purchase_during_inspection_period':'${numbers[1]}',
          'total_product_available_for_sale':'$total_product_available_for_sale',
          'sales_as_per_meter_reading':'${numbers[3]}',
          'book_stock':'$book_stock',
          'current_physical_stock':'${numbers[5]}',
          'gain_loss':'$gain_loss',
          'task_id':inspectionid
        },
      );

      if (response.statusCode == 200) {
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
    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_inspections_status.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'task_id':'$inspectionid',
          'row_id': '',
          'table_name':'stock_variations_status'
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
  Future<void> printReadingControllersValues() async {
      if (hasHSD)
        await DealerStockVariations(
          hsdValues, HSDID
        );
      if (hasPMG)
        await DealerStockVariations(
            pmgValues, PMGID
        );
      sendstatus();
  }

  Future<List<Map<String, dynamic>>> TargetSales(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealer_monthly_target.php?key=03201232927&dealer_id=$dealerId';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData = List<Map<String, dynamic>>.from(data);
          for (int index = 0; index < filteredData.length; index++) {
            if(filteredData[index]['name']=='PMG'){
              hasPMG = true;
              PMGID=filteredData[index]['product_id'];
            }
            if(filteredData[index]['name']=='HSD'){
              hasHSD = true;
              HSDID=filteredData[index]['product_id'];
            }
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        elevation: 20.0,
        title: Text(
          'Stock Variation',
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
                        SizedBox(height: 10,),
                        Text(
                          'Opening Stock (Total of all tanks)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    hsdValues[0] = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    pmgValues[0] = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Purchases during inspection period',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    hsdValues[1] = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    pmgValues[1] = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Product available for sale',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (hsdValues[0] + hsdValues[1]).toString(),),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (pmgValues[0] + pmgValues[1]).toString(),),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sales as per Meter Reading (Nozzle Sale)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                  setState(() {
                                    hsdValues[3] = int.tryParse(value) ?? 0;
                                    hsdValues[2] = (hsdValues[0]+hsdValues[1]);
                                    print(hsdValues);
                                  });
                                  },
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                  setState(() {
                                    pmgValues[3] = int.tryParse(value) ?? 0;
                                    pmgValues[2] = (pmgValues[0]+pmgValues[1]);
                                    print(pmgValues);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Book Stock',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (hsdValues[2] - hsdValues[3]).toString(),),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (pmgValues[2] - pmgValues[3]).toString(),),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Current Physical Stock',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                  setState(()
                                  {
                                    hsdValues[5] = int.tryParse(value) ?? 0;
                                    hsdValues[4] = (hsdValues[2]-hsdValues[3]);
                                    print(hsdValues);
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                  setState(()
                                  {
                                    pmgValues[5] = int.tryParse(value) ?? 0;
                                    pmgValues[4] = (pmgValues[2]-pmgValues[3]);
                                    print(pmgValues);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Gain/Loss',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHSD)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'HSD'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (hsdValues[5] - hsdValues[4]).toString(),),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (hasPMG)
                              Expanded(
                              child: TextField(
                                decoration: InputDecoration(labelText: 'PMG'),
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController(text: (pmgValues[5] - pmgValues[4]).toString(),),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
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
                    printReadingControllersValues();
                  },
                  child: isLoading
                      ? CircularProgressIndicator() // Show loader
                      : Text('Submit',style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
