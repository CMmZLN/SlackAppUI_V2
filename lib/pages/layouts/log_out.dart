import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/welcome.dart';
import 'package:flutter/material.dart';

import "package:http/http.dart" as http;

class Logout extends StatefulWidget {
  const Logout({super.key});
  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return const Welcome();
  }

  @override
  void initState() {
    super.initState();
    _Logout();
  }

  dynamic user_id;
  @override
  Future<void> _Logout() async {
    await SharedPrefUtils.remove("token");
    await SharedPrefUtils.remove("workspaceid");
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.delete(Uri.parse(
        "https://slackapi-team1.onrender.com/logout?user_id=$user_id"));
    // if (response.statusCode == 200) {
    // } else {
    //   throw Exception('Failed to Logout');
    // }
    await SharedPrefUtils.remove("userid");
  }
}
