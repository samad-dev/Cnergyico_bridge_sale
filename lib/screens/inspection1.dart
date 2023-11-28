import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:im_stepper/stepper.dart';

class Inspection extends StatefulWidget {
  @override
  _InspectionState createState() => _InspectionState();
}

class _InspectionState extends State<Inspection> {
  @override
  void initState() {
    super.initState();
  }

  int activeStep =0; // Initial step set to 5.
  int upperBound = 6;
  final List<String> apiCases = ['case1', 'case2', 'case3'];

  int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          //replace with our own icon data.
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Text(
          'Inspection',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: Color(0xff12283D),
              fontSize: 16),
        ),
      ),
      // Here we have initialized the stepper widget
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            NumberStepper(
              stepReachedAnimationEffect: Curves.easeIn,
              enableStepTapping: true,
              activeStepColor: Color(0xff12283d),
              activeStepBorderPadding: 4,
              stepPadding: 0,
              stepRadius: 18,
              lineColor: Color(0xff8d8d8d),
              nextButtonIcon:Icon(FluentIcons.next_frame_24_regular,color: Color(0xff12283d),),
              previousButtonIcon: Icon(FluentIcons.previous_frame_24_regular,color: Color(0xff12283d),),
              numbers: [
                1,2,3,4,5,6,
              ],

              numberStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  color: Color(0xffffffff),
                  fontSize: 12),
              activeStepBorderColor: Color(0xff32a58b),
              stepColor: Color(0xff55a5f1),

              // activeStep property set to activeStep variable defined above.
              activeStep: activeStep,

              // This ensures step-tapping updates the activeStep.
              onStepReached: (index) {
                setState(() {
                  activeStep = index;

                });
              },
            ),
            Divider(color: Color(0xffafabab),height: 2,thickness: 2,),
            SizedBox(height: 5,),
            header(),
            /*
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _icon(0, text: "Are decanting instructions available in tank area?"),
                  _icon(1, text: "Are decanting instructions available in tank area?"),
                ],
            ),
            */
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            previousButton(),
            nextButton(),
            ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the next button.
  Widget nextButton() {
    return ElevatedButton(
      onPressed: () {
        // Increment activeStep, when the next button is tapped. However, check for upper bound.
        if (activeStep < upperBound) {
          setState(() {
            activeStep++;
          });
        }
      },
      child: Text('Next'),
    );
  }

  /// Returns the previous button.
  Widget previousButton() {
    return ElevatedButton(
      onPressed: () {
        // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
        if (activeStep > 0) {
          setState(() {
            activeStep--;
          });
        }
      },
      child: Text('Prev'),
    );
  }

  /// Returns the header wrapping the header text.
  Widget header() {
    return headerText();
  }

  // Returns the header text based on the activeStep.
  Widget headerText() {
    switch (activeStep) {
      case 0:
        return Case1(context);

      case 1:
        return Case2(context);

      case 2:
        return Case3(context);

      case 3:
        return Case4(context);

      case 4:
        return Case5(context);

      case 5:
        return Case6(context);

      default:
        return Case6(context);
    }
  }
  int ?_selected;
  Widget _icon(int index, {required String text}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkResponse(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 250,
              child: Text(text,style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w200,
                  fontStyle: FontStyle.normal,
                  color: Color(0xff12283D),
                  fontSize: 16),
              maxLines: 30,
              overflow: TextOverflow.ellipsis,),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  _selected == index ?  FluentIcons.checkbox_unchecked_24_regular : FluentIcons.checkbox_checked_24_regular,
                  color: _selected == index ? Colors.green : null,
                ),
                Icon(
                  _selected == index ?  Icons.cancel_outlined : Icons.cancel,
                  color: _selected == index ? Colors.red : null,
                ),
              ],
            ),


          ],
        ),
        // onTap: () => setState(
        //       () {
        //     _selected = index;
        //   },
        // ),
      ),
    );
  }

  Widget Case1(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Card(
            color: Color(0xff12283D),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal :MediaQuery.of(context).size.width/3, vertical: 10),
              child: Text(
                  "Tank Area",
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
              children: [
                _icon(0, text: "Are decanting instructions available in tank area?"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget Case2(BuildContext context) {
    return Container(
      child: Text("Electricity"),
    );
  }
  Widget Case3(BuildContext context) {
    return Container(
      child: Text("Fare court"),
    );
  }
  Widget Case4(BuildContext context) {
    return Container(
      child: Text("Earthing result"),
    );
  }
  Widget Case5(BuildContext context) {
    return Container(
      child: Text("Emergency preparedness"),
    );
  }
  Widget Case6(BuildContext context) {
    return Container(
      child: Text("House keeping"),
    );
  }

}
