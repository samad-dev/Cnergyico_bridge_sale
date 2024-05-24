import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';

class DispenserSetup extends StatefulWidget {
  final String dealer_id;
  final String dealer_name;

  const DispenserSetup({Key? key, required this.dealer_id, required this.dealer_name}) : super(key: key);
  @override
  _DispenserSetupState createState() => _DispenserSetupState(dealer_id,dealer_name);
}

class _DispenserSetupState extends State<DispenserSetup> {
  final String dealer_id;
  final String dealer_name;

  _DispenserSetupState(this.dealer_id, this.dealer_name);

  final TextEditingController nameController = TextEditingController();
  late List<TextEditingController> initialReadingControllers;

  List<String> nozzleNames = [];
  List<String> nozzleIDs = [];
  List<String> SelectedProductNozzleID = [];
  List<String> SelectedTankNozzleID = [];

  List<String> Productlist = [];
  List<String> Product_id_list = [];
  String? selectedProduct;
  String? selectedProductID;

  List<dynamic> Tank = [];

  Future<List<dynamic>> _getDealerDispencer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_dispensor_nozels.php?key=03201232927&dealer_id=$dealer_id';
    print('http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_dispensor_nozels.php?key=03201232927&dealer_id=$dealer_id');
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<void> GetProducts_list() async {
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/dealers_products.php?key=03201232927&dealer_id=$dealer_id'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList = data.map((item) => item['name'].toString()).toList();
      List<String> idList = data.map((item) => item['id'].toString()).toList();
      setState(() {
        Productlist = sizeList;
        Product_id_list = idList;
        print("MOIZ-1: $Productlist");
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> GetDealerTank_list() async {
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealer_id'));
    if (response.statusCode == 200) {
      Tank = json.decode(response.body);
      print(Tank);
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  List<Map<String, String>> generateJson(List<String> nozzleNames, List<String> SelectedProductNozzleID, List<String> SelectedTankNozzleID, List<TextEditingController> initialReadingControllers) {
    List<Map<String, String>> jsonList = [];

    for (int i = 0; i < nozzleNames.length; i++) {
      Map<String, String> jsonMap = {
        "name": nozzleNames[i],
        "nozzels_products": SelectedProductNozzleID[i],
        "product_tank": SelectedTankNozzleID[i],
        "nozel_last_reading":initialReadingControllers[i].text,
      };
      jsonList.add(jsonMap);
    }
    print('this is your list: $jsonList');
    return jsonList;
  }
  bool isFormFilled() {
    // Check if the name field is filled
    if (nameController.text.isEmpty) {
      return false;
    }

    // Check if any nozzle field is not filled
    for (int i = 0; i < nozzleNames.length; i++) {
      if (nozzleNames[i].isEmpty || SelectedProductNozzleID[i].isEmpty || SelectedTankNozzleID[i].isEmpty) {
        return false;
      }
    }

    return true;
  }
  Future<void> postData(String data_arr) async {
    print (data_arr);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dispensor_nozzels_app.php'));
    request.fields.addAll({
      'dealer_id': dealer_id,
      'user_id': '$user_id',
      'data_arr': data_arr,
      'dispenser_name': nameController.text.toString()
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Data sent successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      nameController.clear();
      nozzleNames.clear();
      SelectedProductNozzleID.clear();
      SelectedTankNozzleID.clear();
    }
    else {
      print(response.reasonPhrase);
    }
  }


  @override
  void initState() {
    super.initState();
    GetProducts_list();
    GetDealerTank_list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Dispenser Setup',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Constants.secondary_color,
              fontSize: 16),
        ),
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: StatefulBuilder(
                        builder: (context, setState) =>  Container(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dispencer',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                TextField(
                                  controller: nameController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                TextDropdownFormField(
                                  options: ['1','2','3','4','5','6'],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                                    labelText: "Nozzle",
                                  ),
                                  dropdownHeight: 100,
                                  onChanged: (dynamic value) {
                                    print(value);
                                    int selectedNozzles = int.parse(value);
                                    nozzleNames = List.generate(selectedNozzles, (index) => 'Nozzle ${index + 1}');
                                    SelectedProductNozzleID  = List.generate(selectedNozzles, (index) => '');
                                    SelectedTankNozzleID  = List.generate(selectedNozzles, (index) => '');
                                    initialReadingControllers = List.generate(nozzleNames.length,(index) => TextEditingController());
                                    setState(() {});
                                  },
                                ),
                                SizedBox(height: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i =0; i<nozzleNames.length; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${nozzleNames[i]}: '), // Display nozzle name
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextDropdownFormField(
                                                    options: Productlist,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(18.0),
                                                      ),
                                                      suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                                                      labelText: "Select Product",
                                                    ),
                                                    dropdownHeight: 100,
                                                    onChanged: (dynamic value) {
                                                      if (value.isNotEmpty) {
                                                        setState(() {
                                                          selectedProduct = value;
                                                          int index = Productlist.indexOf(value);
                                                          if (index >= 0 && index < Product_id_list.length) {
                                                            selectedProductID = Product_id_list[index]; // Set the corresponding ID
                                                            print("$selectedProduct,$selectedProductID");
                                                          }
                                                          nozzleNames[i] = '${nozzleNames[i]} - $selectedProduct';
                                                          SelectedProductNozzleID[i] = '$selectedProductID';
                                                          print(SelectedProductNozzleID);
                                                          print(nozzleNames);
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                Expanded(
                                                  child: DropdownButtonFormField<String>(
                                                      items:
                                                      Tank.map<DropdownMenuItem<String>>((dynamic option) {
                                                        return DropdownMenuItem<String>(
                                                          value: option['id'],
                                                          child: Text("${option['lorry_no']}"),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) async {
                                                        setState((){
                                                          SelectedTankNozzleID[i] = value!;
                                                          print(SelectedTankNozzleID);
                                                        });
                                                      },
                                                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                                                      decoration: InputDecoration(
                                                        labelText: 'Select Tank',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(18.0),
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            TextField(
                                              controller: initialReadingControllers[i],
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                labelText: 'Initial Reading',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                              ),
                                              keyboardType: TextInputType.number,
                                            )

                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Close dialog
                                          nameController.clear();
                                          nozzleNames.clear();
                                          SelectedProductNozzleID.clear();
                                          SelectedTankNozzleID.clear();
                                          Navigator.of(context).pop();
                                          initialReadingControllers.clear();
                                        },
                                        child: Text(
                                          'Close',
                                          style: TextStyle(color: Constants.secondary_color),
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if(isFormFilled()){
                                            List<Map<String, String>> jsonList = await generateJson(nozzleNames, SelectedProductNozzleID, SelectedTankNozzleID,initialReadingControllers);
                                            postData(jsonEncode(jsonList));
                                          }
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(color: Constants.primary_color),
                                        ),
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Constants.secondary_color)),
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
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Constants.primary_color),
                  Text(
                    ' ADD ',
                    style: TextStyle(color: Constants.primary_color),
                  ),
                ],
              ),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Constants.secondary_color),
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: _getDealerDispencer(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var product = snapshot.data![index];
                List<String> nozzleNames = (product['nozel_name'] as String).split(',');
                List<String> TankNames = (product['tank_name'] as String).split(',');
                print(nozzleNames);
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(product['dispenser_name'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      subtitle:ListView.builder(
                        shrinkWrap: true,
                        itemCount: nozzleNames.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nozzleNames[index],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Tank Name: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        TankNames[index],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}
