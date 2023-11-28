import 'dart:convert';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/complaint.dart';
import 'package:hascol_inspection/screens/login.dart';
import 'package:hascol_inspection/screens/order_list.dart';
import 'package:hascol_inspection/screens/profile.dart';
import 'package:hascol_inspection/screens/task_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'create_order.dart';
import 'inspection.dart';
import 'outlets_list.dart';

class Home extends StatefulWidget {
  static const Color contentColorOrange = Color(0xFF00705B);
  final Color leftBarColor = Color(0xFFCB6600);
  final Color rightBarColor = Color(0xFF5BECD2);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  final double width = 7;
  int _selectedIndex = 0;
  int touchedGroupIndex = -1;
  String total_outlet='0';
  String total_orders='0';
  String total_task='0';
  int inspection_length=0;
  List<Map<String, dynamic>> inspection_task = [];
  DateTime? selectedDate;
  TextEditingController reasonController = TextEditingController();
  TextEditingController reasontransferController = TextEditingController();
  List<String> tm_list = [];
  List<String> tm_id_list = [];
  String? selectedtmformId;
  String? selectedtmformType;
  String? user_privilege;

  @override
  void initState() {
    super.initState();
    Total_outlet();
    Total_orders();
    Inspection_task();
    TransfersZM();
  }


  Future<void> Total_outlet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    user_privilege=pre;
    final response = await http.get(
        Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/outlet_count.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        total_outlet = '${data.length}';
        print("total_outlet --->  $total_outlet");
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> Total_orders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(
        Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/user_all_orders.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        total_orders = '${data.length}';
        print("total_orders --->  $total_orders");
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> Inspection_task() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    final response = await http.get(
        Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/inspector_task.php?key=03201232927&id=$id&pre=$pre'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        inspection_task = List<Map<String, dynamic>>.from(data);
        total_task = '${data.length}';
        if(data.length>=3){
          inspection_length=3;
        }else{
          inspection_length=data.length;
        }
      });
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }
  Future<void> TransfersZM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    var pre = prefs.getString("privilege");
    if(pre=="ZM" || pre == "zm"){
      final response = await http.get(Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/individual_tm_of_zm.php?key=03201232927&zm_id=$id'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> typeList = data.map((item) => '${item['name']} - ${item['privilege']}').toList();
        List<String> idList = data.map((item) => item['tm_id'].toString()).toList();
        setState(() {
          tm_list = typeList;
          tm_id_list = idList;
        });
      } else {
        throw Exception('Failed to fetch data from the API');
      }
    }
    else if(pre =="TM"|| pre=="tm"){
      final response = await http.get(
          Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/individual_asm_of_tm.php?key=03201232927&tm_id=$id'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> typeList = data.map((item) => '${item['name']} - ${item['privilege']}').toList();
        List<String> idList = data.map((item) => item['tm_id'].toString()).toList();
        setState(() {
          tm_list = typeList;
          tm_id_list = idList;
        });
      } else {
        throw Exception('Failed to fetch data from the API');
      }
    }
  }
  void sendRequestReschedule(var taskId,String oldDate)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final apiUrl = "http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/task_reschedule.php";
    final data = {
      "user_id": id,
      "task_id": taskId,
      "row_id": '',
      "old_date": oldDate,
      "description": reasonController.text.toString(),
      "new_date":  "${selectedDate?.toLocal()}".split('.').first,
    };
    final response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Request for Reschedule is send successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    else {
      Fluttertoast.showToast(
        msg: "Request for Reschedule is not send successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    setState(() {
      selectedDate = null;
      reasonController.clear();

    });
  }
  void sendRequestTransfer(var taskId)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString("Id");
    final apiUrl = "http://151.106.17.246:8080/OMCS-CMS-APIS/update/inspection/transfer_task.php";
    final data = {
      "user_id": id,
      "task_id": taskId,
      "row_id": '',
      "transfer_to":selectedtmformId,
      "reason": reasontransferController.text.toString(),
    };
    final response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Transfer of Task is completed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
      reasontransferController.clear();
    }
    else {
      Fluttertoast.showToast(
        msg: "Transfer of task is failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
    setState(() {
      reasontransferController.clear();
      selectedtmformId = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM kk:mm:ss').format(now);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 48.0, left: 5, right: 5),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xff12283D),
                      radius: 30,
                      child: Text(
                        'SB',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ), //Text
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Home,',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xff8A8A8A),
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'Sales Bridge',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                IconButton(
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: Icon(
                      Icons.add_box_rounded,
                      color: Color(0xff12283D),
                      size: 35,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Create_Order()),
                      );
                      print("Pressed");
                    }),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You've got",
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 18,
                          color: Color(0xd8787676),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      Text(
                        '$total_task Task',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 18,
                          color: Color(0xff12283D),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  color: Color(0xff3a833c),//color: Color(0xff12283D),
                  elevation: 15,
                  child: SizedBox(
                    width: 165,
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: Color(0xff586776),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                              ),
                            ),
                          ), //Text
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Orders',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffffffff),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              Text(
                                '$total_orders Orders',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xffc7c7c7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              OutlinedButton(
                                child: Text(
                                  'View Order',
                                  style: GoogleFonts.montserrat(
                                    color: Color(0xffc7c7c7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1.0, color: Color(0xd5e0e0e0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Orders()),
                                  );
                                },
                              )
                            ],
                          ),

                          //SizedBox
                          //T //SizedBox
                          //SizedBox
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  color: Color(0xff3a833c),//color: Color(0xff12283D),
                  elevation: 15,
                  child: SizedBox(
                    width: 165,
                    height: 160,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            color: Color(0xff586776),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                FluentIcons.gas_pump_24_regular,
                                color: Colors.white,
                              ),
                            ),
                          ), //Text
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Outlets',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffffffff),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              Text(
                                '$total_outlet Outlets',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xffc7c7c7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              OutlinedButton(
                                child: Text(
                                  'View Outlets',
                                  style: GoogleFonts.montserrat(
                                    color: Color(0xffc7c7c7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1.0, color: Color(0xd5e0e0e0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Outlets()),
                                  );
                                },
                              )
                            ],
                          ),

                          //SizedBox
                          //T //SizedBox
                          //SizedBox
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox,
                ),

                //
              ],
            ),
            SizedBox(
              height: 10,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: Color(0xfff9f9f9),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8,left: 8, right: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming',
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displayLarge,
                                fontSize: 18,
                                color: Color(0xff12283D),
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            Text(
                              'View All',
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displaySmall,
                                fontSize: 15,
                                color: Color(0xff727272),
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: inspection_length,
                          itemBuilder: (BuildContext context, int index2) {
                            final type = inspection_task[index2]['type'];
                            final dealer_name = inspection_task[index2]['dealer_name'];
                            final dealer_id = inspection_task[index2]['dealer_id'];
                            final time = inspection_task[index2]['time'];
                            final id = inspection_task[index2]['id'];
                            return Card(
                              elevation: 10,
                              color: Color(0xffffffff),
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Inspection at $dealer_name - Jauhar',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xff12283D),
                                                fontSize: 14),
                                          ),
                                          if(user_privilege == "ZM" || user_privilege == "zm" || user_privilege == "TM"||user_privilege == "tm")
                                            GestureDetector(
                                            onTap: (){
                                              reasontransferController.clear();
                                              selectedtmformId = null;
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(
                                                      builder: (BuildContext context, StateSetter setState){
                                                        return AlertDialog(
                                                          title: Text("Transfer"),
                                                          content: Container(
                                                            height: MediaQuery.of(context).size.height/3.4,
                                                            width: MediaQuery.of(context).size.width/1.5,
                                                            child: Column(
                                                              children: [
                                                                TextDropdownFormField(
                                                                  options:tm_list,
                                                                  decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(18.0),
                                                                    ),
                                                                    suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                                                                    labelText: "Select employee",
                                                                  ),
                                                                  dropdownHeight: 100,
                                                                  onChanged: (dynamic value) {
                                                                    setState(() {
                                                                      selectedtmformType = value; // Set the selected type
                                                                      // Find the index of the selected type in uniform_type_list
                                                                      int index = tm_list.indexOf(value);
                                                                      if (index >= 0 && index < tm_id_list.length) {
                                                                        selectedtmformId = tm_id_list[index]; // Set the corresponding ID
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                                  child: TextField(
                                                                    controller: reasontransferController,
                                                                    decoration: InputDecoration(
                                                                      labelText: 'Reason',
                                                                      hintText: "Reason for Transfer",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                                                      ),
                                                                    ),
                                                                    maxLines: 3,
                                                                    minLines: 3,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed: (){
                                                                        sendRequestTransfer(id);
                                                                      },
                                                                      child: Text("Start"),
                                                                    ),
                                                                    SizedBox(width: 10,),
                                                                    ElevatedButton(
                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                      child: Text("Cancel"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  );
                                                },
                                              );
                                            },
                                            child: CircleAvatar(
                                                backgroundColor: Color(0xff12283D),
                                                child: Image.asset(
                                                  "assets/images/change.png",
                                                  width: 35,
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$type',
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w200,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xff737373),
                                                fontSize: 12),
                                          ),
                                          Text(
                                            'Details',
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w200,
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xff737373),
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(height: 1, color: Color(0xffBFBFBF)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Wrap(
                                            children: [
                                              Icon(
                                                FluentIcons.clock_48_regular,
                                                size: 15,
                                                color: Color(0xff12283d),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width:MediaQuery.of(context).size.width/3.5,
                                                child: Text(
                                                  '$time',
                                                  style: GoogleFonts.montserrat(
                                                      fontWeight: FontWeight.w200,
                                                      fontStyle: FontStyle.normal,
                                                      color: Color(0xff737373),
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                child: Text(
                                                  'Reschedule',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color(0xff12283D),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),

                                                ),
                                                onPressed: () {
                                                  selectedDate = null;
                                                  reasonController.clear();
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return StatefulBuilder(
                                                          builder: (BuildContext context, StateSetter setState){
                                                        return AlertDialog(
                                                          title: Text("Reschedule"),
                                                          content: Container(
                                                            height: MediaQuery.of(context).size.height/3.4,
                                                            width: MediaQuery.of(context).size.width/1.5,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                    border: Border.all(
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      selectedDate != null
                                                                          ? Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0),
                                                                        child: Container(
                                                                          width: MediaQuery.of(context).size.width/3.4,
                                                                          child: Text(
                                                                            selectedDate != null
                                                                                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!)
                                                                                : "Select a Date",
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                          : Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0),
                                                                        child: Text("Select a Date"),
                                                                      ),
                                                                      Container(
                                                                        height: 40, // Adjust the height as needed
                                                                        child: ElevatedButton(
                                                                          onPressed: () async {
                                                                            final DateTime? pickedDate = await showDatePicker(
                                                                              context: context,
                                                                              initialDate: DateTime.now(),
                                                                              firstDate: DateTime.now(),
                                                                              lastDate: DateTime(2101),
                                                                            );
                                                                            if (pickedDate != null) {
                                                                              final TimeOfDay? pickedTime = await showTimePicker(
                                                                                context: context,
                                                                                initialTime: TimeOfDay.fromDateTime(DateTime.now(),),
                                                                              );

                                                                              if (pickedTime != null) {
                                                                                setState(() {
                                                                                  selectedDate = DateTime(
                                                                                    pickedDate.year,
                                                                                    pickedDate.month,
                                                                                    pickedDate.day,
                                                                                    pickedTime.hour,
                                                                                    pickedTime.minute,
                                                                                  );
                                                                                });
                                                                              }
                                                                            }
                                                                          },
                                                                          style: ElevatedButton.styleFrom(
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(20.0),
                                                                                bottomRight: Radius.circular(20.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child: Text("Select Date"),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),

                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                                  child: TextField(
                                                                    controller: reasonController,
                                                                    decoration: InputDecoration(
                                                                      labelText: 'Reason',
                                                                      hintText: "Reason for Reschedule",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                                                      ),
                                                                    ),
                                                                    maxLines: 3,
                                                                    minLines: 3,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed: (){
                                                                        sendRequestReschedule(id,time.toString());
                                                                      },
                                                                      child: Text("Start"),
                                                                    ),
                                                                    SizedBox(width: 10,),
                                                                    ElevatedButton(
                                                                      onPressed: () => Navigator.of(context).pop(),
                                                                      child: Text("Cancel"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                child: Text(
                                                  'Start',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color(0xff12283D),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),

                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Inspection(dealer_id: dealer_id,)),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x8ca9a9a9),
              blurRadius: 20,
            ),
          ],
        ),
        child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            unselectedItemColor: Color(0xff8d8d8d),
            unselectedLabelStyle:
                const TextStyle(color: Color(0xff8d8d8d), fontSize: 14),
            unselectedFontSize: 14,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedIconTheme: IconThemeData(
              color: Color(0xff12283D),
            ),
            type: BottomNavigationBarType.shifting,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(
                    FluentIcons.home_32_regular,
                    size: 20,
                  ),
                  label: 'Home',
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                  icon: Icon(
                    FluentIcons.weather_sunny_16_regular,
                    size: 20,
                  ),
                  label: 'Tasks',
                  backgroundColor: Colors.white),
              BottomNavigationBarItem(
                icon: Icon(
                  FluentIcons.inprivate_account_16_regular,
                  size: 20,
                ),
                label: 'Profile',
                backgroundColor: Colors.white,
              ),
            ],
            selectedItemColor: Color(0xff12283D),
            iconSize: 40,
            onTap: _onItemTapped,
            elevation: 15),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Tasks()),
      );
    }
    if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
    }
  }
}
