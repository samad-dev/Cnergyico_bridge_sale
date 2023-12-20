import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hascol_inspection/screens/Measurement&Pricing.dart';
import 'package:hascol_inspection/screens/StockVariation.dart';
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'package:hascol_inspection/screens/stock_reconcile_Tank.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import '../utils/constants.dart';
import 'SalesPerformance.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'inspection.dart';


class TaskDashboard extends StatefulWidget {
  final String? dealer_id;
  final String? inspectionid;
  final String? dealer_name;

  const TaskDashboard({Key? key, this.dealer_id, this.inspectionid,this.dealer_name}) : super(key: key);
  @override
  TaskDashboardState createState() => TaskDashboardState(dealer_id!,inspectionid,dealer_name);
}

class TaskDashboardState extends State<TaskDashboard> {
  final String dealer_id;
  final String? inspectionid;
  final String? dealer_name;
  TaskDashboardState(this.dealer_id,this.inspectionid,this.dealer_name);

  @override
  void initState() {
    super.initState();
    fetchData(dealer_id);
  }

  List<Map<String, String>> resultList = [];
  int zeroCount = 0;
  int oneCount = 0;
  TextEditingController commentController = TextEditingController();
  late String signatureImagePath;

  Future<List<Map<String, String>>> fetchData(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_dealers_inspections.php?key=03201232927&id=$dealerId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
          resultList.add({
            'Sales Status': data[0]['sales_status'],
            'Measurement Status': data[0]['measurement_status'],
            'Wet Stock Status': data[0]['wet_stock_status'],
            'Dispensing Status': data[0]['dispensing_status'],
            'Stock Variations Status': data[0]['stock_variations_status'],
            'Inspection': data[0]['inspection'],
          });
          List<String> keys = resultList[0].keys.cast<String>().toList();
          oneCount = resultList[0].values.where((value) => value == '1').length;
          zeroCount= resultList[0].values.where((value) => value == '0').length;
          print("hellow world: $resultList");
          print("Number of Status: ${keys.length}");
      });
      return resultList;
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> postSignatureImages(String dealerSignaturePath, String representerSignaturePath) async {
    String apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/task_response.php';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Use null-aware operator to provide a default value if 'Id' is null
    var id = prefs.getString("Id") ?? '';

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the dealer signature image file
      request.files.add(await http.MultipartFile.fromPath('dealer_sign', dealerSignaturePath));

      // Add the representer signature image file
      request.files.add(await http.MultipartFile.fromPath('representator_sign', dealerSignaturePath));

      // Add the postData fields
      request.fields.addAll({
        'user_id': id,
        'task_id': widget.inspectionid ?? '', // Provide a default value if null
        'row_id': '',
        'status': '1',
        'description': commentController.text.toString(),
      });

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Signatures and postData posted successfully');
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
        print('Failed to post signatures and postData. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception while posting signatures and postData: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenWidth / 2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Puma_Background.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width/10,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          // Navigate back to the home page
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$dealer_name",
                      style: TextStyle(
                        color: Colors.black, // Text color on top of the image
                        fontSize: 20.0, // Adjust the font size as needed
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Constants.secondary_color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          color:  Colors.white.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '6',
                                      style: TextStyle(
                                        color:Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total Tasks',
                                      style: TextStyle(
                                        color:Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width/27,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$oneCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Completed',
                                      style: TextStyle(
                                        color:Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width/27,
                                      ),
                                    ),
                                  ],
                                ),
                                // Add any other content for the "Tasks Completed" card
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$zeroCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width/27,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        color:Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                // Add any other content for the "Remaining Tasks" card
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    if (resultList.isNotEmpty && resultList[0]['Sales Status'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    }
                                    else {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SalesPerformance(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!,)));
                                    }
                                    },
                                  child: Card(
                                    elevation: 10.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Sales Status'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white, // Change card color based on Measurement Status
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/performance-award.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Sales Status'] == '1'
                                                ? Colors.white
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Sales',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Sales Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                Text(
                                                  'Performance',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Sales Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Check if Measurement Status is 1
                                    if (resultList.isNotEmpty && resultList[0]['Measurement Status'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    } else {
                                      // Measurement Status is not 1, navigate to MPricing
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MPricing(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!,),));
                                    }
                                  },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Measurement Status'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white, // Change color based on Measurement Status
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/efficiency.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Measurement Status'] == '1'
                                                ? Colors.white
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Measurement',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width / 27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Measurement Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                Text(
                                                  '& Pricing',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width / 27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Measurement Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    if (resultList.isNotEmpty && resultList[0]['Wet Stock Status'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    }
                                    else {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => StockReconcileTankPage(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!)));
                                    }
                                    },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Wet Stock Status'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white, // Change card color based on Measurement Status
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/oil-tank.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Wet Stock Status'] == '1'
                                                ? Colors.white
                                                : null, // Set color to white if Measurement Status is 1
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Wet Stock',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Wet Stock Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                Text(
                                                  'Management',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Wet Stock Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    if (resultList.isNotEmpty && resultList[0]['Dispensing Status'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    }
                                    else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!)),
                                      );
                                    }
                                    },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Dispensing Status'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white, // Change card color based on Measurement Status
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/electric-meter.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Dispensing Status'] == '1'
                                                ? Colors.white
                                                : null, // Set color to white if Measurement Status is 1
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Dispensing Unit',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Dispensing Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                Text(
                                                  'Meter Reading',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                    color: resultList.isNotEmpty && resultList[0]['Dispensing Status'] == '1'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Stock Variations Status'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/report.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Stock Variations Status'] == '1'
                                                ? Colors.white
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              'Stock Variation',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width/27,
                                                fontWeight: FontWeight.bold,
                                                color: resultList.isNotEmpty && resultList[0]['Stock Variations Status'] == '1'
                                                    ? Colors.white
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: (){
                                    if (resultList.isNotEmpty && resultList[0]['Stock Variations Status'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    }
                                    else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  StockVariation(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!)),
                                      );
                                    }

                                  },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap:(){
                                    if (resultList.isNotEmpty && resultList[0]['Inspection'] == '1') {
                                      print('Measurement Status is 1, action not allowed');
                                    }
                                    else {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => Inspection(dealer_id: dealer_id,inspectionid: inspectionid!,dealer_name: dealer_name!)),);
                                    }
                                  },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: resultList.isNotEmpty && resultList[0]['Inspection'] == '1'
                                        ? Constants.secondary_color
                                        : Colors.white, // Change card color based on Measurement Status
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/inspection.png',
                                            height: 50.0,
                                            color: resultList.isNotEmpty && resultList[0]['Inspection'] == '1'
                                                ? Colors.white
                                                : null, // Set color to white if Measurement Status is 1
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              'Inspection',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width/27,
                                                fontWeight: FontWeight.bold,
                                                color: resultList.isNotEmpty && resultList[0]['Inspection'] == '1'
                                                    ? Colors.white
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width/1.8, // Half of the screen width
                            height: 45,
                            child: TextButton(
                              onPressed: () {
                                if (oneCount == 6) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      SignatureController _controller = SignatureController(
                                        penStrokeWidth: 5,
                                        penColor: Colors.black,
                                        exportBackgroundColor: Colors.white,
                                      );
                                      return AlertDialog(
                                        title: Text('Conclusion'),
                                        content: Container(
                                          height: MediaQuery.of(context).size.width/1.2,
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: [
                                              TextField(
                                                controller: commentController,
                                                decoration: InputDecoration(
                                                  labelText: 'Description',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                ),
                                                maxLines: 2,
                                                minLines: 1,
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Text('Dealer Signature:'),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                height: MediaQuery.of(context).size.width/2, // Adjust the height as needed
                                                child: Signature(
                                                  controller: _controller,
                                                  height: 200, // Adjust the height as needed
                                                  width: MediaQuery.of(context).size.width,
                                                  backgroundColor: Colors.grey,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              _controller.clear();
                                            },
                                            child: Text('Clear'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Get the cache directory
                                              final directory = await getTemporaryDirectory();
                                              // Generate a unique file name
                                              final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
                                              // Combine the directory path and file name
                                              final filePath = '${directory.path}/$fileName';
                                              // Convert the signature to an image
                                              final Uint8List? pngBytes = await _controller.toPngBytes();
                                              if (pngBytes != null) {
                                                final img.Image? image = img.decodePng(pngBytes);
                                                // Save the image to the cache directory
                                                File(filePath).writeAsBytesSync(img.encodePng(image!));
                                                // Store the file path in the variable
                                                setState(() {
                                                  signatureImagePath = filePath;
                                                });
                                                print('Image path: $signatureImagePath');
                                                await postSignatureImages(signatureImagePath, signatureImagePath);
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                                              }
                                            },
                                            child: Text('Submit'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Please fill all form.'),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
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
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}