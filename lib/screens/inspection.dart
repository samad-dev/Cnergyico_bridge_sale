import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:im_stepper/stepper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';
import 'Task_Dashboard.dart';
import 'home.dart';

class CaseData {
  String id;
  String title;
  List<String> questionIds;
  List<String> questions;
  List<bool?> responses;
  List<List<String>> imagePaths;

  CaseData({
    required this.id,
    required this.questionIds,
    required this.title,
    required this.questions,
    required this.responses,
    required this.imagePaths,
  });
}

class Inspection extends StatefulWidget {
  final String? dealer_id;
  final String? inspectionid;
  final String? dealer_name;

  const Inspection({Key? key, this.dealer_id, this.inspectionid,this.dealer_name}) : super(key: key);

  @override
  _InspectionState createState() => _InspectionState();
}

class _InspectionState extends State<Inspection> {
  int activeStep = 0;
  List<CaseData> cases = [];
  List<Map<String, dynamic>> postedDataList = [];
  TextEditingController commentController = TextEditingController();
  late String signatureImagePath;
  List<Map<String, dynamic>> imagesToPost = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> sendstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString("Id");
    final apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/update_inspections_status.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'task_id':widget.inspectionid,
          'row_id': '',
          'table_name':'inspection'
        },
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
        Navigator.push(context,
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
      } else {
        // Handle errors, if needed
        print('Failed to send data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, if needed
      print('Error: $e');
    }
  }
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/OMCS-CMS-APIS/get/get_servey_data.php?key=03201232927'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        cases = data.map((category) {
          return CaseData(
            id: category['id'].toString(),
            title: category['name'],
            questions: (category['Questions'] as List)
                .map((question) => question['question'] as String)
                .toList(),
            questionIds: (category['Questions'] as List)
                .map((question) => question['id'] as String)
                .toList(),
            responses: List<bool?>.filled(
              (category['Questions'] as List).length,
              null,
            ),
            imagePaths: List<List<String>>.filled(
              (category['Questions'] as List).length,
              <String>[],
            ),
          );
        }).toList();
      });
    } else {
      print('Failed to load data. Error: ${response.statusCode}');
    }
  }
  Future<void> postSurveyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('Id');
    if (userId == null) {
      print('User ID is null');
      return;
    }

    String apiUrl =
        'http://151.106.17.246:8080/OMCS-CMS-APIS/create/create_servey.php';
    List<Map<String, dynamic>> jsonDataList = [];
    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) => {
            '${caseData.questionIds[index]}':
            caseData.responses[index] == true ? 'Yes' : 'No'
          },
        ),
      });
    }
    Map<String, dynamic> postData = {
      'user_id': userId,
      'response': json.encode(jsonDataList),
      'dealer_id': widget.dealer_id,
      'inspection_id':widget.inspectionid,
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), body: postData);
      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception while posting data: $error');
    }
  }
  Future<PickedFile?> getImage() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      return pickedFile != null ? PickedFile(pickedFile.path) : null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }
  Future<void> saveImageDetails(String categoryId, String questionId, String imagePath) async {
    print('Active Step: ${activeStep}');
    CaseData caseData = cases[activeStep];
    caseData.imagePaths[activeStep].add(imagePath);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");

    // Prepare data for post request
    final Map<String, dynamic> postData = {
      'user_id': id, // Replace with your actual user_id
      'category_id': categoryId,
      'question_id': questionId,
      'dealer_id': widget.dealer_id,
      'inspection_id': widget.inspectionid,

    };

    // Add the index of this postData in the postedDataList
    int index = postedDataList.length;
    postedDataList.add(postData);

    // Save the image path along with the postData index
    imagesToPost.add({
      'index': index,
      'file_path': imagePath,
    });

    print(postedDataList);
    print(imagesToPost);
  }
  Future<void> postImages(List<Map<String, dynamic>> postDataList, List<Map<String, dynamic>> imagesToPost) async {
    String apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/create/survey_detail_files.php';

    try {
      for (var imageInfo in imagesToPost) {
        // Get the corresponding postData
        final Map<String, dynamic> postData = postDataList[imageInfo['index']];

        // Create a multipart request
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add postData fields
        postData.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add the image file
        request.files.add(await http.MultipartFile.fromPath('files', imageInfo['file_path']));

        // Send the request
        final response = await request.send();

        if (response.statusCode == 200) {
          print('Image posted successfully');
          print("My file: ${postData['category_id']}");
        } else {
          print('Failed to post image. Error: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Exception while posting image: $error');
    }
  }

  Widget _icon(int index, {required CaseData caseData}) {
    String question = caseData.questions[index];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkResponse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w200,
                fontStyle: FontStyle.normal,
                color: Color(0xff12283D),
                fontSize: 16,
              ),
              maxLines: 30,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ResponseWidgets(
                  caseData: caseData,
                  questionIndex: index,
                  onChanged: (bool? value) {
                    updateResponse(caseData, index, value);
                  },
                ),
                if (valueIsNo(caseData, index))
                  GestureDetector(
                    onTap: () async {
                      print('Camera button tapped');
                      final imageFile = await getImage();
                      if (imageFile != null) {
                        print('Image captured. Path: ${imageFile.path}');
                        saveImageDetails(
                          caseData.id,
                          caseData.questionIds[index],
                          imageFile.path,
                        );
                      } else {
                        print('Image capture canceled or failed.');
                      }
                    },
                    child: Icon(Icons.camera_alt),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
  bool valueIsNo(CaseData caseData, int questionIndex) {
    return caseData.responses[questionIndex] == false;
  }
  Widget CaseWidget(BuildContext context, CaseData caseData) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Color(0xff12283D),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            caseData.title,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    caseData.questions.length,
                        (index) => _icon(index, caseData: caseData),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void updateResponse(CaseData caseData, int questionIndex, bool? value) {
    setState(() {
      caseData.responses[questionIndex] = value;
    });
  }
  /* posting data */ Future<void> printData() async {
    List<Map<String, dynamic>> jsonDataList = [];

    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) => {
            '${caseData.questionIds[index]}':
            caseData.responses[index] == true ? 'Yes' : 'No'
          },
        ),
      });
    }
    try {
      // Show loader while posting data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        barrierDismissible: false,
      );

      // Post data
      await postSurveyData();
      await postImages(postedDataList,imagesToPost);
      sendstatus();

      /*
      Fluttertoast.showToast(
        msg: 'Inspection sent successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      */
    } catch (error) {
      print('Error while posting data: $error');
      Fluttertoast.showToast(
        msg: 'Failed to send inspection. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  bool validateResponses(List<Map<String, dynamic>> unansweredQuestions) {
    unansweredQuestions.clear();

    for (var i = 0; i < cases.length; i++) {
      var caseData = cases[i];

      if (caseData.responses.contains(null)) {
        var unansweredQuestionNumbers = [];
        for (var j = 0; j < caseData.responses.length; j++) {
          if (caseData.responses[j] == null) {
            unansweredQuestionNumbers.add(j + 1);
          }
        }
        unansweredQuestions.add({
          'stepperName': caseData.title,
          'questions': unansweredQuestionNumbers,
        });
      }
    }
    return unansweredQuestions.isEmpty;
  }
  Future<void> postSignatureImages(String dealerSignaturePath, String representerSignaturePath) async {
    String apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/task_response.php';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Use null-aware operator to provide a default value if 'Id' is null
    var id = prefs.getString("Id") ?? '';

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the dealer signature image file
      request.files.add(await http.MultipartFile.fromPath('dealer_sign', dealerSignaturePath));

      // Add the representer signature image file
      request.files.add(await http.MultipartFile.fromPath('representator_sign', dealerSignaturePath));

      // Add the postData fields
      request.fields.addAll({
        'user_id': id,
        'task_id': widget.inspectionid ?? '', // Provide a default value if null
        'row_id': '',
        'status': '1',
        'description': commentController.text.toString(),
      });

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Signatures and postData posted successfully');
      } else {
        print('Failed to post signatures and postData. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception while posting signatures and postData: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text('Inspection Form',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            NumberStepper(
              numbers: List.generate(cases.length, (index) => index + 1),
              activeStep: activeStep,
              onStepReached: (index) {
                setState(() {
                  activeStep = index;
                });
              },
            ),
            Divider(
              color: Color(0xffafabab),
              height: 2,
              thickness: 2,
            ),
            SizedBox(
              height: 5,
            ),
            header(),
          ],
        ),
      ),
      floatingActionButton: activeStep == cases.length - 1
          ? FloatingActionButton(
        backgroundColor: Constants.secondary_color,
        onPressed: () {
          List<Map<String, dynamic>> unansweredQuestions = [];
          if (validateResponses(unansweredQuestions)) {
            printData();
            /*
            showDialog(
              context: context,
              builder: (BuildContext context) {
                SignatureController _controller = SignatureController(
                  penStrokeWidth: 5,
                  penColor: Colors.black,
                  exportBackgroundColor: Colors.white,
                );
                return AlertDialog(
                  title: Text('Conclusion'),
                  content: Container(
                    height: MediaQuery.of(context).size.width/1.2,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          maxLines: 2,
                          minLines: 1,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Dealer Signature:'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.width/2, // Adjust the height as needed
                          child: Signature(
                            controller: _controller,
                            height: 200, // Adjust the height as needed
                            width: MediaQuery.of(context).size.width,
                            backgroundColor: Colors.grey,
                          ),
                        ),

                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          child: Text('Clear'),
                        ),
                    TextButton(
                      onPressed: () async {
                        /*
                        // Get the cache directory
                        final directory = await getTemporaryDirectory();
                        // Generate a unique file name
                        final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
                        // Combine the directory path and file name
                        final filePath = '${directory.path}/$fileName';
                        // Convert the signature to an image
                        final Uint8List? pngBytes = await _controller.toPngBytes();
                        if (pngBytes != null) {
                          final img.Image? image = img.decodePng(pngBytes);
                          // Save the image to the cache directory
                          File(filePath).writeAsBytesSync(img.encodePng(image!));
                          // Store the file path in the variable
                          setState(() {
                          signatureImagePath = filePath;
                          });
                          print('Image path: $signatureImagePath');
                         */
                          Navigator.pop(context);
                          printData();
                        //}
                      },
                      child: Text('Submit'),
                    ),
                  ],
                );
              },
            );
            */
          }
          else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Please answer all the questions before submitting.'),
                      SizedBox(height: 10),
                      Text('Unanswered Questions:'),
                      for (var unanswered in unansweredQuestions)
                        Text(
                          '${unanswered['stepperName']}: ${unanswered['questions'].map((q) => 'Q$q').join(', ')}',
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },

        child: Icon(Icons.send_rounded,color: Colors.white,),
      )
          : null,
    );
  }

  Widget header() {
    return headerText();
  }

  Widget headerText() {
    if (activeStep >= 0 && activeStep < cases.length) {
      return CaseWidget(context, cases[activeStep]);
    } else {
      return Container();
    }
  }
}

class ResponseWidgets extends StatelessWidget {
  final CaseData caseData;
  final int questionIndex;
  final void Function(bool?) onChanged;

  const ResponseWidgets({
    required this.caseData,
    required this.questionIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Radio(
              value: true,
              groupValue: caseData.responses[questionIndex],
              onChanged: onChanged,
            ),
            Text('Yes'),
          ],
        ),
        Column(
          children: [
            Radio(
              value: false,
              groupValue: caseData.responses[questionIndex],
              onChanged: onChanged,
            ),
            Text('No'),
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Inspection(),
  ));
}
