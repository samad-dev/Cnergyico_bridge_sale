import 'package:flutter/material.dart';
import 'package:hascol_inspection/screens/stock_reconcile.dart';
import 'package:hascol_inspection/screens/stock_reconcile_Tank.dart';
import '../utils/constants.dart';
import 'SalesPerformance.dart';
import 'inspection.dart';


class TaskDashboard extends StatefulWidget {
  final String? dealer_id;
  final String? inspectionid;
  final String? dealer_name;

  const TaskDashboard({Key? key, this.dealer_id, this.inspectionid,this.dealer_name}) : super(key: key);
  @override
  TaskDashboardState createState() => TaskDashboardState(dealer_id!,inspectionid,dealer_name);
}

class TaskDashboardState extends State<TaskDashboard> {
  final String dealer_id;
  final String? inspectionid;
  final String? dealer_name;
  TaskDashboardState(this.dealer_id,this.inspectionid,this.dealer_name);


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: screenWidth / 2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Puma_Background.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$dealer_name",
                  style: TextStyle(
                    color: Colors.black, // Text color on top of the image
                    fontSize: 20.0, // Adjust the font size as needed
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Constants.secondary_color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        color:  Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '6',
                                    style: TextStyle(
                                      color:Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Total Tasks',
                                    style: TextStyle(
                                      color:Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width/27,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      color:Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width/27,
                                    ),
                                  ),
                                ],
                              ),
                              // Add any other content for the "Tasks Completed" card
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width/27,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color:Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              // Add any other content for the "Remaining Tasks" card
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SalesPerformance(dealer_id: dealer_id,)));},
                                  child: Card(
                                    elevation: 10.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/performance-award.png',
                                            height: 50.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Sales',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Performance',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
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
                              Expanded(
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/efficiency.png',
                                          height: 50.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Measurement',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.width/27,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '& Pricing',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.width/27,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StockReconcileTankPage(dealer_id: dealer_id,)));
                                    },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/oil-tank.png',
                                            height: 50.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Wet Stock',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Management',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StockReconcilePage(dealer_id:dealer_id)),
                                  );
                                    },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/electric-meter.png',
                                            height: 50.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Dispensing Unit',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Meter Reading',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context).size.width/27,
                                                    fontWeight: FontWeight.bold,
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
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/report.png',
                                          height: 50.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            'Stock Variation',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width/27,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap:(){
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => Inspection(dealer_id: dealer_id,inspectionid: inspectionid)),);
                                  },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/inspection.png',
                                            height: 50.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              'Inspection',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width/27,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width/1.8, // Half of the screen width
                            height: 45,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45.0), // Adjust the value for curved border
                                ),
                                backgroundColor: Constants.secondary_color, // Background color
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}