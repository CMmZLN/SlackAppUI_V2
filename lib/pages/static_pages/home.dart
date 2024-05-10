import 'dart:async';
import 'dart:convert';
import 'package:Team2SlackApp/pages/m_channels/show_channel.dart';
import 'package:flutter/material.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import "package:http/http.dart" as http;
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

// import 'package:Team2SlackApp/models/muser.dart';

Timer? timerHome;
bool? member_status;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '';
  String? token = "";
  int? workspace_id;
  int? user_id;

  @override
  void initState() {
    super.initState();
    fetchData();
    refresh();
    timerHome =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => memberStatus());
  }

  Future<void> memberStatus() async {
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/member_status?user_id=$user_id"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    dynamic data;
    data = json.decode(response.body);
    member_status = data["member_status"];
  }

  Future<void> refresh() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.get(
      Uri.parse("https://slackapi-team2.onrender.com/refresh?user_id=$user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return;
    } else {
      print("Not yet");
    }
  }

  Future<void> fetchData() async {
    token = await SharedPrefUtils.getStr("token");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/home?workspace_id=$workspace_id&user_id=$user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final dynamic body = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        userName = '${body["m_user"]['name']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBarWidget(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              SizedBox(
                  width: 300,
                  height: 280,
                  child: Image(image: AssetImage("assets/background.png"))),
              SizedBox(
                height: 100.0,
              ),
              Text(
                'ようこそ!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '友達と楽しくメッセージ\n     を送りましょう。',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(126, 22, 139, 14)),
              ),
            ],
          ),
        ),
      ),
      drawer: GestureDetector(
          onTap: () => {
                FocusManager.instance.primaryFocus?.unfocus(),
                keyForFlutterMention.currentState!.controller!.clear()
              },
          child: const Leftpannel()),
    );
  }
}
