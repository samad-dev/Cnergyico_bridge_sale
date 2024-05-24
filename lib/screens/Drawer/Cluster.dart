import 'dart:convert';

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';

void main() {
  runApp(ClusteringPage());
}

class Pump {
  final String name;
  final List<String> omcs;

  Pump({required this.name, required this.omcs});
}

class ClusteringPage extends StatefulWidget {
  @override
  _ClusteringPageState createState() => _ClusteringPageState();
}

class _ClusteringPageState extends State<ClusteringPage> {

  String selectedPump = '';
  String selectedside = '';
  List<Map<String, dynamic>> clusterData = [];
  LatLng? currentLocation;
  LatLng? selectedLocation;
  GoogleMapController? mapController;

  TextEditingController nameController = TextEditingController();
  TextEditingController gasolineController = TextEditingController();
  TextEditingController dieselController = TextEditingController();
  TextEditingController motorFuelController = TextEditingController();
  TextEditingController cngController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  TextEditingController MygasolineController = TextEditingController();
  TextEditingController MydieselController = TextEditingController();
  TextEditingController MymotorFuelController = TextEditingController();
  TextEditingController MycngController = TextEditingController();
  TextEditingController MyremarksController = TextEditingController();

  List<String> Outletlist = [];
  List<String> Outlet_id_list = [];
  String? selectedOutlet;
  String? selectedOutletID;

  List<String> namelist = [];
  List<String> name_id_list = [];
  String selectedOmc = '';
  String? selectedOMCSID;

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
  Future<void> _getCurrentLocation() async {
    LocationData? locationData;
    var location = Location();

    try {
      locationData = await location.getLocation();
    } catch (error) {
      print("Error getting location: $error");
    }

    if (locationData != null) {
      setState(() {
        currentLocation = LatLng(locationData!.latitude!, locationData.longitude!);
        selectedLocation = currentLocation;
      });
    }
  }
  Future<void> GetOMCSList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_omcs.php?key=03201232927'));

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
  void _selectLocation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Location'),
          content: Container(
            width: double.maxFinite,
            height: 300, // adjust height as needed
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation ?? LatLng(0, 0), // default location if current location is not available
                zoom: 15,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              onTap: (LatLng latLng) {
                setState(() {
                  selectedLocation = latLng; // Update selected location
                });
              },
              markers: Set<Marker>.of([
                Marker(
                  markerId: MarkerId('selectedLocation'),
                  position: selectedLocation ?? LatLng(0, 0),
                  draggable: true,
                  onDragEnd: (LatLng position) {
                    setState(() {
                      selectedLocation = position;
                      print(selectedLocation);
                    });
                  },
                ),
              ]),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Handle the selected location
                print('Selected location: $selectedLocation');
                Navigator.of(context).pop(selectedLocation);
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );
  }
  Future<void> postCluster(jsonData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_clusters.php'));
    request.fields.addAll({
      'dealer_id': '$selectedOutletID',
      'user_id': '$user_id',
      'gasoline': MygasolineController.text,
      'row_id': '',
      'cluster': jsonData,
      'hsd': MydieselController.text,
      'motol': MygasolineController.text,
      'cng': MycngController.text,
      'remark': MyremarksController.text
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
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
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    GetOutlets_list();
    _getCurrentLocation();
    GetOMCSList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.primary_color,
          iconTheme: IconThemeData(color: Constants.secondary_color,),
          title: Text(
            'Clustering',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Constants.secondary_color,
                fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                        selectedOutlet = value!;
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

                if (selectedOutlet != null && selectedOutlet!.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 18),
                          child: Column(
                            children: [
                              Text(
                                'Enter Cluster Data:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(labelText: 'Name'),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      items: namelist.map((omc) {
                                        return DropdownMenuItem<String>(
                                          value: omc,
                                          child: Text(omc),
                                        );
                                      }).toList(),
                                      onChanged: (dynamic value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            selectedOmc = value;
                                            // Find the index of the selected type in uniform_type_list
                                            int index = namelist.indexOf(value);
                                            if (index >= 0 && index < name_id_list.length) {
                                              selectedOMCSID = name_id_list[index]; // Set the corresponding ID
                                              print("$selectedOmc,$selectedOMCSID");
                                            }
                                          });
                                        }
                                      },
                                      hint: Text('Select OMC'),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      items: ['SS', 'OS'].map((side) {
                                        return DropdownMenuItem<String>(
                                          value: side,
                                          child: Text(side),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        selectedside = value!;
                                      },
                                      hint: Text('Select Side'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: gasolineController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: 'Gasoline'),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: TextField(
                                      controller: dieselController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: 'Diesel'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: motorFuelController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: 'Motor Fuel'),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: TextField(
                                      controller: cngController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(labelText: 'CNG (cars/day)'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: remarksController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(labelText: 'Remarks (if any)'),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                      onPressed:(){
                                        /*
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Select Location'),
                                              content: Container(
                                                width: double.maxFinite,
                                                height: 300, // adjust height as needed
                                                child: GoogleMap(
                                                  initialCameraPosition: CameraPosition(
                                                    target: currentLocation ?? LatLng(0, 0), // default location if current location is not available
                                                    zoom: 15,
                                                  ),
                                                  onMapCreated: (controller) {
                                                    setState(() {
                                                      mapController = controller;
                                                    });
                                                  },
                                                  onTap: (LatLng latLng) {
                                                    setState(() {
                                                      selectedLocation = latLng;
                                                    });
                                                  },
                                                  markers: Set<Marker>.of([
                                                    Marker(
                                                      markerId: MarkerId('selectedLocation'),
                                                      position: selectedLocation ?? LatLng(0, 0),
                                                      draggable: true,
                                                      onDragEnd: (LatLng position) {
                                                        setState(() {
                                                          selectedLocation = position;
                                                        });
                                                      },
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Close'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Handle the selected location
                                                    print('Selected location: $selectedLocation');
                                                    Navigator.of(context).pop(selectedLocation);
                                                  },
                                                  child: Text('Select'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                         */
                                        _selectLocation();
                                      },
                                      icon: Icon(Icons.location_on,color: Constants.primary_color,),
                                    label: Text('Location',style: TextStyle(color: Constants.primary_color),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Constants.secondary_color)
                                  ),),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              if(nameController.text.isNotEmpty && gasolineController.text.isNotEmpty && dieselController.text.isNotEmpty
                                  && motorFuelController.text.isNotEmpty && selectedOmc != '' && selectedside !=''){
                                setState(() {
                                  clusterData.add({
                                    'name': nameController.text,
                                    'gasoline': gasolineController.text,
                                    'diesel': dieselController.text,
                                    'motorFuel': motorFuelController.text,
                                    'cng': cngController.text,
                                    'remarks': remarksController.text,
                                    'omc': selectedOmc,
                                    'side':selectedside,
                                    'location':selectedLocation
                                  });
                                  /*clusterData.add({
                                    'name': nameController.text,
                                    'gasoline': gasolineController.text,
                                    'diesel': dieselController.text,
                                    'motorFuel': motorFuelController.text,
                                    'cng': cngController.text,
                                    'remarks': remarksController.text,
                                    'omc': selectedOmc,
                                    'side':selectedside,
                                    'location':currentLocation
                                  });*/
                                });
                                _resetFields();
                              }
                              else{

                              }
                            },
                            icon: Icon(Icons.add_circle_outline,size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20),
                if (clusterData.isNotEmpty) ...[
                  Text(
                    'Cluster Data:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: List.generate(clusterData.length, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(clusterData[index]['name'],style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text('OMC\'s: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text('${clusterData[index]['omc']}'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('Side: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text('${clusterData[index]['side']}'),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Gasoline: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text('${clusterData[index]['gasoline']}'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('Diesel: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text('${clusterData[index]['diesel']}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Motor Fuel: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text('${clusterData[index]['motorFuel']}'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('CNG: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(
                                                clusterData[index]['cng'] == '' ? '0/0' : clusterData[index]['cng'],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text('Remarks: ',style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${clusterData[index]['remarks']}',),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,color: Colors.red,),
                            onPressed: () {
                              setState(() {
                                clusterData.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 18),
                      child: Column(
                        children: [
                          Text(
                            '$selectedOutlet (Proposed)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: MygasolineController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Gasoline'),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  controller: MydieselController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Diesel'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: MymotorFuelController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Motor Fuel'),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child: TextField(
                                  controller: MycngController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(labelText: 'CNG (cars/day)'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: MyremarksController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(labelText: 'Remarks (if any)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 200, // Set your desired width
                      height: 50, // Set your desired height
                      child: ElevatedButton(
                        onPressed: () {
                          String jsonData = jsonEncode(clusterData.map((data) => {
                            "name": data['name'],
                            "omc_id": selectedOMCSID,
                            "side": selectedside,
                            "gasoline": data['gasoline'],
                            "hsd": data['diesel'],
                            "motor": data['motorFuel'],
                            "cng": data['cng'],
                            "remark": data['remarks'],
                            "coordinates": "${data['location']!.latitude}, ${data['location']!.longitude}"
                          }).toList());
                          print('Submitting data: $jsonData');
                          if(MygasolineController.text.isNotEmpty && MydieselController.text.isNotEmpty && MymotorFuelController.text.isNotEmpty){
                            postCluster(jsonData);
                          }
                        },
                        child: Text('Submit',style: TextStyle(color: Constants.primary_color),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Constants.secondary_color)
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetFields() {
    nameController.clear();
    gasolineController.clear();
    dieselController.clear();
    motorFuelController.clear();
    cngController.clear();
    remarksController.clear();
  }
}
