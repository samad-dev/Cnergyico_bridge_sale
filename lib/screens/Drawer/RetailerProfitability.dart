import 'dart:convert';

import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Task_Dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../home.dart';

class RetailerProfitability extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  const RetailerProfitability({Key? key, required this.dealer_id, required this.inspectionid, required this.dealer_name, required this.formId}) : super(key: key);

  @override
  _RetailerProfitabilityState createState() => _RetailerProfitabilityState(dealer_id, inspectionid, dealer_name, formId);
}

class _RetailerProfitabilityState extends State<RetailerProfitability> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  _RetailerProfitabilityState(this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  List<TextEditingController> cfControllers = [];
  List<TextEditingController> sfControllers = [];
  List<TextEditingController> dfControllers = [];
  List<String> rowTitles = [
    'Working Capital', 'Volume-Ltr', 'Lube Sales', 'MF Dealer Margin Per Liter', 'Lube Dealer Margin Per Liter',
    'MF Margin', 'LBS Margin', 'Total Margin', 'Incentive', 'Rebate', 'Lease Rental', 'CNG', 'Car Wash', 'Shop',
    'Tyre Shop', 'Others NFR Income', 'NFR-1-Rs', 'NFR-2-Rs', 'NFR-3-Rs', 'NFR Income', 'Revenue', 'Salaries',
    'Utility', 'Genset Exp-Diesel', 'FC', 'Misc', 'Net Income',
  ];
  bool isLoading = false;
  String choice = ''; // Variable to store the selected value

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < rowTitles.length; i++) {
      cfControllers.add(TextEditingController());
      sfControllers.add(TextEditingController());
      dfControllers.add(TextEditingController());
    }
  }

  void multiplyStrings(String str1, String str2, TextEditingController controller) {
    double? num1 = double.tryParse(str1);
    double? num2 = double.tryParse(str2);
    if (num1 != null && num2 != null) {
      double result = num1 * num2;
      String formattedResult = result.toStringAsFixed(2); // Formats the result to two decimal places
      controller.text = formattedResult;
    }
  }
  void SumStrings(String str1, String str2, TextEditingController controller) {
    double? num1 = double.tryParse(str1);
    double? num2 = double.tryParse(str2);
    if (num1 != null && num2 != null) {
      double result = num1 + num2;
      String formattedResult = result.toStringAsFixed(2); // Formats the result to two decimal places
      controller.text = formattedResult;
    }
  }
  void calculateTax(String incomeStr, TextEditingController controller) {
    double income = double.tryParse(incomeStr) ?? 0;
    if (income < 100000) {
      controller.text = '0';
    } else if (income < 175000) {
      controller.text = '${income * 0.35}';
    } else if (income < 225000) {
      controller.text = '${income * 0.5}';
    } else if (income < 360000) {
      controller.text = '${income * 0.65}';
    } else {
      controller.text = '${income * 0.8}';
    }
  }
  void SumList(List<TextEditingController> controllers, int fromIndex, int toIndex,TextEditingController controller) {
    double sum = 0;
    for (int i = fromIndex; i <= toIndex; i++) {
      TextEditingController controller = controllers[i];
      double value = double.tryParse(controller.text) ?? 0;
      sum += value;
    }
    controller.text = '$sum';
  }
  void SumList_ADD(List<TextEditingController> controllers, int fromIndex, int toIndex, String str1, TextEditingController controller) {
    double sum = 0;
    double? num1 = double.tryParse(str1);
    for (int i = fromIndex; i <= toIndex; i++) {
      TextEditingController controller = controllers[i];
      double value = double.tryParse(controller.text) ?? 0;
      sum += value;
    }
    sum= sum + num1!;
    print(sum);
    controller.text = '$sum';
  }
  void sumAndSave(List<TextEditingController> controllers) {
    if (controllers.length >= 27) {
      double sum = 0.0;
      for (int i = 21; i <= 25; i++) {
        double value = double.tryParse(controllers[i].text) ?? 0.0;
        sum += value;
      }
      double num1 = double.tryParse(controllers[20].text)?? 0.0;
      double num2 = num1 - sum;
      controllers[26].text = num2.toStringAsFixed(2);
    } else {
      print("Error: Insufficient elements in the list of controllers.");
    }
  }

  String generateJson() {
    isLoading = true;
    List<Map<String, dynamic>> data = [];
    for (int index = 0; index < rowTitles.length-1; index++) {
      Map<String, dynamic> rowData = {
        "retailer_profitability": rowTitles[index],
        "cf": cfControllers[index].text.isEmpty ? '0' : cfControllers[index].text,
        "sf": sfControllers[index].text.isEmpty ? '0' : sfControllers[index].text,
        "df": dfControllers[index].text.isEmpty ? '0' : dfControllers[index].text,
      };
      data.add(rowData);
    }
    return jsonEncode(data);
  }
  Future<void> postDataToServer(String datalist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var url = Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_dealers_profitabilty.php');
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll({
      'dealer_id': '$dealer_id',
      'row_id': '',
      'cf_total': cfControllers[26].text.isEmpty?'0':cfControllers[26].text,
      'sf_total': sfControllers[26].text.isEmpty?'0':sfControllers[26].text,
      'df_total': dfControllers[26].text.isEmpty?'0':dfControllers[26].text,
      'data': datalist,
      'user_id': '$user_id',
      'task_id': '$inspectionid',
      'form_id': '$formId',
    });

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print('Failed with status code: ${response.statusCode}');
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
        MaterialPageRoute(builder: (context) => TaskDashboard(dealer_id: dealer_id,inspectionid: inspectionid,dealer_name: dealer_name)),);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        title: Text(
            'Retailer Profitability',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Constants.secondary_color,
              fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: TextDropdownFormField(
                options: const ['CF', 'SF', 'DF'],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                  labelText: "Select Option",
                ),
                dropdownHeight: 100,
                onChanged: (dynamic value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      choice =value;
                    });
                  }
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(rowTitles.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(choice.isNotEmpty)
                          Padding(
                          padding: const EdgeInsets.only(top: 4, left: 8, bottom: 4),
                          child: Text(
                            rowTitles[index],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            children: [
                              if(choice=='CF')
                                Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: cfControllers[index],
                                    keyboardType: TextInputType.number,
                                    enabled: index != 5 && index != 6 && index != 7 && index != 8 && index != 19 && index != 20 && index != 24 && index != 25 && index != 26,
                                    decoration: InputDecoration(
                                      labelText: 'CF',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if(index == 0){
                                        double? num1 = double.tryParse(cfControllers[index].text);
                                        cfControllers[24].text='${(num1! * 0.25)/12}';
                                      }
                                      else if(index == 1){
                                        calculateTax(cfControllers[1].text,cfControllers[8]);
                                      }
                                      else if (index == 3 || index == 1) {
                                        // Ensure both CF and SF controllers have non-empty values
                                        if (cfControllers[3].text.isNotEmpty && cfControllers[1].text.isNotEmpty) {
                                          multiplyStrings(cfControllers[3].text, cfControllers[1].text, cfControllers[5]);
                                          if (cfControllers[5].text.isNotEmpty && cfControllers[6].text.isNotEmpty) {
                                            SumStrings(cfControllers[5].text, cfControllers[6].text, cfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index == 4 || index == 2) {
                                        if (cfControllers[4].text.isNotEmpty && cfControllers[2].text.isNotEmpty) {
                                          multiplyStrings(cfControllers[4].text, cfControllers[2].text, cfControllers[6]);
                                          if (cfControllers[5].text.isNotEmpty && cfControllers[6].text.isNotEmpty) {
                                            SumStrings(cfControllers[5].text, cfControllers[6].text, cfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index==11||index==12||index==13||index==14||index==15||index==16||index==17||index==18) {
                                        SumList(cfControllers, 11, 18,cfControllers[19]);
                                        SumList_ADD(cfControllers, 7, 10,cfControllers[19].text,cfControllers[20]);
                                        double? num1 = double.tryParse(cfControllers[20].text);
                                        cfControllers[25].text = '${num1! * 0.02}';
                                        sumAndSave(cfControllers);
                                      }
                                      else if(index==21||index==22||index==23){
                                        sumAndSave(cfControllers);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              if(choice=='SF')
                                Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: sfControllers[index],
                                    keyboardType: TextInputType.number,
                                    enabled: index != 5 && index != 6 && index != 7 && index != 8&& index != 9 && index != 19 && index != 20 && index != 24 && index != 25 && index != 26,
                                    decoration: InputDecoration(
                                        labelText: 'SF',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if(index == 0){
                                        double? num1 = double.tryParse(sfControllers[index].text);
                                        sfControllers[24].text='${(num1! * 0.25)/12}';
                                      }
                                      else if(index == 1){
                                        calculateTax(sfControllers[1].text,sfControllers[8]);
                                        double? num1 = double.tryParse(sfControllers[1].text);
                                        sfControllers[9].text = '${num1!*0.5}';

                                      }
                                      else if (index == 3 || index == 1) {
                                        // Ensure both CF and SF controllers have non-empty values
                                        if (sfControllers[3].text.isNotEmpty && sfControllers[1].text.isNotEmpty) {
                                          multiplyStrings(sfControllers[3].text, sfControllers[1].text, sfControllers[5]);
                                          if (sfControllers[5].text.isNotEmpty && sfControllers[6].text.isNotEmpty) {
                                            SumStrings(sfControllers[5].text, sfControllers[6].text, sfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index == 4 || index == 2) {
                                        if (sfControllers[4].text.isNotEmpty && sfControllers[2].text.isNotEmpty) {
                                          multiplyStrings(sfControllers[4].text, sfControllers[2].text, sfControllers[6]);
                                          if (sfControllers[5].text.isNotEmpty && sfControllers[6].text.isNotEmpty) {
                                            SumStrings(sfControllers[5].text, sfControllers[6].text, sfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index==11||index==12||index==13||index==14||index==15||index==16||index==17||index==18) {
                                        SumList(sfControllers, 11, 18,sfControllers[19]);
                                        SumList_ADD(sfControllers, 7, 10,sfControllers[19].text,sfControllers[20]);
                                        double? num1 = double.tryParse(sfControllers[20].text);
                                        sfControllers[25].text = '${num1! * 0.02}';
                                      }
                                      else if(index==21||index==22||index==23){
                                        sumAndSave(sfControllers);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              if(choice=='DF')
                                Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: dfControllers[index],
                                    keyboardType: TextInputType.number,
                                    enabled: index != 5 && index != 6 && index != 7 && index != 8&& index != 9 && index != 19 && index != 20 && index != 24 && index != 25 && index != 26,
                                    decoration: InputDecoration(
                                        labelText: 'DF',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if(index == 0){
                                        double? num1 = double.tryParse(dfControllers[index].text);
                                        dfControllers[24].text='${(num1! * 0.25)/12}';
                                      }
                                      else if(index == 1){
                                        calculateTax(dfControllers[1].text,dfControllers[8]);
                                        double? num1 = double.tryParse(dfControllers[1].text);
                                        dfControllers[9].text = '${num1!*0.5}';
                                      }
                                      else if (index == 3 || index == 1) {
                                        // Ensure both CF and SF controllers have non-empty values
                                        if (dfControllers[3].text.isNotEmpty && dfControllers[1].text.isNotEmpty) {
                                          multiplyStrings(dfControllers[3].text, dfControllers[1].text, dfControllers[5]);
                                          if (dfControllers[5].text.isNotEmpty && dfControllers[6].text.isNotEmpty) {
                                            SumStrings(dfControllers[5].text, dfControllers[6].text, dfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index == 4 || index == 2) {
                                        if (dfControllers[4].text.isNotEmpty && dfControllers[2].text.isNotEmpty) {
                                          multiplyStrings(dfControllers[4].text, dfControllers[2].text, dfControllers[6]);
                                          if (dfControllers[5].text.isNotEmpty && dfControllers[6].text.isNotEmpty) {
                                            SumStrings(dfControllers[5].text, dfControllers[6].text, dfControllers[7]);
                                          }
                                        }
                                      }
                                      else if (index==11||index==12||index==13||index==14||index==15||index==16||index==17||index==18) {
                                        SumList(dfControllers, 11, 18,dfControllers[19]);
                                        SumList_ADD(dfControllers, 7, 10,dfControllers[19].text,dfControllers[20]);
                                        double? num1 = double.tryParse(dfControllers[20].text);
                                        dfControllers[25].text = '${num1! * 0.02}';
                                      }
                                      else if(index==21||index==22||index==23){
                                        sumAndSave(dfControllers);
                                      }
                                    },
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
              }),
            ),
            if(choice.isNotEmpty)
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 4.0,
                  backgroundColor: Constants.secondary_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(200, 50), // Set your preferred width and height
                ),
                onPressed: isLoading
                    ? null // Disable button while loading
                    : () async {
                  setState(() {
                    isLoading = true;
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Verify Data'),
                          content: Text('Are you sure you want to send this data?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                String datalist = await generateJson();
                                print(datalist);
                                await postDataToServer(datalist);
                                poststaus();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text('Send'),
                            ),
                          ],
                        );
                      });
                },
                child: isLoading
                    ? CircularProgressIndicator() // Show loader
                    : Text('Submit', style: TextStyle(color: Constants.primary_color)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    for (var controller in cfControllers) {
      controller.dispose();
    }
    for (var controller in sfControllers) {
      controller.dispose();
    }
    for (var controller in dfControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
