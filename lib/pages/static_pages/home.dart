import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import "package:http/http.dart" as http;
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
// import 'package:Team2SlackApp/models/muser.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              const Text(
                'ホーム',
                style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 200.0,
              ),
              Text(
                'Hi! $userName',
                style: const TextStyle(fontSize: 25),
              ),
              const Text(
                '友達と楽しくメッセージを送りましょう。',
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
      ),
      drawer: const Leftpannel(),
    );
  }
}
