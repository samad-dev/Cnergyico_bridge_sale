import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/constants.dart';
import 'Task_Dashboard.dart';

class MPricing extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const MPricing({
    Key? key,
    required this.dealer_id,
    required this.inspectionid,
    required this.dealer_name,
    required this.formId,
  }) : super(key: key);

  @override
  MPricingState createState() =>
      MPricingState(dealer_id, inspectionid, dealer_name, formId);
}

class MPricingState extends State<MPricing> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  MPricingState(this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  bool isLoading = false;
  List<Map<String, dynamic>> productsDataList = [];

  @override
  void initState() {
    super.initState();
    fetchUniqueNames(dealer_id).then((result) {
      setState(() {
        productsDataList = result;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchUniqueNames(String dealerId) async {
    final apiUrl =
        "http://151.106.17.246:8080/bycobridgeApis/get/dealers_products.php?key=03201232927&dealer_id=$dealerId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> productsDataList = [];

        for (var item in data) {
          if (item.containsKey("name")) {
            String name = item["name"];
            String product_id = item["product_id"];

            // Create a map for each product with name and corresponding text controllers
            Map<String, dynamic> productData = {

              'name': name,
              'product_id':product_id,
              'ograPmgController': TextEditingController(),
              'pumpPmgController': TextEditingController(),
              'variancePmgController': TextEditingController(),
            };

            productsDataList.add(productData);
          }
        }

        return productsDataList;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<void> postProductData(List<Map<String, dynamic>> productsDataList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var dpt_id = prefs.getString("department_id");
    const apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/dealer_inspection_price_check.php';

    for (var productData in productsDataList) {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add your common fields
      request.fields.addAll({
        'user_id': '$user_id',
        'task_id': inspectionid,
        'form_id': formId,
        'dpt_id': '$dpt_id',
        'dealer_id': dealer_id,
        // Add specific fields for each product
        'product_id': productData['product_id'],
        'ogra_price': productData['ograPmgController'].text,
        'pump_price': productData['pumpPmgController'].text,
        'variance': productData['variancePmgController'].text,
        'row_id': '',
      });

      // Send the POST request
      try {
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('Product ${productData['name']} posted successfully.');
          print(await response.stream.bytesToString());
        } else {
          print('Failed to post data for product ${productData['name']}: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error posting data for product ${productData['name']}: $e');
      }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pricing',
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
        backgroundColor: Constants.primary_color, // Set your desired color
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                // Loop through productsDataList to create TextFields
                for (var productData in productsDataList)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text("${productData['name']}"),
                          // Create TextField for OGRA PMG Price
                          TextField(
                            controller: productData['ograPmgController'],
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'OGRA Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            controller: productData['pumpPmgController'],
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Pump Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            controller: productData['variancePmgController'],
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Variance',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    bool allFieldsFilled = true;

                    for (var productData in productsDataList) {
                      if (productData['ograPmgController'].text.isEmpty ||
                          productData['pumpPmgController'].text.isEmpty ||
                          productData['variancePmgController'].text.isEmpty) {
                        allFieldsFilled = false;
                        break;
                      }
                    }

                    if (allFieldsFilled) {
                      // Await the completion of postProductData before moving on
                      await postProductData(productsDataList);

                      // Await the completion of poststaus before navigating and showing toast
                      await poststaus();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TaskDashboard(
                            dealer_id: dealer_id,
                            inspectionid: inspectionid,
                            dealer_name: dealer_name,
                          ),
                        ),
                      );

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
                      print("Please fill in all fields.");
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.secondary_color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}