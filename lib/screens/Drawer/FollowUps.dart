import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/Drawer/FollowUps_Chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import 'package:image_picker/image_picker.dart';



class Followups extends StatefulWidget {
  @override
  _FollowupsState createState() => _FollowupsState();
}

class _FollowupsState extends State<Followups> {

  List<String> Outletlist = [];
  List<String> Outlet_id_list = [];
  List<dynamic> followups = [];
  final TextEditingController _messageController = TextEditingController();
  File? _image;


  Future<void> GetOutlets_list() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(Uri.parse('http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));
    print('http://151.106.17.246:8080/bycobridgeApis/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> sizeList = data.map((item) => item['name'].toString()).toList();
      List<String> idList = data.map((item) => item['id'].toString()).toList();
      setState(() {
        Outletlist = sizeList;
        Outlet_id_list = idList;
      });
      await fetchData();
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var department_id = prefs.getString("department_id");
    var department_name = prefs.getString("department_name");
    print(department_name);
    String outletIdString = Outlet_id_list.toString();
    String cleanedString = outletIdString.replaceAll('[', '').replaceAll(']', '');
    final url = Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_all_followups.php?key=03201232927&dpt_id=$department_id&dealers=$cleanedString');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        followups = data;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> _submitData(followup) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("Id");
    var request = http.MultipartRequest('POST', Uri.parse('http://151.106.17.246:8080/bycobridgeApis/update/close_followup_chase.php'));
    request.fields.addAll({
      'user_id': '$userId',
      'action_id': '$followup',
      'message_des': _messageController.text,
    });

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'action_file', _image!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      // Successful submission
      print('Data submitted successfully');
      fetchData();

    } else {
      // Error handling
      print('Failed to submit data');
    }
  }

  Future<File?> _getImagefromgallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      return _image;
    } else {
      return null; // Return null if no image is picked
    }
  }
  Future<File?> _getImagefromcamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      return _image;
    } else {
      return null; // Return null if no image is picked
    }
  }

  @override
  void initState() {
    super.initState();
    GetOutlets_list();
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
          'Followup',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Constants.secondary_color,
              fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: followups.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: followups.length,
          itemBuilder: (context, index) {
            var followup = followups[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PUMP NAME ${followup['dpt_name']}"),
                      Text('Category: ${followup['cat_name']}'),
                      Text('Question: ${followup['ques_name']}'),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Close Followup'),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return SingleChildScrollView(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width / 2,
                                            child: Column(
                                              children: <Widget>[
                                                _image == null
                                                    ? Text('No image selected.')
                                                    : Image.file(
                                                  _image!,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        final pickedImage = await _getImagefromcamera();
                                                        setState(() {
                                                          _image = pickedImage;
                                                        });
                                                      },
                                                      icon: Icon(Icons.camera_alt),
                                                    ),
                                                    IconButton(
                                                      onPressed: () async {
                                                        final pickedImage = await _getImagefromgallery();
                                                        setState(() {
                                                          _image = pickedImage;
                                                        });
                                                      },
                                                      icon: Icon(Icons.image),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                TextField(
                                                  controller: _messageController,
                                                  decoration: InputDecoration(labelText: 'Message'),
                                                  minLines: 1,
                                                  maxLines: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_messageController.text.isNotEmpty && _image != null && _image!.path.isNotEmpty) {
                                            await _submitData(followup['id']);
                                            Navigator.of(context).pop();
                                            setState(() {
                                              _image = null;
                                              _messageController.clear();
                                            });
                                          }
                                          else{
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Error'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        Text('Please provide both an image and a message.'),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              ).then((_) {
                                // This block will be executed after the dialog is dismissed
                                setState(() {
                                  _image = null;
                                  _messageController.clear();
                                });
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color),
                            ),
                            child: Row(
                              children: [
                                Text('Close followup ', style: TextStyle(color: Constants.primary_color)),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),
                          TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => FollowupChat(followupId: '${followup['id']}',),),);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Constants.secondary_color), // Set your desired background color here
                              ),
                              child: Row(
                                children: [
                                  Text(' Chat',style: TextStyle(color: Constants.primary_color),),
                                  Icon(Icons.chevron_right,color: Constants.primary_color,),
                                ],
                              )
                          ),
                        ],
                      )
                      /*
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Descriptions',
                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust the padding values as needed
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                        ), // Add this line to include a border
                                      ),
                                    )
                                ),
                                SizedBox(width: 10,),
                                Icon(Icons.camera_alt),
                              ],
                            ),
                            TextButton(onPressed: (){}, child: Text('Submit'))
                          ],
                        ),
                      )
                      */
                    ],
                  ),
                )
              ),
            );
          },
        ),
      ),
    );
  }
}