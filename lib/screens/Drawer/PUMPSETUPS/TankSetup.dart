import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';

class TankSetup extends StatefulWidget {
  final String dealer_id;
  final String dealer_name;

  const TankSetup({Key? key, required this.dealer_id, required this.dealer_name}) : super(key: key);
  @override
  _TankSetupState createState() => _TankSetupState(dealer_id,dealer_name);
}

class _TankSetupState extends State<TankSetup> {
  final String dealer_id;
  final String dealer_name;

  _TankSetupState(this.dealer_id, this.dealer_name);

  @override
  void initState() {
    super.initState();
  }

  Future<void> GetProducts_list() async {
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/dealers_products.php?key=03201232927&dealer_id=$dealer_id'));
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
  Future<List<dynamic>> _getDealerTank() async {
    final String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealer_id';
    print('http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealer_id');
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<void> createDealerTank() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_tanks.php'));
    request.fields.addAll({
      'user_id': '$id',
      'lorry_no': _tankNumberController.text,
      'dealer_id': dealer_id,
      'row_id': '',
      'products': '$selectedProductID',
      'min_limit': _minLimitController.text.toString(),
      'max_limit': _maxLimitController.text.toString(),
      'current_reading': current_reading.text.toString(),
      'current_dip': current_dip.text.toString(),
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        setState(() {
          _tankNumberController.clear();
          _minLimitController.clear();
          _maxLimitController.clear();
          current_reading.clear();
          current_dip.clear();
          selectedProductID = null;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  TextEditingController _tankNumberController = TextEditingController();
  TextEditingController _minLimitController = TextEditingController();
  TextEditingController _maxLimitController = TextEditingController();
  TextEditingController current_reading = TextEditingController();
  TextEditingController current_dip = TextEditingController();
  List<String> Productlist = [];
  List<String> Product_id_list = [];
  String? selectedProduct;
  String? selectedProductID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Tank Setup',
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
                await GetProducts_list();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      title: Text(
                        "ADD Tanks",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              TextField(
                                controller: _tankNumberController,
                                decoration: InputDecoration(
                                  labelText: "Tank #",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              TextDropdownFormField(
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
                                  // Find the index of the selected type in uniform_type_list
                                  int index = Productlist.indexOf(value);
                                  if (index >= 0 && index < Product_id_list.length) {
                                    selectedProductID = Product_id_list[index]; // Set the corresponding ID
                                    print("$selectedProduct,$selectedProductID");
                                  }
                                });
                              }
                            },
                          ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: current_dip,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Current Dip",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: TextField(
                                      controller: current_reading,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Current Reading",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _minLimitController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Min Limit",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: TextField(
                                      controller: _maxLimitController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Max Limit",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _tankNumberController.clear();
                            _minLimitController.clear();
                            _maxLimitController.clear();
                            current_reading.clear();
                            current_dip.clear();
                            selectedProductID = null;
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if(_tankNumberController.text.isNotEmpty && _maxLimitController.text.isNotEmpty && _minLimitController.text.isNotEmpty && selectedProductID!.isNotEmpty
                            && current_dip.text.isNotEmpty && current_reading.text.isNotEmpty){
                              await createDealerTank();
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
                            }else{
                              Fluttertoast.showToast(
                                msg: 'Please Fill All Field',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
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
                backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color),
              ),
            ),

          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            FutureBuilder(
              future: _getDealerTank(),
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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var product = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Text('${product['lorry_no']}: ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                Text(product['name'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Min Limit: ', style: TextStyle( fontWeight: FontWeight.bold),),
                                        Text('${product['min_limit']}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Max Limit: ',style: TextStyle( fontWeight: FontWeight.bold)),
                                        Text('${product['max_limit']}'),
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
                                        Text('Current Dip: ',style: TextStyle( fontWeight: FontWeight.bold)),
                                        Text('${product['current_dip']}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Current Reading: ',style: TextStyle( fontWeight: FontWeight.bold)),
                                        Text('${product['current_reading']}'),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Update Time: ',style: TextStyle( fontWeight: FontWeight.bold)),
                                    Text('${product['update_time']}'),
                                  ],
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(product['created_at']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
