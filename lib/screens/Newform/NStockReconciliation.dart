import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;

class NStockReconciliation extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const NStockReconciliation(
      {Key? key,
        required this.dealer_id,
        required this.inspectionid,
        required this.dealer_name,
        required this.formId})
      : super(key: key);

  @override
  NStockReconciliationState createState() => NStockReconciliationState( dealer_id, inspectionid, dealer_name, formId);
}

class NStockReconciliationState extends State<NStockReconciliation> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;
  NStockReconciliationState(
      this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  //tanks
  List<TextEditingController> openingDipControllers = [];
  List<TextEditingController> closingDipControllers = [];
  TextEditingController closingDipSumController = TextEditingController();
  //Nozzels
  List<TextEditingController> openingSalesControllers = [];
  List<TextEditingController> closingSalesControllers = [];
  List<TextEditingController> SalesControllers = [];
  TextEditingController closingSalesSumController = TextEditingController();
  TextEditingController TotalRecieptsController = TextEditingController();
  //recipts
  TextEditingController BookController = TextEditingController();
  TextEditingController VarianceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTank();
    fetchNozzles();
  }

  Future<List<Map<String, dynamic>>> fetchTank() async {
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=41'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Map<String, dynamic>> tankList = List<Map<String, dynamic>>.from(jsonList);
      print(tankList);
      return tankList;
    } else {
      throw Exception('Failed to load tanks');
    }
  }
  Future<List<Map<String, dynamic>>> fetchNozzles() async {
    try {
      final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=41'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> result = [];

        for (var dispenser in data) {
          if (dispenser['nozels'] != null) {
            result.addAll(List<Map<String, dynamic>>.from(dispenser['nozels']));
          }
        }
        return result;
      } else {
        throw Exception('Failed to load nozzle data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<void> postStockReconciliation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var dpt_id = prefs.getString("department_id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/dealers_inspection_stock_recon.php'));

    request.fields.addAll({
      'user_id': '$user_id',
      'task_id': inspectionid,
      'form_id': formId,
      'dpt_id': '$dpt_id',
      'dealer_id': dealer_id,
      'product_id': '41',
      'tanks': '[]',
      'sum_of_opening': sumController(openingDipControllers).text,
      'sum_of_closing': closingDipSumController.text.toString(),
      'row_id': '',
      'nozzel': '[]',
      'total_sales': closingSalesSumController.text.toString(),
      'total_recipt': TotalRecieptsController.text.toString(),
      'book_value': BookController.text.toString(),
      'variance': VarianceController.text.toString(),
      'remark': '',
      'shortage_claim': '',
      'variance_of_sales': '',
      'average_daily_sales': ''
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
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
          'Stock Reconciliation',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Opening and Closing Dips',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder(
                      future: fetchTank(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                          return Text('No tanks available.');
                        } else {
                          List<Map<String, dynamic>> tankList = snapshot.data as List<Map<String, dynamic>>;
                          List<Map<String, dynamic>> filteredTanks = tankList
                              .where((tank) => tank['name'] == 'PMG')
                              .toList();

                          openingDipControllers.clear();
                          closingDipControllers.clear();

                          return Column(
                            children: filteredTanks.asMap().entries.map((entry) {
                              int index = entry.key + 1;
                              Map<String, dynamic> tank = entry.value;

                              TextEditingController openingController = TextEditingController(text: tank['current_dip']);
                              TextEditingController closingController = TextEditingController();

                              openingDipControllers.add(openingController);
                              closingDipControllers.add(closingController);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tank: $index',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              labelText: 'Opening Dip',
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: openingController,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Enter Closing Dip',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            controller: closingController,
                                            onChanged: (value){
                                              print("opening");
                                              printControllerValues(openingDipControllers);
                                              print("closing");
                                              printControllerValues(closingDipControllers);
                                              closingDipSumController.text = calculateSum(closingDipControllers).toString();
                                                BookController.text = Bookvalue().toString();
                                                VarianceController.text = Variance().toString();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Column(
                        children: [
                          Divider(),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Sum of Opening Dip',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: sumController(openingDipControllers),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Sum of Closing Dip',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: closingDipSumController,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Opening and Closing Meter readings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder(
                      future: fetchNozzles(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                          return Text('No nozzles available.');
                        } else {
                          List<Map<String, dynamic>> nozzleList = snapshot.data as List<Map<String, dynamic>>;
                          List<Map<String, dynamic>> filteredNozzles = nozzleList
                              .where((nozzle) => nozzle['product_name'] == 'PMG')
                              .toList();

                          openingSalesControllers.clear();
                          closingSalesControllers.clear();
                          SalesControllers.clear();

                          return Column(
                            children: filteredNozzles.asMap().entries.map((entry) {
                              int index = entry.key + 1;
                              Map<String, dynamic> nozzle = entry.value;

                              TextEditingController openingSalesController = TextEditingController(text: nozzle['new_reading']);
                              TextEditingController closingSalesController = TextEditingController();
                              TextEditingController SalesController = TextEditingController();

                              openingSalesControllers.add(openingSalesController);
                              closingSalesControllers.add(closingSalesController);
                              SalesControllers.add(SalesController);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${nozzle['name']} Nozzle: $index',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              labelText: 'Opening',
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: openingSalesController,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Closing',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            controller: closingSalesController,
                                            onChanged: (value){
                                              print("opening sales");
                                              printControllerValues(openingSalesControllers);
                                              print("closing sales");
                                              printControllerValues(closingSalesControllers);
                                              print("sales");
                                              printControllerValues(SalesControllers);

                                              // Calculate Sales and update SalesController
                                              double openingValue = double.tryParse(openingSalesController.text.trim()) ?? 0;
                                              double closingValue = double.tryParse(closingSalesController.text.trim()) ?? 0;
                                              double salesValue = closingValue - openingValue;
                                              SalesController.text = salesValue.toString();
                                              closingSalesSumController.text = calculateSum(SalesControllers).toString();
                                              BookController.text = Bookvalue().toString();
                                              VarianceController.text = Variance().toString();
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Expanded(
                                          child: TextField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              labelText: 'Sales',
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: SalesController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                      child: Column(
                        children: [
                          Divider(),
                          SizedBox(height: 10,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Total Sale for the Period',
                                  border: OutlineInputBorder(),
                                ),
                                controller: closingSalesSumController,
                              ),
                              SizedBox(height: 10,),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Total Reciepts in LTRS',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TotalRecieptsController,
                                onChanged: (value){
                                  BookController.text = Bookvalue().toString();
                                  VarianceController.text = Variance().toString();
                                }
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Final Analysis',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Opening Stock',
                                  border: OutlineInputBorder(),
                                ),
                                controller: sumController(openingDipControllers),
                              ),
                            ),
                            Text(" + "),
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Receipts',
                                  border: OutlineInputBorder(),
                                ),
                                controller: TotalRecieptsController,
                              ),
                            ),
                            Text(" - "),
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Sales',
                                  border: OutlineInputBorder(),
                                ),
                                controller: closingSalesSumController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(" = "),
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Book Value',
                                  border: OutlineInputBorder(),
                                ),
                                controller: BookController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Physical Stock',
                                  border: OutlineInputBorder(),
                                ),
                                controller: closingDipSumController,
                              ),
                            ),
                            Text(" - "),
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Book Stock',
                                  border: OutlineInputBorder(),
                                ),
                                controller: BookController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(" = "),
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Variance',
                                  border: OutlineInputBorder(),
                                ),
                                controller: VarianceController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Remarks',
                                  border: OutlineInputBorder(),
                                ),
                                //controller: openingSalesController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Shortage Claim for the period (TLs short received by in ltrs)',
                                  border: OutlineInputBorder(),
                                ),
                                //controller: openingSalesController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Net Gain or Loss',
                                  border: OutlineInputBorder(),
                                ),
                                controller: VarianceController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Variance as % of Sales (for the period)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Average Daily Sales',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    child: Text('Next',style: TextStyle(color: Constants.primary_color),),
                    style: ElevatedButton.styleFrom(
                      elevation: 4.0,
                      backgroundColor: Constants.secondary_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to calculate the sum of controllers
  TextEditingController sumController(List<TextEditingController> controllers) {
    double sum = 0;
    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        sum += double.parse(controller.text);
      }
    }
    return TextEditingController(text: sum.toString());
  }
  double Bookvalue() {
    double openingDipSum = calculateSum(openingDipControllers);
    double totalReciepts = double.tryParse(TotalRecieptsController.text) ?? 0;
    double closingSalesSum = double.tryParse(closingSalesSumController.text) ?? 0;

    double sum = openingDipSum + totalReciepts - closingSalesSum;
    return sum;
  }
  double Variance(){
    double closingDipSum = double.tryParse(closingDipSumController.text) ?? 0;
    double bookValue = Bookvalue();

    double sum = closingDipSum - bookValue;
    return sum;
  }
  double calculateSum(List<TextEditingController> controllers) {
    double sum = 0;
    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        sum += double.parse(controller.text);
      }
    }
    return sum;
  }
  void printControllerValues(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      print('Controller Text: ${controller.text}');
    }
  }
}
