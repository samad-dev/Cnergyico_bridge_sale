import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VisitReportPage(),
    );
  }
}

class VisitReportPage extends StatefulWidget {
  @override
  _VisitReportPageState createState() => _VisitReportPageState();
}

class _VisitReportPageState extends State<VisitReportPage> {
  // Add controllers for text fields
  TextEditingController safetyController = TextEditingController();
  TextEditingController canopyController = TextEditingController();
  TextEditingController tanksController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController forecountController = TextEditingController();
  TextEditingController uppAndFittingController = TextEditingController();
  TextEditingController dispensersController = TextEditingController();
  TextEditingController signageController = TextEditingController();
  TextEditingController solarController = TextEditingController();
  TextEditingController actionPlanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(
          color: Constants.secondary_color,
        ),
        title: Text(
          'Visit Report',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Observation:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: safetyController,
                        decoration: InputDecoration(labelText: 'Safety'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: canopyController,
                        decoration: InputDecoration(labelText: 'Canopy'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: tanksController,
                        decoration: InputDecoration(labelText: 'Tanks'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: buildingController,
                        decoration: InputDecoration(labelText: 'Building'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: forecountController,
                        decoration: InputDecoration(labelText: 'Forecount'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: uppAndFittingController,
                        decoration: InputDecoration(labelText: 'UPP and Fitting'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: dispensersController,
                        decoration: InputDecoration(labelText: 'Dispensers'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: signageController,
                        decoration: InputDecoration(labelText: 'Signage'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: solarController,
                        decoration: InputDecoration(labelText: 'Solar'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      TextField(
                        controller: actionPlanController,
                        decoration: InputDecoration(labelText: 'Action Plan'),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
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
