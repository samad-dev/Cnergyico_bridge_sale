import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../home.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  List<Map<String, dynamic>> stationData = [];
  DateTime? selectedDate;
  List<TextEditingController> textControllers =  List.generate(8, (_) =>TextEditingController());
  TextEditingController DescribeController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  // fetchData and postData
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$user_id&pre=101'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        stationData = List<Map<String, dynamic>>.from(data);
        textControllers =  List.generate(stationData.length, (_) =>TextEditingController());
        assignCurrentDateToControllers();

      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> postDataMultipleTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/inspection/create_dealers_task_app.php';

    for (int index = 0; index < stationData.length; index++) {
      if (stationData[index]['isChecked'] == true) {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields.addAll({
          'login_users_id': "$user_id",
          'description': DescribeController.text.toString(),
          'dealers_id': stationData[index]['id'],
          'inspection_date': textControllers[index].text.toString(),
          'user_id': stationData[index]['id'],
          'row_id': '',
        });

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('Request $index successful: ${await response.stream.bytesToString()}');
        } else {
          print('Request $index failed: ${response.reasonPhrase}');
        }
      }
    }
  }
  //
  Future<void> _selectDueDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        textControllers[index].text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }
  //function that will assign today date to all controller
  void assignCurrentDateToControllers() {
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < textControllers.length; i++) {
      textControllers[i].text = currentDate.toLocal().toString().split(' ')[0];
    }
  }
  //function that will check and uncheck all checkboxes
  bool areAllChecked() {
    return stationData.every((item) => item['isChecked'] == true);
  }
  void toggleCheckAllBoxes(bool value) {
    setState(() {
      for (int i = 0; i < stationData.length; i++) {
        stationData[i]['isChecked'] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Create Task',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(color: Constants.secondary_color,),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: areAllChecked(),
                      onChanged: (value) {
                        toggleCheckAllBoxes(value ?? false);
                      },
                    ),
                    Text('Select All'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                      border: OutlineInputBorder(),
                    ),
                    controller: DescribeController,
                    minLines: 2,
                    maxLines: 3,
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: stationData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: stationData[index]['isChecked'] ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      stationData[index]['isChecked'] = value;
                                    });
                                  },
                                ),
                                Text(stationData[index]['name']),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                              child: GestureDetector(
                                onTap: () => _selectDueDate(context, index),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: textControllers[index], // TL Departure Time
                                    decoration: InputDecoration(
                                      labelText: 'Inspection Date',
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust the padding values as needed
                                      border: OutlineInputBorder(), // Add this line to include a border
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
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
                      setState(() {
                        isLoading = true;
                      });
                        await postDataMultipleTimes(); // Assuming printNozzleValues is an async function
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Home()),);
                      Fluttertoast.showToast(
                        msg: 'Data sent successfully',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? CircularProgressIndicator() // Show loader
                        : Text('Submit', style: TextStyle(color: Colors.white)),
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
