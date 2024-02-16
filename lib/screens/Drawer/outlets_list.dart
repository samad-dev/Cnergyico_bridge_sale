import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/casualvisit.dart';
import 'package:hascol_inspection/screens/Drawer/create_order.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/Drawer/profile.dart';
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;


import '../../utils/constants.dart';

class Outlets extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _OutletsState createState() => _OutletsState();
}


class _OutletsState extends State<Outlets> {
  //created variable:
  List<Map<String, dynamic>> outlets_list = [];
  List<Map<String, dynamic>> filteredData = [];
  String searchQuery = '';
  bool isLoading = true;
  LocationData? _currentLocation;
  var inspectorlat;
  var inspectorlng;
  var dealerlat;
  var dealerlng;
  @override
  void initState() {
    super.initState();
    Outlets_list();
    _getLocation();
  }

  Future<void> Outlets_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        outlets_list = List<Map<String, dynamic>>.from(data);
        filteredData = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  void filterData(String query) {
    setState(() {
      searchQuery = query;
      if (query.isNotEmpty) {
        filteredData = outlets_list.where((order) => order['name'].toUpperCase().contains(query)).toList();
      } else {
        filteredData = outlets_list;
      }
    });
  }
  Future<List<dynamic>> GetLedger(String dealerId) async {
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/get/get_dealer_ledger_log.php?key=03201232927&dealer_id=$dealerId';
    final response = await http.get(
      Uri.parse('$apiUrl'),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data');
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
        _currentLocation = locationData;
        inspectorlat= _currentLocation?.latitude.toString();
        inspectorlng = _currentLocation?.longitude.toString();
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> ISIN(String d_lat,String d_lng,String i_lat,String i_lng,name,dealer_id) async {
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/get/inspection/inspector_checkin.php?key=03201232927&i_lat=$i_lat&i_lng=$i_lng&d_lat=$d_lat&d_lng=$d_lng';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        String result = response.body;
        print("result $result");
        if(result == "IN")
        {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CasualVisitPage(dealer_id: dealer_id,dealer_name: name!,)));
        }

        else
        {
          Fluttertoast.showToast(msg: 'You have not reached your destination',
              toastLength: Toast.LENGTH_LONG,backgroundColor: Colors.redAccent);
        }
      } else {
        // Handle error
        print('Error1: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
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
          automaticallyImplyLeading: true,
          backgroundColor: Constants.primary_color,
          elevation: 10,
          iconTheme: IconThemeData(
            color: Constants.secondary_color,
          ),
          title: Text(
            'Outlets',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Constants.secondary_color,
                fontSize: 16),
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12),
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
                              fontSize: 16
                          ),
                          border: InputBorder.none),
                      onChanged: (value) {
                        filterData(value.toUpperCase());
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index2) {
                        if (searchQuery.isNotEmpty) {
                          filteredData = outlets_list.where((order) => order['name'].toUpperCase().contains(searchQuery)).toList();
                        } else {filteredData = outlets_list;}
                        final ledger = filteredData[index2]['acount'];
                        final dealer_id = filteredData[index2]['id'];
                        final location = filteredData[index2]['location'];
                        final contact = filteredData[index2]['contact'];
                        final sap_no = filteredData[index2]["sap_no"];
                        final name=filteredData[index2]["name"];
                        final co_ordinates = filteredData[index2]['co-ordinates'];
                        final baseurl = 'http://151.106.17.246:8080/bycobridgeApis/uploads/';
                        final banner = filteredData[index2]['banner'];
                        final logo = filteredData[index2]['logo'];
                        final bannerUrl = Uri.parse('$baseurl$banner');
                        final logoUrl = Uri.parse('$baseurl$logo');
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            elevation: 10,
                            color: Color(0xffe9e9e9),//Color(0xffF0F0F0),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        /*
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: CircleAvatar(
                                                radius:
                                                28, // Adjust the size of the circular avatar
                                                backgroundColor: Constants.secondary_color,
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                  child: Image.asset(
                                                    "assets/images/boss.png",
                                                    width: 38,
                                                    height: 38,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        */
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.only(top:12),
                                                            width: MediaQuery.of(context).size.width/2.37,
                                                            child: Text(
                                                              '$name',
                                                              style: GoogleFonts.montserrat(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontStyle: FontStyle.normal,
                                                                  color: Color(0xff12283D),
                                                                  fontSize: 16),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                            child: Icon(Icons.graphic_eq)
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/1.8,
                                                          child: Text(
                                                            '$location',
                                                            style: GoogleFonts.montserrat(
                                                                fontWeight: FontWeight.w200,
                                                                fontStyle: FontStyle.normal,
                                                                color: Colors.black54,
                                                                fontSize: 12),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: GestureDetector(
                                                            child: Text("Details"),
                                                            onTap: (){
                                                              showModalBottomSheet(
                                                                context: context,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                                                                ),
                                                                builder: (BuildContext context) {
                                                                  return Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.only(
                                                                        topLeft: Radius.circular(30.0),
                                                                        topRight: Radius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: <Widget>[
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(30.0),
                                                                              topRight: Radius.circular(30.0),
                                                                            ),
                                                                            color: Constants.primary_color,
                                                                          ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Column(
                                                                              children: [
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    shape: BoxShape.circle,
                                                                                    border: Border.all(
                                                                                      color: Colors.white, // Set the color of the border
                                                                                      width: 2.0, // Set the width of the border
                                                                                    ),
                                                                                  ),
                                                                                  child: CircleAvatar(
                                                                                    radius: 30.0,
                                                                                    backgroundImage: NetworkImage(logoUrl.toString()),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 10.0),
                                                                                Text(
                                                                                  '$name',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold,color: Constants.secondary_color),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          width: MediaQuery.of(context).size.width,
                                                                        ),
                                                                        SizedBox(height: 5.0),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
                                                                          child: Column(
                                                                            children: [
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Icon(FluentIcons.location_12_filled),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      ': $location',
                                                                                      textAlign: TextAlign.start,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 5.0),
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Icon(Icons.contact_phone),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      ' : $contact',
                                                                                      textAlign: TextAlign.justify,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 5.0),
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Icon(Icons.confirmation_number),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      ' : $sap_no',
                                                                                      textAlign: TextAlign.justify,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 5.0),
                                                                              Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Icon(Icons.book),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      ' : ${NumberFormat.decimalPattern('en').format(int.parse(ledger))} PKR',
                                                                                      textAlign: TextAlign.justify,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 20.0),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Divider(
                                        color: Color(0xffBFBFBF),  // Set the color of the divider
                                        height: 20,           // Set the height of the divider
                                        thickness: 2,          // Set the thickness of the divider
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: ()async {
                                                  List<dynamic> ledgerData = await GetLedger(dealer_id);

                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('Ledger Details'),
                                                        content: SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              for(int i=0;i<ledgerData.length;i++)
                                                                Card(
                                                                  elevation: 10,
                                                                  color: Color(0xffe9e9e9),//Color(0xffF0F0F0),
                                                                  child: Container(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                                      child: Column(
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [

                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child:
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(left: 8.0),
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Container(
                                                                                                  padding: EdgeInsets.only(top:12),
                                                                                                  width: MediaQuery.of(context).size.width/2.37,
                                                                                                  child: Text(
                                                                                                    'Update Ledger: ${ledgerData[i]['new_ledger']}',
                                                                                                    style: GoogleFonts.montserrat(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FontStyle.normal,
                                                                                                        color: Color(0xff12283D),
                                                                                                        fontSize: 16),
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(left: 8.0),
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: MediaQuery.of(context).size.width/1.8,
                                                                                                child: Text(
                                                                                                  'Time: ${ledgerData[i]['datetime']}',
                                                                                                  style: GoogleFonts.montserrat(
                                                                                                      fontWeight: FontWeight.w200,
                                                                                                      fontStyle: FontStyle.normal,
                                                                                                      color: Colors.black54,
                                                                                                      fontSize: 12),
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),

                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(left: 8.0),
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: MediaQuery.of(context).size.width/1.8,
                                                                                                child: Text(
                                                                                                  'Doc No: ${ledgerData[i]['doc_no']}',
                                                                                                  style: GoogleFonts.montserrat(
                                                                                                      fontWeight: FontWeight.w200,
                                                                                                      fontStyle: FontStyle.normal,
                                                                                                      color: Colors.black54,
                                                                                                      fontSize: 12),
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),

                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(left: 8.0),
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: MediaQuery.of(context).size.width/1.8,
                                                                                                child: Text(
                                                                                                  'Debit/Credit No.: ${ledgerData[i]['debit_no']}',
                                                                                                  style: GoogleFonts.montserrat(
                                                                                                      fontWeight: FontWeight.w200,
                                                                                                      fontStyle: FontStyle.normal,
                                                                                                      color: Colors.black54,
                                                                                                      fontSize: 12),
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),

                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              // Text('${ledgerData[i]['old_ledger']}:',style: TextStyle(color: Colors.black),)
                                                              // for (var entry in ledgerData.entries)
                                                              //   ,
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('Close'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );},
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 4.0, backgroundColor: Constants.secondary_color, // Set the button color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0), // Set your preferred border radius here
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(FluentIcons.arrow_download_16_filled, color: Constants.primary_color),
                                                    Text(
                                                      ' Download Ledger',
                                                      style: TextStyle(color: Constants.primary_color, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              TextButton(
                                                onPressed: () {
                                                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => InspectionReports(dealer_id: dealer_id)));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 4.0, backgroundColor: Constants.secondary_color, // Set the button color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0), // Set your preferred border radius here
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(FluentIcons.rectangle_portrait_location_target_20_filled, color: Constants.primary_color),
                                                    Text(
                                                      ' Inspection Reports',
                                                      style: TextStyle(color: Constants.primary_color, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () async{
                                                  var dealerlatlng = co_ordinates.split(',');
                                                  dealerlat= dealerlatlng[0];
                                                  dealerlng = dealerlatlng[1];
                                                  print(co_ordinates);
                                                  print(dealerlatlng);
                                                  ISIN(dealerlat,dealerlng,inspectorlat,inspectorlng,name,dealer_id);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 4.0, backgroundColor: Constants.secondary_color, // Set the button color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0), // Set your preferred border radius here
                                                  ),
                                                ),
                                                child: Text(
                                                  'Casual Visits',
                                                  style: TextStyle(color: Constants.primary_color, fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ],
              ),
            )),
      );
    });
  }
}
