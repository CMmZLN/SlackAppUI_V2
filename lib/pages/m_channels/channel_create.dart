import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/models/channel.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';

class ChannelCreate extends StatefulWidget {
  const ChannelCreate({super.key});

  @override
  State<ChannelCreate> createState() => _ChannelCreateState();
}

Future createChannel(String channelName, int channelStatus) async {
  String? token = "";
  int? userId;
  int? workspaceId;
  token = await SharedPrefUtils.getStr("token");
  userId = await SharedPrefUtils.getInt("userid");
  workspaceId = await SharedPrefUtils.getInt("workspaceid");

  await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/m_channels/channelcreate"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "m_channel": {
          'channel_name': channelName,
          'channel_status': channelStatus,
          'workspace_id': workspaceId,
          'user_id': userId
        }
      }));
}

class _ChannelCreateState extends State<ChannelCreate> {
  final channelNameController = TextEditingController();
  int? channel_status;
  Future<Channel>? futureChannel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      channel_status = 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBarWidget(),
        drawer: const Leftpannel(),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "チャンネル作成",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: channel_status,
                      onChanged: (value) {
                        setState(() {
                          channel_status = value;
                        });
                      },
                    ),
                    const Text(
                      'パブリック',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        width: 20), // Add spacing between the radio buttons
                    Radio(
                      value: 0,
                      groupValue: channel_status,
                      onChanged: (value) {
                        setState(() {
                          channel_status = value;
                        });
                      },
                    ),
                    const Text(
                      'プライベート',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                    validator: (String? value) {
                      return value!.isEmpty ? 'チャネル名を入力してください。' : null;
                    },
                    controller: channelNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'チャンネル名称',
                        labelStyle: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 100,
                child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          createChannel(
                              channelNameController.text, channel_status!);
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyHomePage(
                                    title: "スラックアプリ",
                                  )),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(126, 22, 139, 14),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                    child: const Text(
                      "作成",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
        ));
  }
}
