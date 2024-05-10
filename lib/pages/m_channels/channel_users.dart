import 'dart:async';
import 'dart:convert';

import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:Team2SlackApp/pages/m_channels/show_channel.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class ChannelUsers extends StatefulWidget {
  ChannelUsers({super.key, required this.channelData});
  dynamic channelData;

  @override
  State<ChannelUsers> createState() => _ChannelUsersState();
}

class _ChannelUsersState extends State<ChannelUsers> {
  dynamic mChannelsIds = [];
  List<dynamic> wUsers = [];
  List<dynamic> cUsers = [];
  List<dynamic> cUserIds = [];
  int sChannelId = 0;
  int? workspace_id;
  int? user_id;
  String? token;
  bool status = false;

  List<String> nameLists = [];
  String _name = "";

  Timer? timer;

  Future<void> getChannelUserData() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");

    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/channelusers?workspace_id=$workspace_id&s_channel_id=${widget.channelData["id"]}"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final dynamic data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        wUsers = data["w_users"];
        cUsers = data["c_users"];
        cUserIds = data["c_users_id"];
        sChannelId = data["s_channel"]["id"];
        for (var wUser in wUsers) {
          if (!cUserIds.contains(wUser["id"])) {
            nameLists.add(wUser["name"]);
          }
        }
      });
    }
  }

  Future<void> getHome() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/home?workspace_id=$workspace_id&user_id=$user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final dynamic data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        mChannelsIds = data["m_channelsids"];
      });
    }
  }

  Future<void> removeChannelUser(int sChannelId, int userId) async {
    token = await SharedPrefUtils.getStr("token");
    final response = await http.delete(
      Uri.parse(
          "https://slackapi-team2.onrender.com/channeluser/destroy/?s_channel_id=$sChannelId&user_id=$userId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      status = true;
    }
  }

  Future createChannelUser(int userId) async {
    token = await SharedPrefUtils.getStr("token");
    final response = await http.post(
        Uri.parse("https://slackapi-team2.onrender.com/channeluser/create"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{"user_id": userId, "s_channel_id": sChannelId}));
    if (response.statusCode == 200) {
      status = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getChannelUserData();
    getHome();

    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
             
              // print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) =>const Logout()),
                    (route) => false);
              }
              
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBarWidget(),
      drawer: const Leftpannel(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 0),
              child: Row(
                children: [
                  IconButton(
                      padding: const EdgeInsets.only(left: 0, right: 10),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowChannel(
                                    channelData: widget.channelData)),
                            (route) => false);
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded)),
                  Text(widget.channelData["channel_name"],
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                ],
              )),
          if (mChannelsIds.contains(sChannelId))
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
              child: Row(
                children: [
                  if (mChannelsIds.contains(sChannelId))
                    const SizedBox(width: 15),
                  if (mChannelsIds.contains(sChannelId))
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2))),
                        items: nameLists.map((String name) {
                          return DropdownMenuItem(
                              value: name,
                              child: Row(
                                children: <Widget>[
                                  Text(name),
                                ],
                              ));
                        }).toList(),
                        onChanged: (newValue) {
                          // do other stuff with _category
                          setState(() => _name = newValue!);
                        },
                        hint: const Text("名前を選択してください"),
                      ),
                    ),
                  const SizedBox(width: 5.0),
                  if (mChannelsIds.contains(sChannelId))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(50, 50),
                          backgroundColor:
                              const Color.fromARGB(126, 22, 139, 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () async {
                        for (var wUser in wUsers) {
                          if (wUser["name"] == _name) {
                            await createChannelUser(wUser["id"]);
                          }
                        }

                        if (status == true) {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChannelUsers(
                                    channelData: widget.channelData)),
                          );
                        }
                      },
                      child: const Text("追加",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Row(
              children: [
                SizedBox(width: 90, child: Text("名前")),
                SizedBox(width: 20),
                SizedBox(width: 140, child: Text("メール")),
                SizedBox(width: 80),
                SizedBox(width: 60, child: Text("設定")),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          showChannelUser(),
        ],
      ),
    );
  }

  Expanded showChannelUser() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: cUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                SizedBox(width: 90, child: Text(cUsers[index]["name"])),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(width: 130, child: Text(cUsers[index]["email"])),
                const SizedBox(
                  width: 80,
                ),
                if (cUsers[index]["created_admin"] == false &&
                    mChannelsIds.contains(sChannelId))
                  SizedBox(
                    width: 65,
                    child: TextButton(
                        onPressed: () async {
                          await removeChannelUser(
                              sChannelId, cUsers[index]["id"]);
                          if (status == true &&
                              cUsers[index]["id"] != user_id) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChannelUsers(
                                        channelData: widget.channelData)),
                                (route) => false);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyHomePage(title: "SlackApp")),
                                (route) => false);
                          }
                        },
                        child: const Text(
                          "解除",
                          style: TextStyle(
                              color: Color.fromARGB(126, 22, 139, 14),
                              fontWeight: FontWeight.bold),
                        )),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
