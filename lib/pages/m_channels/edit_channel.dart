import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';

class EditChannel extends StatefulWidget {
  EditChannel({super.key, required this.channelData});

  dynamic channelData;

  @override
  State<EditChannel> createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  late TextEditingController channelNameController =
      TextEditingController(text: widget.channelData["channel_name"]);
  int? channel_status;
  final _formKey = GlobalKey<FormState>();
  String? token;
  int? user_id;
  int? workspace_id;

  Future editChannel(String channelName, int channelStatus) async {
    user_id = await SharedPrefUtils.getInt("userid");
    token = await SharedPrefUtils.getStr("token");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    await http.put(
        Uri.parse(
            "https://slackapi-team2.onrender.com/m_channels/channelupdate/${widget.channelData["id"]}"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "m_channel": {
            'channel_name': channelName,
            'channel_status': channelStatus
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    channel_status = widget.channelData["channel_status"] ? 1 : 0;
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
                  "チャンネル編集",
                  style: TextStyle(fontSize: 30.0),
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
                    const Text('パブリック', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                    const Text('プライベート', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                    validator: (String? value) {
                      return value!.isEmpty ? '無効なチャネル名' : null;
                    },
                    controller: channelNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'チャネル名',
                    )),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        editChannel(
                            channelNameController.text, channel_status!);
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage(
                                  title: 'SLACK APP',
                                )),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(126, 22, 139, 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text(
                    "更新",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ));
  }
}
