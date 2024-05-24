import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';


class MST extends StatefulWidget {
  final String dealer_id;
  final String dealer_name;

  const MST({Key? key, required this.dealer_id, required this.dealer_name}) : super(key: key);

  @override
  _MSTState createState() => _MSTState(dealer_id,dealer_name);
}

class _MSTState extends State<MST> {
  final String dealer_id;
  final String dealer_name;

  _MSTState(this.dealer_id, this.dealer_name);

  Future<List<dynamic>> _getDealerProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/dealers_products.php?key=03201232927&dealer_id=$dealer_id';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> nameList = data.map((item) => item['name'].toString()).toList();
        List<String> idList = data.map((item) => item['id'].toString()).toList();
        print('Hellow world of products: $nameList,$idList');
        Productlist=nameList;
        Product_id_list=idList;
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load data');
    }
  }
  Future<List<dynamic>> _getDealerMST() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_product_target.php?key=03201232927&dealer_id=$dealer_id';
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
  Future<void> createDealerMST() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_product_target.php'));
    request.fields.addAll({
      'user_id': '$id',
      'month_name': Month.text,
      'dealer_id': dealer_id,
      'row_id': '',
      'targeted_amount': Target.text,
      'targeted_product': '$selectedProductID',
      'products_description': Description.text,
    });


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
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
      Fluttertoast.showToast(
        msg: 'failed to send data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // Format the picked date to include only month and year
      String formattedDate = DateFormat('yyyy-MM').format(picked);

      setState(() {
        // Assuming Month is a TextEditingController
        Month.text = formattedDate;
      });
    }
  }

  List<String> Productlist = [];
  List<String> Product_id_list = [];
  String? selectedProduct;
  String? selectedProductID;
  final TextEditingController Month = TextEditingController();
  final TextEditingController Target = TextEditingController();
  final TextEditingController Description = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDealerProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Monthly Sales Target',
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
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Products',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15,),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDueDate(context),
                                    child: AbsorbPointer(
                                      child: TextField(
                                        controller: Month, // TL Arrival Time
                                        decoration: InputDecoration(
                                          labelText: 'Month',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          //contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: Target,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Target Amount",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            TextField(
                              controller: Description,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              maxLines: 3,
                              minLines: 3,
                            ),
                            SizedBox(height: 15,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if(Month.text.isNotEmpty && Target.text.isNotEmpty && Description.text.isNotEmpty && selectedProductID != null){
                                      await createDealerMST();
                                      Month.clear();
                                      Target.clear();
                                      Description.clear();
                                      selectedProductID = null;
                                      Navigator.of(context).pop();
                                    }
                                    else{
                                      Fluttertoast.showToast(
                                        msg: 'please fill all field',
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
                                      backgroundColor: MaterialStateProperty.all(
                                          Constants.secondary_color)),
                                ),
                              ],
                            )
                          ],
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
                backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder(
              future: _getDealerMST(),
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(product['name'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Month: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text(DateFormat('MMM yyyy').format(DateFormat('yyyy-MM').parse(product['date_month'])))

                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Target: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text(NumberFormat('#,##0', 'en_US').format(double.parse(product['target_amount']))),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Description: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${product['description']}'),
                                      ],
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('${product['created_at']}'),
                                          /*
                                          Row(
                                            children: [
                                              TextButton(
                                                  onPressed: (){},
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color),
                                                  ),
                                                  child: Text(' Edit ',style: TextStyle(color: Colors.white),)
                                              ),
                                              SizedBox(width: 4,),
                                              TextButton(
                                                  onPressed: (){},
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color),
                                                  ),
                                                  child: Text(' Log ',style: TextStyle(color: Colors.white),)
                                              ),
                                            ],
                                          ),
                                          */
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
