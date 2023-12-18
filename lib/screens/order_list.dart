import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/create_order.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/profile.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

class Orders extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _OrdersState createState() => _OrdersState();
}


class _OrdersState extends State<Orders> {
  //created variable:
  List<Map<String, dynamic>> order_list = [];
  List<Map<String, dynamic>> filteredData = [];
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    Orders_list();
  }

  Future<List<Map<String, dynamic>>?> Orders_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/user_all_orders.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        order_list = List<Map<String, dynamic>>.from(data);
        filteredData = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> createInvoice(BuildContext context, String orderNumber) async {
    final List<Map<String, dynamic>>? data = await filteredData;

    if (data != null && data.isNotEmpty) {
      // Filter data based on the orderNumber
      final List<Map<String, dynamic>> filteredData =
      data.where((order) => order['id'].toString() == orderNumber).toList();

      if (filteredData.isEmpty) {
        // Handle the case where no data is found for the orderNumber
        print('No data found for order number: $orderNumber');
        return;
      }

      final pdf = pw.Document();

      final Uint8List logoImage =
      (await rootBundle.load('assets/images/puma_logo.svg'))
          .buffer
          .asUint8List();

      // Generate PDF content
      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          final String orderID = filteredData[0]["id"]?.toString() ?? "";
          final String totalAmount =
              filteredData[0]["total_amount"]?.toString() ?? "";
          final String dateTime = filteredData[0]["created_at"] ?? "";
          final String type = filteredData[0]["type"] ?? "";

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 1,
                text: 'INVOICE',
                textStyle: pw.TextStyle(fontSize: 28),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Invoice#: $orderID',
                style: pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.Text('Total Amount: PKR. $totalAmount'),
              pw.Text('Date and Time: $dateTime'),
              pw.Text('Type: $type'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Product', 'Quantity', 'Indent Price', 'Amount'],
                  // Assuming product details are in the "products" key in the data
                  for (var product
                  in json.decode(filteredData[0]['product_json']))
                    if (product['quantity'] != null &&
                        product['quantity'] != '0')
                      <String>[
                        product['product_name'] ?? "", // Add null check
                        product['quantity']?.toString() ?? "", // Add null check
                        product['indent_price']?.toString() ??
                            "", // Add null check
                        product['amount']?.toString() ?? "", // Add null check
                      ],
                ],
                border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#FFFFFF')), // Remove border
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#CCCCCC'),
                ),
                cellStyle: pw.TextStyle(
                  color: PdfColor.fromHex('#000000'), // Black color in cells
                ),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ));

      // Get the document bytes
      final Uint8List pdfBytes = await pdf.save();

      // Create a temporary file for the PDF
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final tempFile = File('$tempPath/invoice.pdf');
      await tempFile.writeAsBytes(pdfBytes);

      // Open the PDF
      if (tempFile.existsSync()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFView(filePath: tempFile.path),
          ),
        );
      }
    }
  }
  void filterData(String query) {
    setState(() {
      searchQuery = query;
      if (query.isNotEmpty) {
        filteredData =
            order_list.where((order) => order['name'].contains(query)).toList();
      } else {
        filteredData = order_list;
      }
    });
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
          automaticallyImplyLeading: false,
          backgroundColor: Constants.primary_color,
          elevation: 10,
          title: Text(
            '  Orders',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Colors.white,
                fontSize: 16),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Create_Order()),
                  );
                },
                icon: Icon(
                  // <-- Icon
                  Icons.add,
                  size: 24.0,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff3B8D5A), // Background color
                ),
                label: Text(
                  'Create Order',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ), // <-- Text
              ),
            ),
          ],
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
                      hintText: 'Search using Order Number',
                      hintStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          color: Color(0xff12283D),
                          fontSize: 16),
                      border: InputBorder.none),
                  onChanged: (value) {
                    filterData(value.toUpperCase());
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: filteredData.length,
                  itemBuilder: (BuildContext context, int index2) {
                    if (searchQuery.isNotEmpty) {
                      filteredData = order_list
                          .where((order) =>
                          order['name'].contains(searchQuery))
                          .toList();
                    } else {filteredData = order_list;}
                    final orderNumber = filteredData[index2]["id"];
                    final totalAmount = filteredData[index2]['total_amount'];
                    final type = filteredData[index2]['type'];
                    final created_at = filteredData[index2]['created_at'];
                    final productJsonString = filteredData[index2]["product_json"];
                    final status = filteredData[index2]["status"];
                    final current_status = filteredData[index2]["current_status"];
                    final name=filteredData[index2]["name"];
                    final List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(json.decode(productJsonString));
                  return Card(
                    elevation: 10,
                    color: Color(0xffffffff),
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order#: $orderNumber',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff12283D),
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '$name',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff12283D),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'PKR. $totalAmount',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff3B8D5A),
                                          fontSize: 12,
                                        ),
                                      ),

                                      Container(
                                        width: MediaQuery.of(context).size.width/1.18,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$created_at',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w300,
                                                fontStyle: FontStyle.normal,
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            TextButton.icon(
                                              // <-- TextButton
                                              onPressed: () {
                                                createInvoice(context, orderNumber);
                                              },
                                              icon: Icon(
                                                FluentIcons
                                                    .drawer_arrow_download_24_regular,
                                                size: 16.0,
                                                color: Color(0xff12283D),
                                              ),
                                              label: Text(
                                                'Invoice',
                                                style:
                                                GoogleFonts.montserrat(
                                                  fontWeight:
                                                  FontWeight.w300,
                                                  fontStyle:
                                                  FontStyle.normal,
                                                  color: Color(0xff12283D),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        )),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x8ca9a9a9),
                blurRadius: 20,
              ),
            ],
          ),
          child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              unselectedItemColor: Color(0xff8d8d8d),
              unselectedLabelStyle:
                  const TextStyle(color: Color(0xff8d8d8d), fontSize: 14),
              unselectedFontSize: 14,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              selectedIconTheme: IconThemeData(
                color: Constants.primary_color,
              ),
              type: BottomNavigationBarType.shifting,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.home_32_regular,
                      size: 20,
                    ),
                    label: 'Home',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                    icon: Icon(
                      FluentIcons.weather_sunny_16_regular,
                      size: 20,
                    ),
                    label: 'Orders',
                    backgroundColor: Colors.white),
                BottomNavigationBarItem(
                  icon: Icon(
                    FluentIcons.inprivate_account_16_regular,
                    size: 20,
                  ),
                  label: 'Profile',
                  backgroundColor: Colors.white,
                ),
              ],
              selectedItemColor: Constants.primary_color,
              iconSize: 40,
              onTap: _onItemTapped,
              elevation: 15),
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // if (_selectedIndex == 1) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => Orders()),
    //   );
    // }
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
    }
  }
}
