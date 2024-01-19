import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';
import 'PCC.dart';

class PCCFormHeader extends StatefulWidget {
  final String? dealer_id;
  final String? inspectionid;
  final String? dealer_name;
  final String? formId;

  const PCCFormHeader({Key? key, this.dealer_id, this.inspectionid, this.dealer_name, this.formId}) : super(key: key);

  @override
  PCCFormHeaderState createState() => PCCFormHeaderState(dealer_id!, inspectionid!, dealer_name!, formId!);
}

class PCCFormHeaderState extends State<PCCFormHeader> {
  final String dealer_id;
  final String inspectionid;
  final String dealer_name;
  final String formId;

  PCCFormHeaderState(this.dealer_id, this.inspectionid, this.dealer_name, this.formId);

  List<Map<String, String>> surveyData = [
    {"label": "Canopy Dimension", "answer": "", "comment": ""},
    {"label": "NFR Facilities (By the Way, Car Wash, Tyre Shop, Oil Change, Lube Shop)", "answer": "", "comment": ""},
    {"label": "Masjid and Public Toilets", "answer": "", "comment": ""},
    {"label": "Units & Tanks (Quantity and Capacity) (4 UNITS) (2 GASOLINE 2 DIESEL))", "answer": "", "comment": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        title: Text('PCC Form',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Constants.secondary_color,
                fontSize: 16)
        ),
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: surveyData.map((question) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question["label"]!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Radio(
                        value: "Yes",
                        groupValue: question["answer"],
                        activeColor: Constants.secondary_color,
                        onChanged: (value) {
                          setState(() {
                            question["answer"] = value!;
                            question["comment"] = "";
                          });
                        },
                      ),
                      Text("Yes"),
                      Radio(
                        value: "No",
                        groupValue: question["answer"],
                        activeColor: Constants.secondary_color,
                        onChanged: (value) {
                          setState(() {
                            question["answer"] = value!;
                            question["comment"] = "";
                          });
                        },
                      ),
                      Text("No"),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Comments"),
                    onChanged: (value) {
                      setState(() {
                        question["comment"] = value;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.secondary_color,
        onPressed: () {
          // Check if all questions have answers
          bool allQuestionsAnswered = surveyData.every((question) => question["answer"] != null && question["answer"]!.isNotEmpty);

          if (allQuestionsAnswered) {
            // Print or use the survey data as needed
            List<Map<String, String>> result = surveyData.map((question) {
              return {
                "label": question["label"]!,
                "answer": question["answer"]!,
                "comment": question["comment"]!,
              };
            }).toList();

            // Convert the list to JSON format
            String jsonString = json.encode(result);
            print("header page $jsonString");

            // Navigate to the next page (PCCForm) with the data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PCCForm(
                  dealer_id: dealer_id,
                  inspectionid: inspectionid,
                  dealer_name: dealer_name,
                  formId: formId,
                  header: jsonString,
                ),
              ),
            );
          } else {
            // Show an alert or message indicating that all questions must be answered
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Incomplete Survey'),
                content: Text('Please answer all questions before proceeding.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        child: Icon(Icons.check,color: Constants.primary_color,),
      ),
    );
  }
}
