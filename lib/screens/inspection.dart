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
  List<String> file;
  List<String?> responses;
  List<String?> comments;
  List<String> imagePaths;

  CaseData({
    required this.id,
    required this.questionIds,
    required this.title,
    required this.questions,
    required this.file,
    required this.responses,
    required this.comments,
    required this.imagePaths,
  });
}

class Inspection extends StatefulWidget {
  final String? dealer_id;
  final String? inspectionid;
  final String? dealer_name;
  final String? formId;

  const Inspection({Key? key, this.dealer_id, this.inspectionid,this.dealer_name,this.formId}) : super(key: key);

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
  List<List<TextEditingController>> controllersList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  void printAllComments() {
    for (var caseData in cases) {
      print('Comments for ${caseData.title}:');
      for (int i = 0; i < caseData.comments.length; i++) {
        print('Question ${i + 1}: ${caseData.comments[i]}');
      }

      print('----------------------');
    }
  }
  void printfileForCase(int caseIndex) {
    for (var caseData in cases) {
      print('Image for ${caseData.title}:');
      for (int i = 0; i < caseData.imagePaths.length; i++) {
        print('Image ${i + 1}: ${caseData.imagePaths[i]}');
      }

      print('----------------------');
    }
  }


  void showUnansweredQuestionsSlider(List<Map<String, dynamic>> unansweredQuestions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int id=0;
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
                int totalSections = cases.length;
                print('Total Number of Sections: $totalSections');
                showSlider(unansweredQuestions);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void showSlider(List<Map<String, dynamic>> unansweredQuestions) {
    int sliderIndex = 0;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal on outside tap
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Disable the back button
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Unanswered Questions:'),
                      Slider(
                        value: sliderIndex.toDouble(),
                        onChanged: (double value) {
                          setState(() {
                            sliderIndex = value.toInt();
                          });
                        },
                        min: 0,
                        max: (unansweredQuestions.length - 1).toDouble(),
                        divisions: unansweredQuestions.length - 1,
                      ),
                      Text(
                        'Section: ${unansweredQuestions[sliderIndex]['stepperName']}',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          unansweredQuestions[sliderIndex]['questions'].length,
                              (index) {
                            final questionNumber = unansweredQuestions[sliderIndex]['questions'][index];
                            final questionText = unansweredQuestions[sliderIndex]['questionswhat'][questionNumber - 1];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Question Number: Q$questionNumber',
                                ),
                                Text(
                                  'Question: $questionText',
                                ),
                                ResponseWidgets(
                                  caseData: cases[unansweredQuestions[sliderIndex]['index']],
                                  questionIndex: questionNumber - 1,
                                  onChanged: (String? value) {
                                    updateResponse(cases[unansweredQuestions[sliderIndex]['index']], questionNumber - 1, value);
                                    // Update the UI in real-time
                                    setState(() {});
                                  },
                                ),
                                if (valueIsNo(cases[unansweredQuestions[sliderIndex]['index']], questionNumber - 1))
                                  GestureDetector(
                                    onTap: () async {
                                      print('Camera button tapped');
                                      final imageFile = await getImage();
                                      if (imageFile != null) {
                                        print('Image captured. Path: ${imageFile.path}');
                                        saveImageDetails(
                                          cases[unansweredQuestions[sliderIndex]['index']].id,
                                          cases[unansweredQuestions[sliderIndex]['index']].questionIds[questionNumber - 1],
                                          imageFile.path,
                                        );
                                        // Update the UI in real-time
                                        setState(() {});
                                      } else {
                                        print('Image capture canceled or failed.');
                                      }
                                    },
                                    child: Icon(Icons.camera_alt),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (sliderIndex > 0) {
                          // Move to the previous section
                          sliderIndex--;
                        }
                      });
                    },
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (validateCurrentPage(sliderIndex,unansweredQuestions)) {
                        setState(() {
                          if (sliderIndex < unansweredQuestions.length - 1) {
                            // Move to the next section
                            sliderIndex++;
                          } else {
                            // Submit the form
                            Navigator.pop(context);
                            // You can add your submission logic here
                            // e.g., postSurveyData();
                          }
                        });
                      } else {
                        // Show a message if questions are unanswered
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Incomplete Answers'),
                              content: Text('Please answer all questions on this page before moving to the next section.'),
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        // Change the background color based on the completion of the current page
                        return validateCurrentPage(sliderIndex,unansweredQuestions) ? Constants.secondary_color : Colors.grey;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        // Change the text color based on the completion of the current page
                        return validateCurrentPage(sliderIndex,unansweredQuestions) ? Colors.white : Colors.black;
                      }),
                    ),
                    child: Text(sliderIndex < unansweredQuestions.length - 1 ? 'Next' : 'Submit'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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
          'index': i,
          'stepperName': caseData.title,
          'questions': unansweredQuestionNumbers,
          'questionswhat':caseData.questions,
        });
      }
    }
    return unansweredQuestions.isEmpty;
  }
  bool validateCurrentPage(int sliderIndex, List<Map<String, dynamic>> unansweredQuestions,) {
    var caseData = cases[unansweredQuestions[sliderIndex]['index']];
    return !caseData.responses.contains(null);
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_servey_data.php?key=03201232927'));

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
            file: (category['Questions'] as List)
                .map((question) => question['file'] as String)
                .toList(),
            responses: List<String?>.filled(
              (category['Questions'] as List).length,
              null,
            ),
            comments: List<String?>.filled(
              (category['Questions'] as List).length,
              null,
            ),
            imagePaths: List<String>.filled(
              (category['Questions'] as List).length,
              "",
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
        'http://151.106.17.246:8080/bycobridgeApis/create/create_servey_new.php';
    List<Map<String, dynamic>> jsonDataList = [];
    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) {
            final questionId = caseData.questionIds[index];
            final response = caseData.responses[index] == true.toString() ? 'Yes' : caseData.responses[index] == false.toString() ? 'No' : 'N/A';
            final comment = caseData.comments[index];

            return {
              '$questionId': {
                'response': response,
                'comment': comment,
              },
            };
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
        print("print my jason: ${jsonDataList}");
      } else {
        print('Failed to post data. Error: ${response.statusCode}');
        print("print my jason: ${jsonDataList}");
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

    if (activeStep >= 0 && activeStep < cases.length) {

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

      print("hellow123 $postedDataList");
      print("hellow123 $imagesToPost");
    } else {
      print('Invalid activeStep: $activeStep');

      // Set activeStep to the last valid index
      activeStep = cases.length - 1;

      // You may want to update the UI or show a message to the user
    }
  }
  Future<void> postImages(List<Map<String, dynamic>> postDataList, List<Map<String, dynamic>> imagesToPost) async {
    String apiUrl = 'http://151.106.17.246:8080/bycobridgeApis/create/survey_detail_files.php';

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
  void initializeControllersList() {
    // Assuming cases is a list of CaseData objects
    for (int i = 0; i < cases.length; i++) {
      List<TextEditingController> controllers = [];
      for (int j = 0; j < cases[i].questions.length; j++) {
        controllers.add(TextEditingController());
      }
      controllersList.add(controllers);
    }
  }
  Widget _icon(int index, {required CaseData caseData}) {
    if (activeStep < 0 || activeStep >= cases.length) {
      activeStep = cases.length;
    }

    String question = caseData.questions[index];
    TextEditingController commentController = TextEditingController();
    initializeControllersList();
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
                  onChanged: (String? value) {
                    updateResponse(caseData, index, value);
                  },
                ),
                if (valueIsNo(caseData, index)||caseData.file[index]=="required")
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
                        print(activeStep);
                        saveImagePathAndPrintQuestion(activeStep, index, imageFile.path);
                        // Update the UI in real-time
                        setState(() {
                        });
                      } else {
                        print('Image capture canceled or failed.');
                      }
                    },
                    child: Icon(
                      Icons.camera_alt,
                      color: caseData.imagePaths[index] != "" ? Colors.green : (caseData.file[index] == "required" ? Colors.red : null),
                    )
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controllersList[activeStep][index],//commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter your comments...',
                    ),
                    onChanged: (value) {
                      caseData.comments[index] = value;
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool checkImageAvailability(int activeStep) {
    int printCounter = 0; // Initialize a counter variable

    if (activeStep >= 0 && activeStep < cases.length) {
      CaseData currentStep = cases[activeStep];
      for (int i = 0; i < currentStep.questionIds.length; i++) {
        if (currentStep.file[i] == "required" && currentStep.imagePaths[i] == "") {
          print(currentStep.questions[i]);
          printCounter++; // Increment the counter
        }
      }
    }

    print("Printed $printCounter times."); // Print the total count

    // Return true if printCounter is zero, else false
    return printCounter == 0;
  }
  void saveImagePathAndPrintQuestion(int activeStep, int index, String imageFilePath) {
    if (activeStep >= 0 && activeStep < cases.length) {
      CaseData currentStep = cases[activeStep];

      if (index >= 0 && index < currentStep.questionIds.length) {
        String questionId = currentStep.questionIds[index];
        String question = currentStep.questions[index];

        // Save the image path
        currentStep.imagePaths[index] = imageFilePath;

        print('Question ID: $questionId');
        print('Question: $question');
        print('Image path saved: $imageFilePath');
      } else {
        print('Invalid index for the active step');
      }
    } else {
      print('Invalid active step');
    }
  }


  bool valueIsNo(CaseData caseData, int questionIndex) {
    return caseData.responses[questionIndex] == false.toString();
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
  void updateResponse(CaseData caseData, int questionIndex, String? value) {
    setState(() {
      caseData.responses[questionIndex] = value;
    });
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
  Future<void> printData() async {
    List<Map<String, dynamic>> jsonDataList = [];

    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) {
            final questionId = caseData.questionIds[index];
            final response = caseData.responses[index] == true.toString() ? 'Yes' : caseData.responses[index] == false.toString() ? 'No' : 'N/A';
            final comment = caseData.comments[index];

            return {
              '$questionId': {
                'response': response,
                'comment': comment,
              },
            };
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
      poststaus();
      print("print my jason: ${jsonDataList}");
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text('Inspection',style: TextStyle(color: Colors.white),),
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
                  if (checkImageAvailability(activeStep) == true) {
                    activeStep = index;
                  } else {
                    activeStep = activeStep;
                    Fluttertoast.showToast(
                      msg: 'Please provide all required image on this page',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
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
          } else {
            if (checkImageAvailability(activeStep) == true) {
              showUnansweredQuestionsSlider(unansweredQuestions);
            } else {
              Fluttertoast.showToast(
                msg: 'Please provide all required image on this page',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
            // showUnansweredQuestionsSlider(unansweredQuestions);
            // printAllComments();
            // print("_____printing_____");
            // printfileForCase(0); // Replace 0 with the desired index
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
  final void Function(String?) onChanged; // Explicitly specify String type

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
              value: 'true', // Convert boolean to String
              groupValue: caseData.responses[questionIndex],
              onChanged: onChanged,
            ),
            Text('Yes'),
          ],
        ),
        Column(
          children: [
            Radio(
              value: 'false', // Convert boolean to String
              groupValue: caseData.responses[questionIndex],
              onChanged: onChanged,
            ),
            Text('No'),
          ],
        ),
        Column(
          children: [
            Radio(
              value: 'NA', // Add 'NA' as the third option
              groupValue: caseData.responses[questionIndex],
              onChanged: onChanged,
            ),
            Text('NA'),
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
