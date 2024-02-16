import 'dart:convert';

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../../utils/constants.dart';


class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String? selectedOMCS;
  String? selectedOMCSID;
  String? selectedRadio;

  TextEditingController pumpNameController = TextEditingController();
  List<String> namelist = [];
  List<String> name_id_list = [];

  List<String> Outletlist = [];
  List<String> Outlet_id_list = [];
  String? selectedOutlet;
  String? selectedOutletID;

  String? currentLocation;

  Future<void> GetOMCSList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_omcs.php?key=03201232927'));

    if (response.statusCode == 200) {
      print("Hello world");
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList = data.map((item) => item['name'].toString()).toList();
      List<String> idList = data.map((item) => item['id'].toString()).toList();
      setState(() {
        namelist = sizeList;
        name_id_list = idList;
        print("MOIZ-1: $namelist");
      });
    } else {
      print("object-error");
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> GetOutlets_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));
    print('http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList = data.map((item) => item['name'].toString()).toList();
      List<String> idList = data.map((item) => item['id'].toString()).toList();
      setState(() {
        Outletlist = sizeList;
        Outlet_id_list = idList;
        print("MOIZ-1: $Outletlist");
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
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
        currentLocation = '${locationData.latitude.toString()}, ${locationData.longitude.toString()}';
        print(currentLocation);
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> postDataToServer(String name, String selectedOutletID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_omcs_dealers.php'));
    request.fields.addAll({
      'user_id': '$id',
      'omcs_id': '$selectedOMCSID',
      'name': name,
      'coordinates': '$currentLocation',
      'row_id': '',
      'old_dealer_id': '$selectedOutletID',
    });
    try {
      // Sending the request
      http.StreamedResponse response = await request.send();

      // Handling the response
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        Navigator.pop(context);
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
        print(response.reasonPhrase);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    GetOMCSList();
    GetOutlets_list();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        title: Text(
            'OMCS Form Page',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Constants.secondary_color,
              fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextDropdownFormField(
                        options: namelist,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          suffixIcon: Icon(
                              Icons.arrow_drop_down_circle_outlined),
                          labelText: "Select OMCS",
                        ),
                        dropdownHeight: 100,
                        onChanged: (dynamic value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              selectedOMCS = value;
                              // Find the index of the selected type in uniform_type_list
                              int index = namelist.indexOf(value);
                              if (index >= 0 && index < name_id_list.length) {
                                selectedOMCSID = name_id_list[index]; // Set the corresponding ID
                                print("$selectedOMCS,$selectedOMCSID");
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      if (selectedOMCS == 'BYCO')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      value: 'new',
                                      groupValue: selectedRadio,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRadio = value!;
                                        });
                                      },
                                    ),
                                    Text('New'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: 'old',
                                      groupValue: selectedRadio,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRadio = value!;
                                        });
                                      },
                                    ),
                                    Text('Old'),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            if (selectedRadio == 'old')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextDropdownFormField(
                                    options: Outletlist,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      suffixIcon: Icon(
                                          Icons.arrow_drop_down_circle_outlined),
                                      labelText: "Select Name",
                                    ),
                                    dropdownHeight: 100,
                                    onChanged: (dynamic value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          selectedOutlet = value;
                                          // Find the index of the selected type in uniform_type_list
                                          int index = Outletlist.indexOf(value);
                                          if (index >= 0 && index < Outlet_id_list.length) {
                                            selectedOutletID = Outlet_id_list[index]; // Set the corresponding ID
                                            print("$selectedOutlet,$selectedOutletID");
                                          }
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      postDataToServer('$selectedOutlet','$selectedOutletID');
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                              ),
                            if (selectedRadio == 'new')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: pumpNameController,
                                    decoration: InputDecoration(labelText: 'Enter Pump Names'),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      postDataToServer('$pumpNameController','');
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                              ),
                            if(selectedRadio==null)
                              Column(),
                          ],
                        ),
                      if (selectedOMCS != 'BYCO' && selectedOMCS != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: pumpNameController,
                              decoration: InputDecoration(labelText: 'Enter Pump Names'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                postDataToServer('${pumpNameController.text}','');
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}