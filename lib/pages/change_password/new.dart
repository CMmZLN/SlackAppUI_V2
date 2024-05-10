import 'dart:async';
import 'dart:convert';

import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:flutter/material.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import "package:http/http.dart" as http;
import 'package:Team2SlackApp/pages/static_pages/home.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({super.key, required this.userdata});
  dynamic userdata;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  String? token = "";
  int? user_id;
  bool _isTextBoxVisible = false;
  String error = '';
  Timer? timer;
  Future<void> changepassword(String password, String confirmpassword) async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    final response = await http.get(
      Uri.parse("https://slackapi-team2.onrender.com/home?user_id=$user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final postResponse = await http.post(
        Uri.parse(
            "https://slackapi-team2.onrender.com/change_password?user_id=$user_id"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'm_user': {
            'password': password,
            'password_confirmation': confirmpassword,
          }
        }));

    final responseJson = jsonDecode(postResponse.body);

    if (responseJson['error'] == null) {
      error = '';

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hello This is Snackbar'),
      ));
    } else {
      error = responseJson['error'];
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
              print("change password Timer");
              print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Logout()),
                    (route) => false);
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBarWidget(),
      drawer: const Leftpannel(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                  child: Center(
                    child: Text(
                      'パスワード更新',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                Visibility(
                  visible: _isTextBoxVisible,
                  child: Container(
                    width: 450.0,
                    color: const Color.fromARGB(
                        255, 233, 201, 211), // Background color
                    padding:
                        const EdgeInsets.all(8.0), // Padding around the text
                    child: Center(
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 223, 59, 47), // Text color
                          // Add more text styling as needed
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'メール',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          '${widget.userdata}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'パスワード',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          // hintText: 'Enter a search term',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'パスワード確認',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      TextFormField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(126, 22, 139, 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () async {
                          await changepassword(
                              passwordController.text, confirmController.text);
                          if (error == '') {
                            setState(() {
                              _isTextBoxVisible = false;
                            });

                            showSuccessDialog(context);
                          } else {
                            setState(() {
                              _isTextBoxVisible = true;
                            });
                          }
                        },
                        child: const Text(
                          '更新',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(20),
        content: const Text('おめでとう！ パスワードの変更が成功しました。'),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                            title: 'SLACK APP',
                          )),
                  (route) => false);
            },
            child: const Text(
              'はい',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(126, 22, 139, 14)),
            ),
          ),
        ],
      );
    },
  );
}
