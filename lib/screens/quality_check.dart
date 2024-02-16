import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Task_Dashboard.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'Drawer/outlets_list.dart';

class Quality_check extends StatefulWidget {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String? formId;

  const Quality_check({
    Key? key,
    required this.dealer_id,
    required this.inspectionid,
    required this.dealer_name,
    required this.formId,
  }) : super(key: key);

  @override
  Quality_checkState createState() =>
      Quality_checkState(dealer_id, inspectionid, dealer_name, formId);
}

class Quality_checkState extends State<Quality_check> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String? formId;

  Quality_checkState(
      this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  late File image;
  TextEditingController commentController = TextEditingController();
  bool isOkButtonSelected = false;
  bool isNotOkButtonSelected = false;
  late String options;

  @override
  void initState() {
    super.initState();
    createDummyFile();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Icon(Icons.collections),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Icon(Icons.camera_alt),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      final pickedImage = await picker.pickImage(
        source: pickedFile,
      );

      setState(() {
        if (pickedImage != null) {
          image = File(pickedImage.path);
        }
      });
    }
  }
  Future<void> _postDataToApi(String option) async {
    final Uri apiUrl =
    Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/dealer_inspection_quality_check.php');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    var dpt_id = prefs.getString("department_id");

    // Prepare the image file for upload
    var request = http.MultipartRequest('POST', apiUrl)
      ..fields['user_id'] = user_id!
      ..fields['task_id'] = inspectionid
      ..fields['form_id'] = formId!
      ..fields['dealer_id'] = dealer_id
      ..fields['response'] = option
      ..fields['row_id'] = ''
      ..fields['dpt_id'] = dpt_id!
      ..fields['description'] = commentController.text
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        // Handle successful response
        print('Post request successful');
        print('Response: ${await response.stream.bytesToString()}');
        await poststaus();
        Navigator.of(context).pushReplacement(
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
      } else {
        // Handle error response
        print('Error during post request. Status code: ${response.statusCode}');
        print('Error message: ${await response.stream.bytesToString()}');
      }
    } catch (error) {
      // Handle errors during the request
      print('Error during post request: $error');
    }
  }
  void createDummyFile() {
    // Create a temporary directory for storing the dummy file
    Directory tempDir = Directory.systemTemp;
    // Create a dummy file with a unique name
    image = File('${tempDir.path}/dummy_image.jpg');
    // You can write some content to the file if needed
    image.writeAsStringSync('Dummy Image Content');
  }
  Future<void> poststaus() async {
    final String apiUrl =
        'http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php';
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/inspection/update_department_users_from_status.php'));
    request.fields.addAll({
      'task_id': inspectionid,
      'form_id': "$formId",
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
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
        title: Text(
          'Quality Check',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 10),
                    child: Text('Is Quality OK ?'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: commentController,
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: 'Add your comments here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Constants.secondary_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          minimumSize: Size(
                              MediaQuery.of(context).size.width / 1.2, 38),
                        ),
                        onPressed: () => _getImage(),
                        child: Text('Upload Image',
                            style: TextStyle(color: Constants.primary_color)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor: isOkButtonSelected
                                ? Colors.green
                                : Constants.secondary_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            minimumSize:
                            Size(MediaQuery.of(context).size.width / 2.5, 40),
                          ),
                          onPressed: () {
                            setState(() {
                              isOkButtonSelected = true;
                              isNotOkButtonSelected = false;
                              options = 'Yes';
                            });
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: isOkButtonSelected
                                  ? Colors.white
                                  : Constants.primary_color,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4.0,
                            backgroundColor: isNotOkButtonSelected
                                ? Colors.red
                                : Constants.secondary_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            minimumSize:
                            Size(MediaQuery.of(context).size.width / 2.5, 40),
                          ),
                          onPressed: () {
                            setState(() {
                              isOkButtonSelected = false;
                              isNotOkButtonSelected = true;
                              options = 'No';
                            });
                          },
                          child: Text(
                            'Not OK',
                            style: TextStyle(
                              color: isNotOkButtonSelected
                                  ? Colors.white
                                  : Constants.primary_color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOkButtonSelected || isNotOkButtonSelected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 4.0,
                              backgroundColor: Constants.secondary_color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize:
                              Size(MediaQuery.of(context).size.width / 2.5, 40),
                            ),
                            onPressed: () {
                              _postDataToApi(options);
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(color: Constants.primary_color),
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
      ),
    );
  }
}
