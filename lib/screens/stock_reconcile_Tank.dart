import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'Task_Dashboard.dart';
import 'outlets_list.dart';
import 'package:intl/intl.dart';

class StockReconcileTankPage extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const StockReconcileTankPage({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name, required this.formId}) : super(key: key);

  @override
  _StockReconcileTankPageState createState() => _StockReconcileTankPageState(dealer_id, inspectionid,dealer_name,formId);
}

class _StockReconcileTankPageState extends State<StockReconcileTankPage> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  _StockReconcileTankPageState(this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> filteredData1 = [];
  String number_of_Tank = "0";
  String number_of_nozzel = "0";
  List<TextEditingController> readingControllers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    get_dealer_Tank(dealer_id);
    get_dealer_nozzles(dealer_id);
  }

  Future<List<Map<String, dynamic>>> get_dealer_Tank(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealerId';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData = List<Map<String, dynamic>>.from(data);
          number_of_Tank = "${filteredData.length}";
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
  Future<List<Map<String, dynamic>>> get_dealer_nozzles(String dealerId) async {
    final apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_nozels.php?key=03201232927&dealer_id=$dealerId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> resultList =
        data.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          filteredData1 = List<Map<String, dynamic>>.from(data);
          number_of_nozzel= "${filteredData1.length}";
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

  Future<void> sendReconciliationData(int index,String id, String oldReading, String newReading, String product_id) async {
    setState(() {
      isLoading = true; // Show loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedDate = formatter.format(now);
    final apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/dealers_inspection_dip.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'user_id': '$user_id',
          'dealer_id':dealer_id,
          'task_id': inspectionid,
          'dip_old': oldReading,
          'product_id': product_id,
          'tank_id': id,
          'dip_new': newReading,
        },
      );

      if (response.statusCode == 200) {
        if(filteredData.length-1 == index){
          poststaus();
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
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php'));
    request.fields.addAll({
      'task_id': "${widget.inspectionid}",
      'form_id': "${widget.formId}",
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: widget.dealer_id,inspectionid: widget.inspectionid,dealer_name: widget.dealer_name)),);
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
  void printReadingControllersValues() {
    if (checkNullReadings()) {
      for (int index = 0; index < readingControllers.length; index++) {
        print('Controller Value: ${readingControllers[index].text}');
        String oldReading = filteredData[index]['current_dip'] ?? '0';
        String newReading = readingControllers[index].text;

        sendReconciliationData(
          index,
          filteredData[index]['id'],
          oldReading,
          newReading,
          filteredData[index]['product']
        );
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
              content: Text('Reading of Tank ${index+1} is not taken. Please take its reading.'),
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
          'Wet Stock Management',
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
                      final min_limit = filteredData[index2]["min_limit"];
                      final max_limit = filteredData[index2]["max_limit"];
                      final old_dip = filteredData[index2]["current_dip"];
                      final update_time = filteredData[index2]["update_time"];
                      final created_at = filteredData[index2]["created_at"];
                      final created_by = filteredData[index2]["created_by"];
                      final product = filteredData[index2]["product"];
                      final name = filteredData[index2]["name"];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 15,
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
                                      "Tank ${index2+1}: $name",
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
                                  "Recent Reading: ${NumberFormat.decimalPattern('en').format(int.parse(old_dip))} ltr.",
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
