import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hascol_inspection/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

Future<void> login(BuildContext context) async {
  final email = _emailController.text;
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    Fluttertoast.showToast(
        msg: "Please Fill Credentials",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    return;
  }

  final url = Uri.parse('http://151.106.17.246:8080/OMCS-CMS-APIS/get/inspection/login.php?key=03201232927&username=$email&password=$password');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final jsons = json.decode(response.body);
    if (jsons.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      print(jsons[0]['name']);
      prefs.setString("Id", jsons[0]["id"]);
      prefs.setString("name", jsons[0]["name"].toString());
      prefs.setString("contact", jsons[0]["contact"].toString());
      prefs.setString("privilege", jsons[0]["privilege"].toString());
      prefs.setString("login", jsons[0]["login"].toString());
      prefs.setString("password", jsons[0]["password"].toString());
      prefs.setString("usersetting", jsons[0]["userSettings_id"].toString());
      prefs.setString("status", jsons[0]["status"].toString());
      prefs.setString("description", jsons[0]["description"].toString());
      prefs.setString("address", jsons[0]["address"].toString());
      prefs.setString("telephone", jsons[0]["telephone"].toString());
      prefs.setString("email", jsons[0]["email"].toString());
      prefs.setString("notify", jsons[0]["notify"].toString());
      prefs.setString("subacc_id", jsons[0]["subacc_id"].toString());
      prefs.setString("allowed_actions", jsons[0]["allowed_actions"].toString());
      prefs.setString("independent_exist", jsons[0]["independent_exist"].toString());
      prefs.setString("image", jsons[0]["image"].toString());

      Navigator.pushReplacement<void, void>(context,MaterialPageRoute<void>(builder: (BuildContext context) => Home(),),);
    } else {
      // Incorrect credentials
      Fluttertoast.showToast(
          msg: "Incorrect Credentials. Please Try Again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  } else {
    // Handle the HTTP error
    Fluttertoast.showToast(
        msg: "HTTP Request Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    // getValue();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/puma icon.png',
                      width: 100,
                    ),
                    Container(
                      child: Text(
                        'Login Here',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 22,
                          color: Constants.primary_color,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        'Welcome Back You`ve',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Color(0xff000000),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'been missed!',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Color(0xff000000),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 38, right: 38),
                      child: TextField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(
                          color: Color(0xffa8a8a8),
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF1F4FF),
                          hintText: 'Enter Email',
                          hintStyle: GoogleFonts.poppins(
                            color: Color(0xffa8a8a8),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: Color(0xffa8a8a8),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Constants.primary_color),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),

                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xffF1F4FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 38, right: 38),
                      child: TextField(
                        controller: _passwordController,
                        style: GoogleFonts.poppins(
                          color: Color(0xffa8a8a8),
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Color(0xffa8a8a8),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: Color(0xffa8a8a8),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                          ),
                          filled: true,
                          fillColor: Color(0xffF1F4FF),
                          hintText: 'Enter Password',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(
                                  0xff3b5fe0)),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xffF1F4FF)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 40),
                      child: Text(
                        'Forget Password?',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 14,
                          color: Constants.primary_color,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Constants.primary_color,

                        ),
                        onPressed: () {
                          login(context);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
/*void getValue() async {
    var prefs = await SharedPreferences.getInstance();
    var getName = (prefs.getString("userId") ?? "");
    // nameValue = getName != null ? getName : "No Value Saved ";
    if (getName == "") {
      Timer(Duration(seconds: 3), () {

        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                Home(),
          ),
        );
      });
    } else {
      Timer(Duration(seconds: 3), () {

        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                MyHomePage(),
          ),
        );
      });

    }
    setState(() {

    });
  }*/
}
