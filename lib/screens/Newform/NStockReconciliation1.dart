import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../Task_Dashboard.dart';

class ProductControllers {
  late String ProductIDs;
  List<TextEditingController> openingDipControllersltr = [];
  List<TextEditingController> closingDipControllersltr = [];
  List<TextEditingController> openingDipControllers = [];
  List<TextEditingController> closingDipControllers = [];
  TextEditingController closingDipSumController = TextEditingController();
  List<TextEditingController> openingSalesControllers = [];
  List<TextEditingController> closingSalesControllers = [];
  List<TextEditingController> salesControllers = [];
  TextEditingController closingSalesSumController = TextEditingController();
  TextEditingController totalRecieptsController = TextEditingController();
  TextEditingController bookController = TextEditingController();
  TextEditingController varianceController = TextEditingController();
  TextEditingController remarks = TextEditingController();
  TextEditingController shortageClaim = TextEditingController();
  TextEditingController variancepercentage = TextEditingController();
  TextEditingController averagedailysales = TextEditingController();
  List<Map<String, String>> _Tanks = [];
  List<Map<String, String>> _Nozzle = [];

  // Method to add a new entry to customValues
  void addCustomTanks(String id, String name, String closing,String opening,String openingdip, String closingdip ) {
    // Check if the ID already exists
    bool idExists = _Tanks.any((entry) => entry['id'] == id);

    if (!idExists) {
      _Tanks.add({"id": id,"name":name,'opening':opening, "closing": closing,'opening_dip':openingdip,"closing_dip": closingdip,});
    } else {
      // If ID already exists, update the closing value
      for (var entry in _Tanks) {
        if (entry['id'] == id) {
          entry['closing'] = closing;
          entry['opening'] = opening;
          entry['opening_dip'] = openingdip;
          entry['closing_dip'] = closingdip;
          break;
        }
      }
    }
  }
  void addCustomNozzle(String id, String name, String closing, String opening,) {
    // Check if the ID already exists
    bool idExists = _Nozzle.any((entry) => entry['id'] == id);

    if (!idExists) {
      _Nozzle.add({"id": id,"name": name,"closing": closing,"opening": opening});
    } else {
      // If ID already exists, update the closing value
      for (var entry in _Nozzle) {
        if (entry['id'] == id) {
          entry['closing'] = closing;
          entry['opening'] = opening;
          break;
        }
      }
    }
  }
}
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
  List<TextEditingController> _openingcontroller = [];
  List<TextEditingController> _Newopeningcontroller = [];
  List<TextEditingController> _Oldclosingcontroller = [];
  List<TextEditingController> _Newclosingcontroller = [];
  NStockReconciliationState(
      this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  List<String> products = [];
  List<String> products_ids = [];
  List<String> sucessfull =[];
  late String last_date;
  late String totalDays;
  Map<String, int> totalDips = {};
  Map<String, ProductControllers> productControllersMap = {};
  List<String> _isChecked = [];
  List<bool> _isCheckedb = [];
  List<Map<String, dynamic>> nozzleList =[];
  List<Map<String, dynamic>> tankList =[];

  Future<List<Map<String, dynamic>>> fetchTank() async {
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/get_dealers_tanks.php?key=03201232927&dealer_id=$dealer_id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Map<String, dynamic>> tankList = List<Map<String, dynamic>>.from(jsonList);
      print(tankList);

      // Get the first tank
      DateTime currentDate = DateTime.now();
      Map<String, dynamic> firstTank = tankList.first;
      last_date = firstTank['last_dip_date']??'$currentDate';

      DateTime lastDipDate = DateTime.parse(last_date);
      totalDays = "${currentDate.difference(lastDipDate).inDays}";

      // Iterate through each tank and sum up the dips based on the product name
      totalDips.clear();
      for (var tank in tankList) {
        String name = tank['name'];
        int currentDip = int.parse(tank['current_readings']);
        totalDips[name] = (totalDips[name] ?? 0) + currentDip;
        print('$name and ${totalDips[name]} and $currentDip');

      }
      print(totalDips);
      print("Last dip date of the first tank: $last_date");
      return tankList;
    } else {
      throw Exception('Failed to load tanks');
    }
  }
  Future<List<Map<String, dynamic>>> fetchNozzles() async {
    try {
      final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealer_id'));
      print('http://151.106.17.246:8080/bycobridgeApis/get/dealers_dispensor_nozles.php?key=03201232927&dealer_id=$dealer_id');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> result = [];

        for (var dispenser in data) {
          if (dispenser['nozels'] != null) {
            result.addAll(List<Map<String, dynamic>>.from(dispenser['nozels']));
          }
        }
        print("checkbox length: ${_isChecked.length}");
        if (_isChecked.isEmpty) {
          _isChecked = List<String>.generate(result.length, (index) => '');
          _isCheckedb = List<bool>.generate(result.length, (index) => false);
          print("checkbox length: ${_isChecked.length}");
        }
        return result;
      } else {
        throw Exception('Failed to load nozzle data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  Future<void> processTankList() async {
    List<Map<String, dynamic>> tankList = await fetchTank();
    Set<String> uniqueNames1 = Set<String>();
    for (Map<String, dynamic> tank in tankList) {
      uniqueNames1.add(tank['name']);
    }

    List<Map<String, dynamic>> nozzleList = await fetchNozzles();
    Set<String> uniqueNames2 = Set<String>();
    for (Map<String, dynamic> nozzle in nozzleList) {
      uniqueNames2.add(nozzle['product_name']);
    }

    List<Map<String, dynamic>> idList = await fetchTank();
    Set<String> productId = Set<String>();
    for (Map<String, dynamic> product in idList) {
      productId.add(product['product']);
    }

    // Finding common names
    Set<String> commonNames = uniqueNames1.intersection(uniqueNames2);

    setState(() {
      products = commonNames.toList();
      products_ids = productId.toList();
    });
    for (String product in products) {
      productControllersMap[product] = ProductControllers();
    }

    print(products);
    print('china $uniqueNames1,$uniqueNames2');
  }
  Future<void> postStockReconciliation(ProductControllers? controllers, String tanks, String nozzles) async {

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
      'product_id': '${controllers?.ProductIDs}',
      'tanks': tanks,
      'sum_of_opening': sumController(controllers!.openingDipControllersltr).text,
      'sum_of_closing': controllers.closingDipSumController.text.toString(),
      'row_id': '',
      'nozzel': nozzles,
      'total_sales': controllers.closingSalesSumController.text.toString(),
      'total_recipt': controllers.totalRecieptsController.text.toString(),
      'book_value': controllers.bookController.text.toString(),
      'variance': controllers.varianceController.text.toString(),
      'remark': controllers.remarks.text.toString(),
      'shortage_claim': controllers.shortageClaim.text.toString(),
      'variance_of_sales': controllers.variancepercentage.text.toString(),
      'average_daily_sales': controllers.averagedailysales.text.toString(),
      'last_date': last_date,
      'total_days': totalDays,
    });

    try {
      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        sucessfull.add(responseBody);
        print(responseBody);
        if(products.length == sucessfull.length){
          poststaus();
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> poststaus() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php'));
    request.fields.addAll({
      'task_id': "${widget.inspectionid}",
      'form_id': "${widget.formId}",
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: widget.dealer_id,inspectionid: widget.inspectionid,dealer_name: widget.dealer_name)),);
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
  void someFunction() async {
    nozzleList = await fetchNozzles();
    print('hellow my ${nozzleList.length}');

    int nozzlecount = nozzleList.length;
    for(int i=0;i<nozzlecount;i++)
    {
      print('SOMI'+nozzleList[i]['new_reading']);
      _openingcontroller.add(TextEditingController());
      _openingcontroller[i].value = TextEditingValue(text: nozzleList[i]['new_reading'] ?? '0',);
    }
    tankList = await fetchTank();
  }
  Future<void> runChecklist(List<String> isChecked) async {
    for (var i = 0; i < _isChecked.length; i++) {
      if(_isChecked[i]!=''){
        var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/update_nozzel_totalizer.php'));
        request.fields.addAll({
          'nozzel_id': _isChecked[i]
        });
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          print('Request $i successful: ${await response.stream.bytesToString()}');
        }
        else {
          print('Request $i failed: ${response.reasonPhrase}');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    processTankList();
    someFunction();
  }

  @override
  Widget build(BuildContext context) {
    print('My nozzle list $nozzleList');
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
            if(products.isNotEmpty)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  String product = products[index];
                  ProductControllers? controllers = productControllersMap[product];
                  controllers?.ProductIDs = products_ids[index];
                  String sum;
                  print("Samad${totalDips['Deisel']}");
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Text( product,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Opening and Closing Dips',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: tankList.length,
                                        itemBuilder: (context, index) {
                                          if(tankList[index]['name'] == product) {
                                            TextEditingController openingController = TextEditingController(
                                                text: tankList[index]['current_readings']);
                                            TextEditingController closingController = TextEditingController();
                                            TextEditingController openingdipController = TextEditingController(
                                                text: tankList[index]['current_dip']);
                                            TextEditingController closingdipController = TextEditingController();

                                            controllers
                                                ?.openingDipControllersltr
                                                .add(openingController);
                                            controllers
                                                ?.closingDipControllersltr
                                                .add(closingController);
                                            controllers?.openingDipControllers
                                                .add(openingdipController);
                                            controllers?.closingDipControllers
                                                .add(closingdipController);
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(tankList[index]['name'] == product)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Tank: ${index+1}',
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              enabled: false,
                                                              decoration: InputDecoration(
                                                                labelText: 'Opening Dip mm',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              controller: openingdipController,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: TextField(
                                                              decoration: InputDecoration(
                                                                labelText: 'Closing Dip mm',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              keyboardType: TextInputType.number,
                                                              controller: closingdipController,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              enabled: false,
                                                              decoration: InputDecoration(
                                                                labelText: 'Opening Qty in Ltrs',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              controller: openingController,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: TextField(
                                                              decoration: InputDecoration(
                                                                labelText: 'Closing Qty in Ltrs',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              keyboardType: TextInputType.number,
                                                              controller: closingController,
                                                              onChanged: (value){
                                                                print("opening");
                                                                printControllerValues(controllers!.openingDipControllersltr);
                                                                print("closing");
                                                                printControllerValues(controllers.closingDipControllersltr);
                                                                controllers.closingDipSumController.text = calculateSum(controllers.closingDipControllersltr).toString();
                                                                controllers.bookController.text = Bookvalue(controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                                controllers.varianceController.text = Variance(controllers.closingDipSumController,controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                                controllers.addCustomTanks("${tankList[index]['id']}","${tankList[index]['lorry_no']}", closingController.text.toString(),openingController.text.toString(),openingdipController.text.toString(),closingdipController.text.toString());
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          }
                                          return Container();
                                        }
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
                                                    labelText: 'Opening Stock',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: TextEditingController(text: totalDips[product].toString()),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  enabled: false,
                                                  decoration: InputDecoration(
                                                    labelText: 'Physical Stock',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  controller: controllers?.closingDipSumController,
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
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Opening and Closing Meter readings',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // FutureBuilder(
                                    //   future: fetchNozzles(),
                                    //   builder: (context, snapshot) {
                                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                                    //       return CircularProgressIndicator();
                                    //     } else if (snapshot.hasError) {
                                    //       return Text('Error: ${snapshot.error}');
                                    //     } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                                    //       return Text('No nozzles available.');
                                    //     } else {
                                    //       List<Map<String, dynamic>> nozzleList = snapshot.data as List<Map<String, dynamic>>;
                                    //       List<Map<String, dynamic>> filteredNozzles = nozzleList.where((nozzle) => nozzle['product_name'] == product).toList();
                                    //
                                    //       controllers?.openingSalesControllers.clear();
                                    //       controllers?.closingSalesControllers.clear();
                                    //       controllers?.salesControllers.clear();
                                    //
                                    //       return Column(
                                    //         children: filteredNozzles.asMap().entries.map((entry) {
                                    //           int index = entry.key + 1;
                                    //           Map<String, dynamic> nozzle = entry.value;
                                    //
                                    //           TextEditingController openingSalesController = TextEditingController(text: nozzle['new_reading']??'0');
                                    //           print(nozzle['new_reading']);
                                    //           print(nozzle);
                                    //           TextEditingController closingSalesController = TextEditingController();
                                    //           TextEditingController SalesController = TextEditingController();
                                    //
                                    //           controllers?.openingSalesControllers.add(openingSalesController);
                                    //           controllers?.closingSalesControllers.add(closingSalesController);
                                    //           controllers?.salesControllers.add(SalesController);
                                    //
                                    //           return Padding(
                                    //             padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                    //             child: Column(
                                    //               crossAxisAlignment: CrossAxisAlignment.start,
                                    //               children: [
                                    //                 Row(
                                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //                   crossAxisAlignment: CrossAxisAlignment.center,
                                    //                   children: [
                                    //                     Text(
                                    //                       'Nozzle$index: ${nozzle['name']}',
                                    //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    //                     ),
                                    //                     Checkbox(
                                    //                       value: _isChecked[index] == '' ? false : true,
                                    //                       onChanged: (bool? newValue) {
                                    //                         if(newValue == true){
                                    //                           setState(() {
                                    //                             _isChecked[index] = '${nozzle['id']}' ;
                                    //                           });
                                    //                         }else{
                                    //                           setState(() {
                                    //                             _isChecked[index] = '' ;
                                    //                           });
                                    //                         }
                                    //                       },
                                    //                     )
                                    //                   ],
                                    //                 ),
                                    //                 SizedBox(height: 10,),
                                    //                 Row(
                                    //                   children: [
                                    //                     if(_isChecked[index] == '')
                                    //                       Expanded(
                                    //                         child: TextField(
                                    //                           enabled: false,
                                    //                           decoration: InputDecoration(
                                    //                             labelText: 'Opening',
                                    //                             border: OutlineInputBorder(),
                                    //                           ),
                                    //                           controller: openingSalesController,
                                    //                         ),
                                    //                       ),
                                    //                     if(_isChecked[index] != '')
                                    //                       Expanded(
                                    //                       child: TextField(
                                    //                         enabled: true,
                                    //                         decoration: InputDecoration(
                                    //                           labelText: 'Opening',
                                    //                           border: OutlineInputBorder(),
                                    //                         ),
                                    //                         controller: openingSalesController,
                                    //                       ),
                                    //                     ),
                                    //                     SizedBox(width: 8),
                                    //                     Expanded(
                                    //                       child: TextField(
                                    //                         decoration: InputDecoration(
                                    //                           labelText: 'Closing',
                                    //                           border: OutlineInputBorder(),
                                    //                         ),
                                    //                         keyboardType: TextInputType.number,
                                    //                         controller: closingSalesController,
                                    //                         onChanged: (value){
                                    //                           print("opening sales");
                                    //                           printControllerValues(controllers!.openingSalesControllers);
                                    //                           print("closing sales");
                                    //                           printControllerValues(controllers.closingSalesControllers);
                                    //                           print("sales");
                                    //                           printControllerValues(controllers.salesControllers);
                                    //
                                    //                           // Calculate Sales and update SalesController
                                    //                           double openingValue = double.tryParse(openingSalesController.text.trim()) ?? 0;
                                    //                           double closingValue = double.tryParse(closingSalesController.text.trim()) ?? 0;
                                    //                           double salesValue = closingValue - openingValue;
                                    //                           SalesController.text = salesValue.toString();
                                    //                           controllers.closingSalesSumController.text = calculateSum(controllers.salesControllers).toString();
                                    //                           controllers.bookController.text = Bookvalue(controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                    //                           controllers.varianceController.text = Variance(controllers.closingDipSumController,controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                    //                           controllers.addCustomNozzle("${nozzle['id']}","${nozzle['name']}",closingSalesController.text.toString(),openingSalesController.text.toString());
                                    //                         },
                                    //                       ),
                                    //                     ),
                                    //                     SizedBox(width: 8,),
                                    //                     Expanded(
                                    //                       child: TextField(
                                    //                         enabled: false,
                                    //                         decoration: InputDecoration(
                                    //                           labelText: 'Sales',
                                    //                           border: OutlineInputBorder(),
                                    //                         ),
                                    //                         controller: SalesController,
                                    //                       ),
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           );
                                    //         }).toList(),
                                    //       );
                                    //     }
                                    //   },
                                    // ),
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: nozzleList.length,
                                        itemBuilder: (context, index) {
                                          if(nozzleList[index]['product_name'] == product) {
                                            TextEditingController openingSalesController = TextEditingController(text: nozzleList[index]['new_reading']??'0');
                                            print(nozzleList[index]['new_reading']);
                                            print(nozzleList[index]);
                                            TextEditingController closingSalesController = TextEditingController();
                                            TextEditingController SalesController = TextEditingController();
                                            controllers?.openingSalesControllers.add(openingSalesController);
                                            controllers?.closingSalesControllers.add(closingSalesController);
                                            // _openingcontroller.add(new TextEditingController());
                                            // _openingcontroller[index].value = TextEditingValue(
                                            //   text: nozzleList[index]['new_reading'] ?? '0',
                                            // );
                                            controllers?.salesControllers.add(SalesController);
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Nozzle$index: ${nozzleList[index]['name']}',
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      Checkbox(
                                                        value: _isCheckedb[index],
                                                        onChanged: (bool? newValue) {
                                                          _isCheckedb[index] = newValue!;
                                                          if(newValue == true){
                                                            setState(() {
                                                              _isChecked[index] = '${nozzleList[index]['id']}' ;
                                                            });
                                                          }else{
                                                            _openingcontroller[index].value = TextEditingValue(text: nozzleList[index]['new_reading']
                                                            );
                                                            setState(() {
                                                              _isChecked[index] = '' ;
                                                            });
                                                          }
                                                        },
                                                      )
                                                    ],
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
                                                          onChanged: (value){
                                                            print("SOMI"+value);
                                                            _openingcontroller[index].value = TextEditingValue(text: value);
                                                          },
                                                          controller: _openingcontroller[index],
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
                                                            printControllerValues(controllers!.openingSalesControllers);
                                                            print("closing sales");
                                                            printControllerValues(controllers.closingSalesControllers);
                                                            print("sales");
                                                            printControllerValues(controllers.salesControllers);

                                                            // Calculate Sales and update SalesController
                                                            double openingValue = double.tryParse(_openingcontroller[index].text.trim()) ?? 0;
                                                            double closingValue = double.tryParse(closingSalesController.text.trim()) ?? 0;
                                                            double salesValue = closingValue - openingValue;
                                                            SalesController.text = salesValue.toString();
                                                            controllers.closingSalesSumController.text = calculateSum(controllers.salesControllers).toString();
                                                            controllers.bookController.text = Bookvalue(controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                            controllers.varianceController.text = Variance(controllers.closingDipSumController,controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                            controllers.addCustomNozzle("${nozzleList[index]['id']}","${nozzleList[index]['name']}",closingSalesController.text.toString(),_openingcontroller[index].text.toString());
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
                                                  if(_isChecked[index] != '')
                                                    Column(
                                                      children: [
                                                        SizedBox(height: 10,),
                                                        Row(
                                                          children: [
                                                            if(_isChecked[index] == '')
                                                              Expanded(
                                                                child: TextField(
                                                                  enabled: false,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'Opening',
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onChanged: (value){
                                                                    print("SOMI"+value);

                                                                    _openingcontroller[index].value = TextEditingValue(
                                                                        text: value
                                                                    );
                                                                  },
                                                                  controller: _openingcontroller[index],
                                                                ),
                                                              ),
                                                            if(_isChecked[index] != '')
                                                              Expanded(
                                                                child: TextField(
                                                                  enabled: true,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'Opening',
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onChanged: (value){
                                                                    print("SOMI"+value);

                                                                    _openingcontroller[index].value = TextEditingValue(
                                                                        text: value
                                                                    );
                                                                  },
                                                                  controller: _openingcontroller[index],
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
                                                                  printControllerValues(controllers!.openingSalesControllers);
                                                                  print("closing sales");
                                                                  printControllerValues(controllers.closingSalesControllers);
                                                                  print("sales");
                                                                  printControllerValues(controllers.salesControllers);

                                                                  // Calculate Sales and update SalesController
                                                                  double openingValue = double.tryParse(_openingcontroller[index].text.trim()) ?? 0;
                                                                  double closingValue = double.tryParse(closingSalesController.text.trim()) ?? 0;
                                                                  double salesValue = closingValue - openingValue;
                                                                  SalesController.text = salesValue.toString();
                                                                  controllers.closingSalesSumController.text = calculateSum(controllers.salesControllers).toString();
                                                                  controllers.bookController.text = Bookvalue(controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                                  controllers.varianceController.text = Variance(controllers.closingDipSumController,controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                                  controllers.addCustomNozzle("${nozzleList[index]['id']}","${nozzleList[index]['name']}",closingSalesController.text.toString(),_openingcontroller[index].text.toString());
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
                                                ],
                                              ),
                                            );
                                          }
                                          return Container();
                                        }
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
                                                controller: controllers?.closingSalesSumController,
                                              ),
                                              SizedBox(height: 10,),
                                              TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Total Reciepts in LTRS',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  controller: controllers?.totalRecieptsController,
                                                  onChanged: (value){
                                                    controllers?.bookController.text = Bookvalue(controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
                                                    controllers?.varianceController.text = Variance(controllers.closingDipSumController,controllers.openingDipControllersltr,controllers.totalRecieptsController,controllers.closingSalesSumController).toString();
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
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                                controller: TextEditingController(text: totalDips[product].toString()),
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
                                                controller: controllers?.totalRecieptsController,
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
                                                controller: controllers?.closingSalesSumController,
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
                                                controller: controllers?.bookController,
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
                                                controller: controllers?.closingDipSumController,
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
                                                controller: controllers?.bookController,
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
                                                controller: controllers?.varianceController,
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
                                                controller: controllers?.remarks,
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
                                                controller: controllers?.shortageClaim,
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
                                                controller: controllers?.varianceController,
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
                                                  labelText: 'Variance as % of Sales (for the period)',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType: TextInputType.number,
                                                controller: controllers?.variancepercentage,
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
                                                  labelText: 'Average Daily Sales',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType: TextInputType.number,
                                                controller: controllers?.averagedailysales,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            if(products.isEmpty)
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(FontAwesomeIcons.circleExclamation,size: 50,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Please create Tank of Dealer or Ask Administration to do it for you",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                ),
              ),
            if(products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 8),
                child: SizedBox(
                  width: double.infinity, // This will make the button expand to the width of its parent
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirmation"),
                            content: Text("Are you sure you want to proceed? This action cannot be undone."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text("Cancel",style: TextStyle(color: Constants.secondary_color),),
                              ),
                              TextButton(
                                onPressed: () {
                                  for (int i = 0; i < products.length; i++) {
                                    String product = products[i];
                                    ProductControllers? controllers = productControllersMap[product];

                                    List<Map<String, String>>? tanks = controllers?._Tanks;
                                    List<Map<String, String>> tanksList = [];
                                    if (tanks != null) {
                                      for (var tank in tanks) {
                                        Map<String, String> tankJson = {
                                          'id': tank['id'].toString(),
                                          'name': tank['name'].toString(),
                                          'opening': tank['opening'].toString(),
                                          'closing': tank['closing'].toString(),
                                          'opening_dip': tank['opening_dip'].toString(),
                                          'closing_dip': tank['closing_dip'].toString(),
                                        };
                                        tanksList.add(tankJson);
                                      }
                                    }

                                    List<Map<String, String>>? nozzles = controllers?._Nozzle;
                                    List<Map<String, String>> nozzleList = [];
                                    if (nozzles != null) {
                                      for (var nozzle in nozzles) {
                                        Map<String, String> nozzleJson = {
                                          'id': nozzle['id'].toString(),
                                          'name': nozzle['name'].toString(),
                                          'opening': nozzle['opening'].toString(),
                                          'closing': nozzle['closing'].toString(),
                                        };
                                        nozzleList.add(nozzleJson);
                                      }
                                    }

                                    print(json.encode(tanksList));
                                    print(json.encode(nozzleList));
                                    print(controllers?.ProductIDs);
                                    postStockReconciliation(controllers,json.encode(tanksList),json.encode(nozzleList));
                                    print(_isChecked);
                                  }
                                  runChecklist(_isChecked);
                                },
                                child: Text("Confirm",style: TextStyle(color: Constants.primary_color),),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Constants.secondary_color)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Submit', style: TextStyle(color: Constants.primary_color),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Constants.secondary_color),),
                  ),
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
  double Bookvalue(openingDipControllersltr,TotalRecieptsController,closingSalesSumController) {
    double openingDipSum = calculateSum(openingDipControllersltr);
    double totalReciepts = double.tryParse(TotalRecieptsController.text) ?? 0;
    double closingSalesSum = double.tryParse(closingSalesSumController.text) ?? 0;

    double sum = openingDipSum + totalReciepts - closingSalesSum;
    return sum;
  }
  double Variance(closingDipSumController,openingDipControllersltr,TotalRecieptsController,closingSalesSumController){
    double closingDipSum = double.tryParse(closingDipSumController.text) ?? 0;
    double bookValue = Bookvalue(openingDipControllersltr,TotalRecieptsController,closingSalesSumController);

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