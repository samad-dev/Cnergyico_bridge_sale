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

class SalesPerformance extends StatefulWidget {
  final String dealer_id;
  const SalesPerformance({Key? key, required this.dealer_id}) : super(key: key);
  @override
  SalesPerformanceState createState() => SalesPerformanceState(dealer_id);
}

class SalesPerformanceState extends State<SalesPerformance> {
  final String dealer_id;

  SalesPerformanceState(this.dealer_id);
  
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> filteredData = [];
  List<String> variancesList = [];


  @override
  void initState() {
    super.initState();
    TargetSales(dealer_id);
  }

  Future<void> sendSalesPerformance(String product_id, String monthly_target, String target_achived, String difference, String description) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/create/dealers_target_return_response.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id': '$user_id',
          'dealer_id': '$dealer_id',
          'product_id': '$product_id',
          'row_id': '',
          'monthly_target':'$monthly_target',
          'target_achived':'$target_achived',
          'differnce':'$difference',
          'reason':'$description',
        },
      );

      if (response.statusCode == 200) {
        // Handle success, if needed
        Navigator.pop(context, TaskDashboard());
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
    for (int index = 0; index < filteredData.length; index++) {
      String description = readingControllers[index] != null
          ? readingControllers[index].text
          : ' ';
      String Variances = "${int.parse(filteredData[index]["total_sum_target"]) - int.parse(filteredData[index]['target_amount'])}";


      sendSalesPerformance(
        filteredData[index]['product_id'],
        filteredData[index]['target_amount'],
        filteredData[index]["total_sum_target"],
        Variances,
        description,
      );
    }
  }

  Future<List<Map<String, dynamic>>> TargetSales(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_dealer_monthly_target.php?key=03201232927&dealer_id=$dealerId';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Sales Performances',
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
                      final date_month = filteredData[index2]['date_month'];
                      final target_amount = filteredData[index2]['target_amount'];
                      final product_id = filteredData[index2]["product_id"];
                      final dealer_id = filteredData[index2]["dealer_id"];
                      final created_at = filteredData[index2]["created_at"];
                      final created_by = filteredData[index2]["created_by"];
                      final description = filteredData[index2]["description"];
                      final name = filteredData[index2]["name"];
                      final total_sum_target = filteredData[index2]["total_sum_target"];
                      controller.addListener(() {
                        print("Updated reason for variation: ${controller.text}");
                        filteredData[index2]['reason_for_variation'] = controller.text;
                        print(filteredData[0]['reason_for_variation']);
                        print(filteredData[1]['reason_for_variation']);
                      });


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
                                      "$name",
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
                                SizedBox(height: 5,),
                                Text(
                                  "Target for the Month: $target_amount",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w200,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Actual To Date: $total_sum_target",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w200,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Variances: ${int.parse(total_sum_target) - int.parse(target_amount)}",
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
                                  decoration: InputDecoration(
                                    labelText: 'Reason for Variation',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
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
