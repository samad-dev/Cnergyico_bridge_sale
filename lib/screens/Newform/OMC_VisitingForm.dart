import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/utils/constants.dart';

class OMCVisitingForm extends StatefulWidget {
  @override
  _OMCVisitingFormState createState() => _OMCVisitingFormState();
}

class _OMCVisitingFormState extends State<OMCVisitingForm> {
  TextEditingController omcNameController = TextEditingController();
  TextEditingController omcDealerController = TextEditingController();
  TextEditingController dailySalesController = TextEditingController();
  TextEditingController pmgController = TextEditingController();
  TextEditingController hsdController = TextEditingController();
  TextEditingController lubeController = TextEditingController();
  TextEditingController dealersNameController = TextEditingController();
  TextEditingController operatedByController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController roadHighwayController = TextEditingController();
  TextEditingController directionController = TextEditingController();
  TextEditingController nearestCityController = TextEditingController();
  TextEditingController supplyPointController = TextEditingController();
  // List of OMCs
  List<String> omcs = ['PSO', 'SPL', 'TPPL', 'BPPL', 'APL', 'GO', 'ASKAR', 'Others'];
  // Additional variables for selected trade area OMCs
  List<String> selectedOMCs = [];
  TextEditingController otherOMCController = TextEditingController();
  bool showOMCDetails = false;
  String operatedBy = '';

  void handleOMCSelection(bool? value, String omc) {
    setState(() {
      if (value != null && value) {
        // If the checkbox is checked, add the OMC to the selected list
        selectedOMCs.add(omc);
      } else {
        // If the checkbox is unchecked, remove the OMC from the selected list
        selectedOMCs.remove(omc);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        title: Text('OMC Visiting Form',
        style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        color: Constants.secondary_color,
        fontSize: 16,),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Row
              TextField(
                controller: omcNameController,
                decoration: InputDecoration(labelText: 'OMC Name'),
              ),

              // Second Row
              Row(
                children: [
                  Text('Multiple Dealers:'),
                  Radio(
                    value: false,
                    groupValue: showOMCDetails,
                    onChanged: (value) {
                      setState(() {
                        showOMCDetails = value!;
                      });
                    },
                  ),
                  Text('No'),
                  Radio(
                    value: true,
                    groupValue: showOMCDetails,
                    onChanged: (value) {
                      setState(() {
                        showOMCDetails = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                ],
              ),
              // Third Row
              if (showOMCDetails)
                TextField(
                  controller: omcDealerController,
                  decoration: InputDecoration(labelText: 'OMC Dealer'),
                ),

              // Fourth Row
              SizedBox(height: 10,),
              Text("Daily Sales Lts"),
              // Fifth Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pmgController,
                      decoration: InputDecoration(labelText: 'PMG'),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: hsdController,
                      decoration: InputDecoration(labelText: 'HSD'),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: lubeController,
                      decoration: InputDecoration(labelText: 'Lube'),
                    ),
                  ),
                ],
              ),

              // Sixth Row
              TextField(
                controller: dealersNameController,
                decoration: InputDecoration(labelText: 'Dealers Name'),
              ),

              // Seventh Row
              SizedBox(height: 10,),
              Text('Operated by'),
              Row(
                children: [
                  Radio(
                    value: 'Dealer',
                    groupValue: operatedBy,
                    onChanged: (value) {
                      setState(() {
                        operatedBy = value!;
                      });
                    },
                  ),
                  Text('Dealer'),
                  Radio(
                    value: 'Contractor',
                    groupValue: operatedBy,
                    onChanged: (value) {
                      setState(() {
                        operatedBy = value!;
                      });
                    },
                  ),
                  Text('Contractor'),
                  Radio(
                    value: 'Other',
                    groupValue: operatedBy,
                    onChanged: (value) {
                      setState(() {
                        operatedBy = value!;
                      });
                    },
                  ),
                  Text('Other'),
                ],
              ),

              // Eighth Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: areaController,
                      decoration: InputDecoration(labelText: 'Area'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: districtController,
                      decoration: InputDecoration(labelText: 'District'),
                    ),
                  ),
                ],
              ),
              // Ninth Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: roadHighwayController,
                      decoration: InputDecoration(labelText: 'Road/Highway'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: directionController,
                      decoration: InputDecoration(labelText: 'Direction'),
                    ),
                  ),
                ],
              ),
              // Tenth Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nearestCityController,
                      decoration: InputDecoration(labelText: 'Nearest City'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: supplyPointController,
                      decoration: InputDecoration(labelText: 'Supply Point'),
                    ),
                  ),
                ],
              ),

              Text("Trade Area Volume (Daily) Lt"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pmgController,
                      decoration: InputDecoration(labelText: 'PMG'),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: hsdController,
                      decoration: InputDecoration(labelText: 'HSD'),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: lubeController,
                      decoration: InputDecoration(labelText: 'Lube'),
                    ),
                  ),
                ],
              ),

              // New Row for Trade area OMC
              SizedBox(height: 10,),
              Text("Trade area OMC"),
              Wrap(
                spacing: 8.0, // Adjust the spacing between checkboxes
                runSpacing: 8.0, // Adjust the spacing between rows
                children: omcs.map((omc) {
                  return Row(
                    mainAxisSize: MainAxisSize.min, // Ensure each row takes minimum space
                    children: [
                      // Checkboxes for various OMCs
                      Checkbox(
                        value: selectedOMCs.contains(omc),
                        onChanged: (value) {
                          handleOMCSelection(value, omc);
                        },
                      ),
                      Text(omc),
                      // If 'Others' is selected, display a text field in a new row
                      if (omc == 'Others' && selectedOMCs.contains('Others'))
                        SizedBox(height: 8.0), // Add spacing before the text field
                    ],
                  );
                }).toList() +
                    // Conditionally add the text field in a new row
                    (selectedOMCs.contains('Others')
                        ? [
                      Row(
                        children: [
                          Expanded( // Use Expanded to allow the TextField to take available space
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                controller: otherOMCController,
                                decoration: InputDecoration(labelText: 'Enter names of OMCs'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]
                        : []),
              ),

              TextField(
                controller: dealersNameController,
                decoration: InputDecoration(labelText: 'Remarks'),
              ),

              TextField(
                controller: dealersNameController,
                decoration: InputDecoration(labelText: 'Recommendation / Suggestion:'),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 4.0,
                  backgroundColor: Constants.secondary_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(200, 50), // Set your preferred width and height
                ),
                onPressed:
                    () async {},
                child: Text('Submit',style: TextStyle(color: Constants.primary_color),),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: OMCVisitingForm(),
  ));
}
