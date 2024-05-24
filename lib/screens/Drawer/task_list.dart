import 'dart:convert';

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Drawer/create_order.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/Drawer/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../../utils/constants.dart';
import '../Task_Dashboard.dart';
import '../inspection.dart';

class Tasks extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _TasksState createState() => _TasksState();
}
class _TasksState extends State<Tasks> {
  List<Map<String, dynamic>> inspection_task = [];
  DateTime? selectedDate;
  TextEditingController reasonController = TextEditingController();
  TextEditingController reasontransferController = TextEditingController();
  List<String> tm_list = [];
  List<String> tm_id_list = [];
  String? selectedtmformId;
  String? selectedtmformType;
  String? user_privilege;
  var dealerlat;
  var dealerlng;
  var inspectorlat;
  var inspectorlng;
  LocationData? _currentLocation;
  late String result;
  String searchQuery = '';
  List<Map<String, dynamic>> filteredData = [];
  late String transfer_id;
  List<String> list1 =[];
  List<String> list2 =[];

  @override
  void initState() {
    super.initState();
    Inspection_task();
    _getLocation();
  }


  Future<void> Inspection_task() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    user_privilege=pre;
    final response = await http.get(
        Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/inspection/inspector_task.php?key=03201232927&id=$id&pre=$pre'));
        print('http://151.106.17.246:8080/bycobridgeApis/get/inspection/inspector_task.php?key=03201232927&id=$id&pre=$pre');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        inspection_task = List<Map<String, dynamic>>.from(data);
        filteredData = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> TransfersZM(String dealer_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/get_spec_dealer.php?key=03201232927&dealer_id=$dealer_id'));

    if (response.statusCode == 200) {
      // Parse the response and get TM and ASM data
      dynamic responseData = json.decode(response.body);

      if (responseData is List && responseData.isNotEmpty) {
        // If responseData is a List, access the first item (assuming only one item is expected)
        Map<String, dynamic> dealerData = responseData[0];
        setState(() {
          list1 = user_privilege?.toLowerCase() == "tm" ? ["${dealerData["asm_name"]} - tm"] : ["${dealerData["tm_name"]} - rm", "${dealerData["asm_name"]} - tm"];
          list2 = [dealerData["asm"],dealerData["tm"]];
        });

      } else {
        throw Exception('The API response is not a non-empty List');
      }
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  void sendRequestReschedule(var taskId,String oldDate)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final apiUrl = "http://151.106.17.246:8080/bycobridgeApis/update/inspection/task_reschedule.php";
    final data = {
      "user_id": id,
      "task_id": taskId,
      "row_id": '',
      "old_date": oldDate,
      "description": reasonController.text.toString(),
      "new_date":  "${selectedDate?.toLocal()}".split('.').first,
    };
    final response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Request for Reschedule is send successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    else {
      Fluttertoast.showToast(
        msg: "Request for Reschedule is not send successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    setState(() {
      selectedDate = null;
      reasonController.clear();

    });
  }
  void sendRequestTransfer(var taskId,var transferid)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final apiUrl = "http://151.106.17.246:8080/bycobridgeApis/update/inspection/transfer_task.php";
    final data = {
      "user_id": id,
      "task_id": taskId,
      "row_id": '',
      "transfer_to":transferid,
      "reason": reasontransferController.text.toString(),
    };
    final response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Transfer of Task is completed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
      reasontransferController.clear();
    }
    else {
      Fluttertoast.showToast(
        msg: "Transfer of task is failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    setState(() {
      reasontransferController.clear();
    });
  }
  Future<void> _getLocation() async {
    try {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation = locationData;
        inspectorlat= _currentLocation?.latitude.toString();
        inspectorlng = _currentLocation?.longitude.toString();
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> ISIN(String d_lat,String d_lng,String i_lat,String i_lng,dealer_name,dealer_id,id) async {
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/get/inspection/inspector_checkin.php?key=03201232927&i_lat=$i_lat&i_lng=$i_lng&d_lat=$d_lat&d_lng=$d_lng';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        // Map<String, dynamic> data = json.decode(response.body);

        result = response.body;
        print("result $result");
        if(result == "IN")

        {
          /*Navigator.push(context,
              MaterialPageRoute(builder: (context) => Inspection(dealer_id: dealer_id,inspectionid: id)),);*/
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: dealer_id,inspectionid: id,dealer_name: dealer_name)),);
        }

        else
        {
          Fluttertoast.showToast(msg: 'You have not reached your destination',
              toastLength: Toast.LENGTH_LONG,backgroundColor: Colors.redAccent);
        }
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text('Location Not Reached'),
        //       content: Text('Please reach the location and try again.'),
        //       actions: <Widget>[
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //           child: Text('OK'),
        //         ),
        //       ],
        //     );
        //   },
        // );
      } else {
        // Handle error
        print('Error1: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
  }
  void filterData(String query) {
    setState(() {
      searchQuery = query;
      if (query.isNotEmpty) {
        filteredData = inspection_task.where((order) => order['dealer_name'].toUpperCase().contains(query)).toList();
      } else {
        filteredData = inspection_task;
      }
    });
  }

  int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Constants.primary_color,
          elevation: 10,
          title: Text(
            'Tasks',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Constants.secondary_color,
                fontSize: 16),
          ),

        ),
        body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 5,
                    child: TextField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(FluentIcons.search_12_regular,
                              color: Color(0xff8d8d8d)),
                          hintText: 'Search...',
                          hintStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                              color: Color(0xff12283D),
                              fontSize: 16),
                          border: InputBorder.none),
                      onChanged: (value) {
                        filterData(value.toUpperCase());
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index2) {
                        if (searchQuery.isNotEmpty) {
                            filteredData = inspection_task.where((order) => order['dealer_name'].toUpperCase().contains(searchQuery)).toList();
                        } else {filteredData = inspection_task;}
                        final type = filteredData[index2]['type'];
                        final dealer_name = filteredData[index2]['dealer_name'];
                        final dealer_id = filteredData[index2]['dealer_id'];
                        final time = filteredData[index2]['time'];
                        final id = filteredData[index2]['id'];
                        final co_ordinates = filteredData[index2]['co_ordinates'];
                        var dealerlatlng = co_ordinates.split(',');
                        dealerlat= dealerlatlng[0];
                        dealerlng = dealerlatlng[1];
                        return Card(
                          elevation: 10,
                          color: Color(0xffffffff),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          'Inspection at $dealer_name',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xff12283D),
                                              fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        width: MediaQuery.of(context).size.width/1.3,
                                      ),
                                      if(user_privilege == "ZM" || user_privilege == "zm" || user_privilege == "TM"||user_privilege == "tm")
                                        GestureDetector(
                                          onTap: () async {
                                            reasontransferController.clear();
                                            await TransfersZM(dealer_id);
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(
                                                    builder: (BuildContext context, StateSetter setState){
                                                      return AlertDialog(
                                                        title: Text("Transfer"),
                                                        content: Container(
                                                          height: MediaQuery.of(context).size.height/3,
                                                          width: MediaQuery.of(context).size.width/1.2,
                                                          child: Column(
                                                            children: [
                                                              TextDropdownFormField(
                                                                options: list1,
                                                                decoration: InputDecoration(
                                                                  isDense: false,
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(18.0),
                                                                  ),
                                                                  suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                                                                  labelText: "Select employee",
                                                                ),
                                                                dropdownHeight: 100,
                                                                onChanged: (dynamic value) {
                                                                  setState(() {
                                                                    transfer_id=value;
                                                                  });
                                                                },
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 5),
                                                                child: TextField(
                                                                  controller: reasontransferController,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'Reason',
                                                                    hintText: "Reason for Transfer",
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                                                    ),
                                                                  ),
                                                                  maxLines: 3,
                                                                  minLines: 2,
                                                                ),
                                                              ),
                                                            ],

                                                          ),
                                                        ),
                                                        actions: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: (){
                                                                  List<String> parts = transfer_id.split('-');
                                                                  String secondPart = parts.length > 1 ? parts[1].trim() : '';
                                                                  if(secondPart=='tm'){
                                                                    print("hello world ${list2[0]}");
                                                                    sendRequestTransfer(id,list2[0]);
                                                                  }
                                                                  else if(secondPart=='rm'){
                                                                    print("hello world ${list2[1]}");
                                                                    sendRequestTransfer(id,list2[1]);
                                                                  }
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Constants.primary_color
                                                                ),
                                                                child: Text(
                                                                  "Start",
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              ElevatedButton(
                                                                onPressed: () => Navigator.of(context).pop(),
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Constants.primary_color
                                                                ),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                );
                                              },
                                            );
                                          },
                                          child: CircleAvatar(
                                              backgroundColor: Constants.secondary_color,
                                              child: Image.asset(
                                                "assets/images/change.png",
                                                width: 35,
                                              )
                                          ),
                                        )
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        child: Text(
                                          'Naviagate',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                            ),
                                          ),
                                          backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color,), // Change to your desired light color
                                        ),
                                        onPressed: () async{
                                          var dealerlatlng = co_ordinates.split(',');
                                          dealerlat= dealerlatlng[0];
                                          dealerlng = dealerlatlng[1];
                                          final availableMaps = await MapLauncher.installedMaps;
                                          print(availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

                                          await availableMaps.first.showMarker(
                                            coords: Coords(double.parse(dealerlat),double.parse(dealerlng)),
                                            title: "$dealer_name",
                                          );
                                          print("Hello, world!");
                                        },
                                      ),
                                      Text(
                                        'Details',
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w200,
                                            fontStyle: FontStyle.normal,
                                            color: Color(0xff737373),
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Divider(height: 1, color: Color(0xffBFBFBF)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Wrap(
                                        children: [
                                          Icon(
                                            FluentIcons.clock_48_regular,
                                            size: 15,
                                            color: Constants.secondary_color,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width:MediaQuery.of(context).size.width/4,
                                            child: Text(
                                              '$time',
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w200,
                                                  fontStyle: FontStyle.normal,
                                                  color: Color(0xff737373),
                                                  fontSize: 11),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            child: Text(
                                              'Reschedule',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Constants.secondary_color,

                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              fixedSize: const Size(120, 30),
                                            ),
                                            onPressed: () {
                                              selectedDate = null;
                                              reasonController.clear();
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(
                                                      builder: (BuildContext context, StateSetter setState){
                                                        return AlertDialog(
                                                          title: Text("Reschedule"),
                                                          content: Container(
                                                            height: MediaQuery.of(context).size.height/3.4,
                                                            width: MediaQuery.of(context).size.width/1.5,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                    border: Border.all(
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      selectedDate != null
                                                                          ? Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0),
                                                                        child: Container(
                                                                          width: MediaQuery.of(context).size.width/3.4,
                                                                          child: Text(
                                                                            selectedDate != null
                                                                                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!)
                                                                                : "Select a Date",
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                          : Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0),
                                                                        child: Text("Select a Date"),
                                                                      ),
                                                                      Container(
                                                                        height: 40, // Adjust the height as needed
                                                                        child: ElevatedButton(
                                                                          onPressed: () async {
                                                                            final DateTime? pickedDate = await showDatePicker(
                                                                              context: context,
                                                                              initialDate: DateTime.now(),
                                                                              firstDate: DateTime.now(),
                                                                              lastDate: DateTime(2101),
                                                                            );
                                                                            if (pickedDate != null) {
                                                                              final TimeOfDay? pickedTime = await showTimePicker(
                                                                                context: context,
                                                                                initialTime: TimeOfDay.fromDateTime(DateTime.now(),),
                                                                              );

                                                                              if (pickedTime != null) {
                                                                                setState(() {
                                                                                  selectedDate = DateTime(
                                                                                    pickedDate.year,
                                                                                    pickedDate.month,
                                                                                    pickedDate.day,
                                                                                    pickedTime.hour,
                                                                                    pickedTime.minute,
                                                                                  );
                                                                                });
                                                                              }
                                                                            }
                                                                          },
                                                                          style: ElevatedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.only(
                                                                                  topRight: Radius.circular(20.0),
                                                                                  bottomRight: Radius.circular(20.0),
                                                                                ),
                                                                              ),
                                                                              backgroundColor: Constants.primary_color
                                                                          ),
                                                                          child: Text(
                                                                            "Select Date",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),

                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                                  child: TextField(
                                                                    controller: reasonController,
                                                                    decoration: InputDecoration(
                                                                      labelText: 'Reason',
                                                                      hintText: "Reason for Reschedule",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                                                      ),
                                                                    ),
                                                                    maxLines: 3,
                                                                    minLines: 3,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    // Check if both date and reason are not null
                                                                    if (selectedDate != null && reasonController.text.isNotEmpty) {
                                                                      sendRequestReschedule(id, selectedDate.toString());
                                                                    } else {
                                                                      // Show a dialog or a message indicating that date and reason are required
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) {
                                                                          return AlertDialog(
                                                                            title: Text("Validation Error"),
                                                                            content: Text("Please select a date and provide a reason."),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Text("OK"),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Constants.primary_color
                                                                  ),
                                                                  child: Text(
                                                                    "Start",
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10,),
                                                                ElevatedButton(
                                                                  onPressed: () => Navigator.of(context).pop(),
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Constants.primary_color
                                                                  ),
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          ElevatedButton(
                                            child: Text(
                                              'Start',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Constants.secondary_color,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              fixedSize: Size(85, 40),
                                            ),
                                            onPressed: () {
                                              var dealerlatlng = co_ordinates.split(',');
                                              dealerlat= dealerlatlng[0];
                                              dealerlng = dealerlatlng[1];
                                              ISIN(dealerlat,dealerlng,inspectorlat,inspectorlng,dealer_name,dealer_id,id);
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: dealer_id,inspectionid: id,dealer_name: dealer_name)),);

                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ],
              ),
            )),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x8ca9a9a9),
                blurRadius: 20,
              ),
            ],
          ),
          child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              unselectedItemColor: Color(0xff8d8d8d),
              unselectedLabelStyle:
              const TextStyle(color: Color(0xff8d8d8d), fontSize: 14),
              unselectedFontSize: 14,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedIconTheme: IconThemeData(
                color: Constants.secondary_color,
              ),
              type: BottomNavigationBarType.shifting,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.home_32_regular,
                      size: 20,
                    ),
                    label: 'Home',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.weather_sunny_16_regular,
                      size: 20,
                    ),
                    label: 'Tasks',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                  icon: Icon(
                    FluentIcons.inprivate_account_16_regular,
                    size: 20,
                  ),
                  label: 'Profile',
                  backgroundColor: Colors.white,
                ),
              ],
             selectedItemColor: Constants.secondary_color,
              iconSize: 40,
              onTap: _onItemTapped,
              elevation: 15),
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // if (_selectedIndex == 1) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Orders()),
    //   );
    // }
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
    }
  }
}
