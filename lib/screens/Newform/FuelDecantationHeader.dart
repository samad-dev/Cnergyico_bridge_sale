import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../utils/constants.dart';
import 'FuelDecantationAudit .dart';

class FuelDecantationHeader extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const FuelDecantationHeader(
      {Key? key,
        required this.dealer_id,
        required this.inspectionid,
        required this.dealer_name,
        required this.formId})
      : super(key: key);

  @override
  _FuelDecantationHeaderState createState() => _FuelDecantationHeaderState(
      dealer_id, inspectionid, dealer_name, formId);
}

class _FuelDecantationHeaderState extends State<FuelDecantationHeader> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  _FuelDecantationHeaderState(
      this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  TextEditingController dateController = TextEditingController();
  List<TextEditingController> textControllers =
  List.generate(8, (_) => TextEditingController()); // 8 is the total number of text fields

  bool isAccurate = true;
  late Map<String, dynamic> item = {};
  late List<String> formattedData;

  @override
  void initState() {
    super.initState();
    // Set the current date to the date controller
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getDealerInfo();
  }

  Future<void> getDealerInfo() async {
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/get/dealer_profile.php?key=03201232927&id=${widget.dealer_id}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        List<dynamic> dataList = json.decode(response.body);

        if (dataList.isNotEmpty) {
          // Extract the first item from the list
          Map<String, dynamic> data = Map<String, dynamic>.from(dataList.first);
          setState(() {
            item = data;
          });
          print(item);
        } else {
          throw Exception('Empty response');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load dealer info');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != textControllers[1].text) {
      setState(() {
        textControllers[1].text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectResolvedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != textControllers[3].text) {
      setState(() {
        textControllers[3].text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  bool validateFields() {
    // Check if all required fields are filled
    return textControllers[0].text.isNotEmpty &&
        textControllers[2].text.isNotEmpty &&
        textControllers[4].text.isNotEmpty &&
        textControllers[5].text.isNotEmpty &&
        textControllers[6].text.isNotEmpty &&
        textControllers[7].text.isNotEmpty &&
        textControllers[1].text.isNotEmpty &&
        textControllers[3].text.isNotEmpty;
  }
  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Incomplete Form"),
          content: Text("Please fill in all the required fields."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void createAndPrintJson() {
    List<Map<String, String>> jsonData = [
      {"label": "Date", "answer": dateController.text},
      {"label": "Station Name", "answer": item["name"]},
      {"label": "City", "answer": item["city"]},
      {"label": "TL Reg.No.", "answer": textControllers[0].text},
      {"label": "Driver Name", "answer": textControllers[2].text},
      {"label": "Byco Invoice/DN No", "answer": textControllers[4].text},
      {"label": "TL Arrival Time", "answer": textControllers[1].text},
      {"label": "TL Departure Time", "answer": textControllers[3].text},
      {"label": "Capacity (Liters)", "answer": textControllers[5].text},
      {"label": "Product", "answer": textControllers[6].text},
      {"label": "Invoiced Quantity", "answer": textControllers[7].text},
      {"label": "Measured Quantity (Dip)", "answer": isAccurate ? "Accurate" : "Variance"},
    ];

    // Convert the list of maps into the desired format
    formattedData = jsonData.map((map) {
      return '{"label": "${map["label"]}", "answer": "${map["answer"]}"}';
    }).toList();

    // Print the formatted data
    print(formattedData);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text(
          'Fuel Decantation Header',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${dateController.text}'),
                  Text('Station Name: ${item["name"]}'),
                  Text('City: ${item["city"]}'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textControllers[0], // TL Reg.No.
                          decoration: InputDecoration(
                            hintText: 'TL Reg.No.',
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDueDate(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: textControllers[1], // TL Arrival Time
                              decoration: InputDecoration(
                                labelText: 'TL Arrival Time',
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textControllers[2], // Driver Name
                          decoration: InputDecoration(
                            hintText: 'Driver Name',
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectResolvedDate(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: textControllers[3], // TL Departure Time
                              decoration: InputDecoration(
                                labelText: 'TL Departure Time',
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                      controller: textControllers[4],
                      decoration:
                      InputDecoration(hintText: 'Byco Invoice/DN No')),
                  SizedBox(height: 10),
                  Text('Tanker Information'),
                  TextField(
                    controller: textControllers[5], // Capacity
                    decoration: InputDecoration(
                      hintText: 'Capacity (Liters)',
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextField(
                      controller: textControllers[6],
                      decoration: InputDecoration(hintText: 'Product')),
                  TextField(
                    controller: textControllers[7], // Invoiced Quantity
                    decoration: InputDecoration(
                      hintText: 'Invoiced Quantity',
                    ),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 10),
                  Text('Measured Quantity (Dip)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: isAccurate,
                            activeColor: Color(0xff9fce00),
                            onChanged: (value) {
                              setState(() {
                                isAccurate = value as bool;
                              });
                            },
                          ),
                          Text('Accurate'),
                          Radio(
                            value: false,
                            groupValue: isAccurate,
                            activeColor: Color(0xff9fce00),
                            onChanged: (value) {
                              setState(() {
                                isAccurate = value as bool;
                              });
                            },
                          ),
                          Text('Variance'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.secondary_color,
        onPressed: () {
          if (validateFields()) {
            createAndPrintJson();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FuelDecantationAudit(dealer_id: dealer_id, inspectionid: inspectionid, dealer_name: dealer_name, formId: formId,header: "${formattedData}"),
              ),
            );
          } else {
            showAlertDialog();
          }
        },
        child: Icon(Icons.check, color: Constants.primary_color),
      ),
    );
  }
}
