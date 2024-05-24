import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../../../utils/constants.dart';
import 'DispencerSetup.dart';
import 'Monthly_Sales_Target.dart';
import 'ProductSetup.dart';
import 'TankSetup.dart';

class PumpSetupList extends StatefulWidget {
  @override
  _PumpSetupListState createState() => _PumpSetupListState();
}

class _PumpSetupListState extends State<PumpSetupList> {

  List<String> rowTitles = ['Product','Tanks','Dispenser & Nozzle'/*,'Monthly Sales Target'*/];
  List<String> Outletlist = [];
  List<String> Outlet_id_list = [];
  List<String> addable_id_list = [];
  String? selectedOutlet;
  String? selectedOutletID;
  String addable = 'control';

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
      List<String> addableList = data.map((item) => item['no_lorries'].toString()).toList();
      setState(() {
        Outletlist = sizeList;
        Outlet_id_list = idList;
        addable_id_list = addableList;
        print("MOIZ-1: $Outletlist");
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> sendstatus() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/update_dealers_setup_status.php'));
    request.fields.addAll({
      'dealers_id': '$selectedOutletID'
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()),);
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

  @override
  void initState() {
    super.initState();
    GetOutlets_list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Pump Setup',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Constants.secondary_color,
              fontSize: 16),
        ),
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextDropdownFormField(
                options: Outletlist,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                  labelText: "Select Name",
                ),
                dropdownHeight: 100,
                onChanged: (dynamic value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selectedOutlet = value;
                      int index = Outletlist.indexOf(value);
                      if (index >= 0 && index < Outlet_id_list.length) {
                        setState(() {
                          selectedOutletID = Outlet_id_list[index];
                          addable = addable_id_list[index];
                        });
                        print("$selectedOutlet,$selectedOutletID");
                      }
                    });
                  }
                },
              ),
            ),
            if(selectedOutletID!=null)
              if(addable != '0')
                Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (int i = 0; i < rowTitles.length; i++)
                    ListTile(
                      title: Text(
                        rowTitles[i],
                      ),
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                      ),
                      onTap: () {
                        if (rowTitles[i] == 'Product') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductSetup(dealer_name:"$selectedOutlet",dealer_id: "$selectedOutletID",)),
                          );
                        }
                        else if (rowTitles[i] == 'Tanks') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TankSetup(dealer_name:"$selectedOutlet",dealer_id: "$selectedOutletID")),
                          );
                        }
                        else if (rowTitles[i] == 'Dispenser & Nozzle') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DispenserSetup(dealer_name:"$selectedOutlet",dealer_id: "$selectedOutletID")),
                          );
                        }
                        else if (rowTitles[i] == 'Monthly Sales Target') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MST(dealer_name:"$selectedOutlet",dealer_id: "$selectedOutletID")),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
              if(addable == '1')
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'To edit pump setups, please click the "Request" button and ask your head for permission.'
                      ),
                    ),
                  ),
                )
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white60,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if(addable != 'control')
                Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4),
                  child: TextButton(
                    onPressed: (){
                      if(addable == '0'){
                        sendstatus();
                      } else if(addable == '1'){
                        
                      }
                    },
                    child: Text(addable == '0' ? 'Submit' : 'Request',style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Constants.secondary_color),
                      minimumSize: MaterialStateProperty.all(Size(200, 50)),
                    ),
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
