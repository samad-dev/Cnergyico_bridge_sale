import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';


class ProductSetup extends StatefulWidget {
  final String dealer_id;
  final String dealer_name;

  const ProductSetup({Key? key, required this.dealer_id, required this.dealer_name}) : super(key: key);

  @override
  _ProductSetupState createState() => _ProductSetupState(dealer_id,dealer_name);
}

class _ProductSetupState extends State<ProductSetup> {
  final String dealer_id;
  final String dealer_name;

  _ProductSetupState(this.dealer_id, this.dealer_name);

  Future<List<dynamic>> _getDealerProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/dealers_products.php?key=03201232927&dealer_id=$dealer_id';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> sizeList = data.map((item) => item['name'].toString()).toList();
        MyProductlist = sizeList;
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
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_all_products.php?key=03201232927'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList = data.map((item) => item['name'].toString()).toList();
      List<String> idList = data.map((item) => item['id'].toString()).toList();

      // Create a copy of the productList and productIdList
      List<String> updatedProductList = List.from(sizeList);
      List<String> updatedProductIdList = List.from(idList);
      // Iterate over myProductList and remove common products from updatedProductList and corresponding indexes from updatedProductIdList
      for (String product in MyProductlist) {
        int index = updatedProductList.indexOf(product);
        if (index != -1) {
          updatedProductList.removeAt(index);
          updatedProductIdList.removeAt(index);
        }
      }
      setState(() {
        Productlist = updatedProductList;
        Product_id_list = updatedProductIdList;
      });
      // Print the updated lists
      print("Updated Product List: $updatedProductList");
      print("Updated Product ID List: $updatedProductIdList");
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> createDealerProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var request = http.MultipartRequest('POST',
        Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_products.php'));
    request.fields.addAll({
      'user_id': '$id',
      'products_name': '$selectedProductID',
      'dealer_id': '$dealer_id',
      'row_id': '',
      'from_date': '0',
      'to_date': '0',
      'indent_price': '0',
      'nozel_price': '0',
      'products_description': 'Done'
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        // Refresh the page after successful data posting
        setState(() {});
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  List<String> Productlist = [];
  List<String> MyProductlist = [];
  List<String> Product_id_list = [];
  String? selectedProduct;
  String? selectedProductID;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Product Setup',
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
                            SizedBox(height: 20.0),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return TextDropdownFormField(
                                  options: Productlist,
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
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Close dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(color: Constants.secondary_color),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  ElevatedButton(
                                    onPressed: () async {
                                       await createDealerProduct();
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
              future: _getDealerProducts(),
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
                                      children: [
                                        Text('From: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${product['from']}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('To: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('${product['to']}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Indent Price: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text('${product['indent_price']}PKR'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Nozel Price: ',style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text('${product['nozel_price']}PKR'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('${product['update_time']}'),
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
