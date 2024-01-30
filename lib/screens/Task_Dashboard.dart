import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hascol_inspection/screens/Newform/NStockReconciliation.dart';
import 'package:hascol_inspection/screens/Pcc_Header.dart';
import 'package:hascol_inspection/screens/quality_check.dart';
import 'package:hascol_inspection/screens/quantity_check.dart';
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
import 'EHSForm.dart';
import 'Newform/FuelDecantationHeader.dart';
import 'Newform/OMC_VisitingForm.dart';
import 'Newform/Visit Report.dart';
import 'PCC.dart';
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
    fetchData(dealer_id, inspectionid!);
  }

  List<Map<String, String>> resultList = [];
  int zeroCount = 0;
  int oneCount = 0;
  int totalCount =0;
  TextEditingController commentController = TextEditingController();
  late String signatureImagePath;
  List<Map<String, dynamic>> formList = [];
  String? formId;

  Future<List<Map<String, dynamic>>> fetchData(String dealerId, String inspectionId) async {
    final apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_inspections.php?key=03201232927&id=$dealerId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      setState(() {
        // Clear the resultList before adding new items
        resultList.clear();

        for (int i = 0; i < data.length; i++) {
          // Check if the current item's inspection id matches the desired inspectionId
          if (data[i]['id'] == inspectionId) {

            // Parse "form_json" and convert it to the desired format
            List<dynamic> formJsonList = json.decode(data[i]['form_json']);
            for (var form in formJsonList) {
              formList.add({
                'form_id': form['form_id'],
                'form_name': form['form_name'],
                'status': form['status'].toString(),
              });
            }
          }
        }
        totalCount = formList.length;
        zeroCount = formList.where((form) => form['status'] == '0').length;
        oneCount = formList.where((form) => form['status'] == '1').length;

        print('Total Count: $totalCount');
        print('Zero Count: $zeroCount');
        print('One Count: $oneCount');
        print("form list: $formList");
        print(dealerId);
      });

      return resultList;
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> postSignatureImages(String dealerSignaturePath, String representerSignaturePath) async {
    String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/update/inspection/task_response.php';
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
  List<Widget> buildTaskCards(List<Map<String, dynamic>> apiResponse) {
    return apiResponse.map((task) {
      return GestureDetector(
        onTap: () {
          formId = task['form_id'];
          if (task['status'] != '1') {
            if (task['form_name'] == "Inspection") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Inspection(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId),),);
            }
            else if (task['form_name'] == "EHS Audit") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  EHSForm(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId),),);
            }
            else if (task['form_name'] == "PCC") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  PCCFormHeader(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId),),);
            }
            else if (task['form_name'] == "Stock Reconciliation [Tank Reading]") {
              /*
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  StockReconcileTankPage(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId!),),);
               */
              /*
              Navigator.push(context, MaterialPageRoute(builder: (context) => OMCVisitingForm(),),);
              */
              /*
              Navigator.push(context, MaterialPageRoute(builder: (context) => VisitReportPage(),),);
               */
              Navigator.push(context, MaterialPageRoute(builder: (context) => FuelDecantationHeader(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!, formId: formId!),),);
            }
            else if (task['form_name'] == "Fuel Decantation Audit") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FuelDecantationHeader(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!, formId: formId!),),);
            }
            else if (task['form_name'] == "Stock Reconciliation") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NStockReconciliation(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!, formId: formId!),),);
            }
            else if (task['form_name'] == "Site_Completion_Reports") {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!,),),);
            }
            else if (task['form_name'] == "Training_Performance") {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!,),),);
            }
            else if (task['form_name'] == "Price") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  MPricing(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId!),),);
            }
            else if (task['form_name'] == "Quantity") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Quantity_check(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId!),),);
            }
            else if (task['form_name'] == "Quality") {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Quality_check(dealer_id: dealer_id,
                      inspectionid: inspectionid!,
                      dealer_name: dealer_name!,
                      formId: formId),),);
            }
            else if (task['form_name'] == "Lube_Test") {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id: dealer_id, inspectionid: inspectionid!, dealer_name: dealer_name!,),),);
            }
          }
        },
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Smaller border radius
          ),
          color: task['status'] == '1' ? Constants.secondary_color : Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width / 4.0, // Smaller width for the card
            height: MediaQuery.of(context).size.width / 4.0, // Smaller height for the card
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   task['imagePath'],
                  //   height: 50.0, // Larger height for the image
                  //   color: task['status'] == '1' ? Colors.white : null,
                  // ),
                  SizedBox(height: 4.0), // Adjust spacing as needed
                  Text(
                    task['form_name'],
                    style: TextStyle(
                      fontSize: 12.0, // Even smaller font size for the heading
                      fontWeight: FontWeight.bold,
                      color: task['status'] == '1' ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: () async {
      // You can handle the back button press here
      // In this example, we're navigating to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
      // Return true to prevent the default behavior of popping the current route
      return true;
    },
    child:Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenWidth / 2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Byco_Background.jpeg'), // Replace with your image path
                fit: BoxFit.fill,
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
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
                                      '$totalCount',
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
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/20),
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: 4.0, // Adjust as needed
                            crossAxisSpacing: 4.0, // Adjust as needed
                            childAspectRatio: 1.4, // Ensures equal width and height for each card
                            children: buildTaskCards(formList),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width/1.8, // Half of the screen width
                            height: 45,
                            child: TextButton(
                              onPressed: () {
                                if (oneCount == totalCount) {
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
    ),
    );
  }
}