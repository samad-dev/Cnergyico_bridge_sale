import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';

class FollowupChat extends StatefulWidget {
  final String followupId;

  const FollowupChat({Key? key, required this.followupId}) : super(key: key);

  @override
  _FollowupChatState createState() => _FollowupChatState(followupId);
}

class _FollowupChatState extends State<FollowupChat> {
  final String followupId;

  _FollowupChatState(this.followupId);

  final TextEditingController _textController = TextEditingController();
  List<dynamic> chatData = [];
  var userId;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the widget is initialized
    fetchData();
    // Start the timer for periodic updates after a delay of 5 minutes
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      // Call fetchData every 5 minutes
      fetchData();
    });
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("Id");
    print('$userId ------ $followupId');
    final url = Uri.parse(
        'http://151.106.17.246:8080/bycobridgeApis/get/get_followup_chats.php?key=03201232927&followup_id=$followupId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        chatData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> postChat() async {
    try {
      var url = Uri.parse('http://151.106.17.246:8080/bycobridgeApis/create/create_followup_chatlog.php');
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'user_id': '$userId',
        'followup_id': '$followupId',
        'message_des': _textController.text.toString(),
        'row_id': ''
      });
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Post successful');
        _textController.clear();
        fetchData();
      } else {
        print('Failed to post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildMessage(String name, String privilege, String description, String time, bool isCurrentUser) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Card(
                color: isCurrentUser ? Constants.secondary_color : Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "$name",//($privilege)
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            color: isCurrentUser ? Constants.primary_color : Colors.black,
                          )
                      ),
                      SizedBox(height: 5),
                      Text(
                          description,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(time, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildChatList() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: chatData.length,
        itemBuilder: (_, int index) {
          String createdAt = chatData[index]['created_at'];
          String date = createdAt.split(' ')[0]; // Extracting date part
          String time = createdAt.split(' ')[1]; // Extracting date part

          // Check if the current date is different from the previous one
          bool isNewDate = index == 0 || date != chatData[index - 1]['created_at'].split(' ')[0];

          return Container(
            child: Column(
              children: [
                if (isNewDate)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                _buildMessage(
                  chatData[index]['name'],
                  chatData[index]['privilege'],
                  chatData[index]['description'],
                  time,
                  userId == chatData[index]['user_id'],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter your message...',
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if(_textController.text.isNotEmpty){
                  postChat();
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primary_color,
        iconTheme: IconThemeData(color: Constants.secondary_color),
        title: Text(
          'Followup Chat',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Constants.secondary_color,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildChatList(),
          _buildTextInput(),
        ],
      ),
    );
  }
}
