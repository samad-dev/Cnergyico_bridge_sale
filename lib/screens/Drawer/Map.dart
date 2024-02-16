import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<String> Outletlist = [];
  List<String> Outlet_coordinates_list = [];
  String? selectedOutlet;
  String? selectedOutletID;
  String? currentLocation;

  Set<Marker> markers = Set();
  late BitmapDescriptor customMarkerIcon;

  Future<void> GetOutlets_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList =
      data.map((item) => item['name'].toString()).toList();
      List<String> idList =
      data.map((item) => item['co-ordinates'].toString()).toList();
      setState(() {
        Outletlist = sizeList;
        Outlet_coordinates_list = idList;
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
        currentLocation =
        '${locationData.latitude.toString()}, ${locationData.longitude.toString()}';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addMarkers() async {
    for (int i = 0; i < Outletlist.length; i++) {
      List<String> coordinates = Outlet_coordinates_list[i].split(',');
      double latitude = double.parse(coordinates[0]);
      double longitude = double.parse(coordinates[1]);

      markers.add(
        Marker(
          markerId: MarkerId(Outletlist[i]),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: Outletlist[i]),

        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    GetOutlets_list().then((value) => _addMarkers());
  }


  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.3753, 69.3451), // Coordinates for a location in Pakistan
    zoom: 6.0, // You can adjust the zoom level as needed
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        title: Text(
          'Map',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
      ),
      body: GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        fortyFiveDegreeImageryEnabled: true,
        trafficEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }
}
