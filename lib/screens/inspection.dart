import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:im_stepper/stepper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaseData {
  String id;
  String title;
  List<String> questionIds;
  List<String> questions;
  List<bool?> responses;

  CaseData({
    required this.id,
    required this.questionIds,
    required this.title,
    required this.questions,
    required this.responses,
  });
}

class Inspection extends StatefulWidget {
  final String? dealer_id; // Change here
  const Inspection({Key? key, this.dealer_id}) : super(key: key);
  @override
  _InspectionState createState() => _InspectionState();
}

class _InspectionState extends State<Inspection> {
  int activeStep = 0;
  List<CaseData> cases = [];

  @override
  void initState() {
    super.initState();
    fetchData();
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
                (category['Questions'] as List).length, null),
          );
        }).toList();
      });
    } else {
      // Handle the error
      print('Failed to load data. Error: ${response.statusCode}');
    }
  }
  Future<void> postSurveyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('Id'); // Replace 'user_id' with the actual key used in SharedPreferences
    if (userId == null) {
      // Handle the case where user_id is null
      print('User ID is null');
      return;
    }
    String apiUrl = 'http://151.106.17.246:8080/OMCS-CMS-APIS/create/create_servey.php';
    List<Map<String, dynamic>> jsonDataList = [];
    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) => {
            '${caseData.questionIds[index]}': caseData.responses[index] == true ? 'Yes' : 'No'
          },
        ),
      });
    }
    Map<String, dynamic> postData = {
      'user_id': userId,
      'response': json.encode(jsonDataList),
      'dealer_id': widget.dealer_id,
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), body: postData);
      if (response.statusCode == 200) {
        // Successfully posted data
        print('Data posted successfully');
      } else {
        // Handle the error
        print('Failed to post data. Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle the exception
      print('Exception while posting data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inspection Form'),
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
            SizedBox(height: 5,),
            header(),
          ],
        ),
      ),
      floatingActionButton: activeStep == cases.length - 1
          ? FloatingActionButton(
        onPressed: () {
          List<Map<String, dynamic>> unansweredQuestions = [];
          if (validateResponses(unansweredQuestions)) {
            printData();
          } else {
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
        child: Icon(Icons.send_rounded),
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
      return Container(); // handle out-of-bounds case
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
            Text(question,
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
                    onTap: (){
                      print("Camera on");
                    },
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        // Handle camera icon click
                        // This can be a function to open the camera or any other action
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

  bool valueIsNo(CaseData caseData, int questionIndex) {
    return caseData.responses[questionIndex] == false;
  }


  Widget CaseWidget(BuildContext context, CaseData caseData) {
    return Container(
      child: Column(
        children: [
          Card(
            color: Color(0xff12283D),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3,
                  vertical: 10),
              child: Text(
                caseData.title, // Change this to category_id
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                caseData.questions.length,
                    (index) => _icon(index, caseData: caseData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateResponse(CaseData caseData, int questionIndex, bool? value) {
    setState(() {
      caseData.responses[questionIndex] = value;
    });
  }
  void printData() {
    List<Map<String, dynamic>> jsonDataList = [];

    for (var caseData in cases) {
      jsonDataList.add({
        caseData.id: List.generate(
          caseData.questionIds.length,
              (index) => {
            '${caseData.questionIds[index]}': caseData.responses[index] == true ? 'Yes' : 'No'
          },
        ),
      });
    }

    print(json.encode(jsonDataList));
    postSurveyData();
  }


  bool validateResponses(List<Map<String, dynamic>> unansweredQuestions) {
    unansweredQuestions.clear();

    for (var i = 0; i < cases.length; i++) {
      var caseData = cases[i];

      if (caseData.responses.contains(null)) {
        var unansweredQuestionNumbers = [];
        for (var j = 0; j < caseData.responses.length; j++) {
          if (caseData.responses[j] == null) {
            unansweredQuestionNumbers.add(j + 1); // Adding 1 to convert to 1-based index
          }
        }
        unansweredQuestions.add({
          'stepperName': caseData.title, // Use the title property instead of index
          'questions': unansweredQuestionNumbers,
        });
      }
    }

    return unansweredQuestions.isEmpty;
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
