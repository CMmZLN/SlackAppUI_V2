import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Team2SlackApp/pages/change_password/new.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import "package:http/http.dart" as http;
import 'package:Team2SlackApp/pages/static_pages/welcome.dart';

class MyAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MyAppBarWidget> createState() => _MyAppBarWidgetState();
}

class _MyAppBarWidgetState extends State<MyAppBarWidget> {
  String email = "";
  String? token = "";
  int? workspace_id;
  int? user_id;

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
        email = '${body["m_user"]['email']}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Future<void> _Logout(int id) async {
    await SharedPrefUtils.remove("token");
    await SharedPrefUtils.remove("workspaceid");
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.delete(Uri.parse(
        "https://slackapi-team2.onrender.com/logout?user_id=$user_id"));
    if (response.statusCode == 200) {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Welcome()),
        );
      });
    } else {
      throw Exception('Failed to Logout');
    }
    await SharedPrefUtils.remove("userid");
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "スラックアプリ",
        style: TextStyle(fontSize: 20),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color.fromARGB(126, 22, 139, 14),
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyHomePage(
                          title: 'スラックアプリ',
                        )));
          },
        ),
        IconButton(
          icon: const Icon(Icons.lock),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangePassword(
                        userdata: email,
                      )),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // timer?.cancel();
            
            _Logout(user_id!);
          },
        ),
      ],
    );
  }
}
