import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool member_status = false;
  bool invalid_message = false;
  bool deactivate_message = false;
  String token = "";
  Map<String, dynamic> user_workspace = {};

  late TextEditingController workspaceNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  String error = '';
  bool _isTextBoxVisible = false;

  Future<void> CreateSignIn(
      String workspaceName, String email, String password) async {
    final response = await http.post(
        Uri.parse("https://slackapi-team2.onrender.com/signin"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'workspace_name': workspaceName,
          'email': email,
          'password': password
        }));
    final body = json.decode(response.body);
    if (body['errors'] == null) {
      error = '';
      token = body['token'];
      print("Token------> $token");
      user_workspace = body['user_workspace'];
      SharedPrefUtils.saveStr("token", body['token']);
      SharedPrefUtils.saveInt("userid", body['user_workspace']['userid']);
      SharedPrefUtils.saveInt(
          "workspaceid", body['user_workspace']['workspaceid']);
      SharedPrefUtils.saveInt("rdirectsize", 10);
      SharedPrefUtils.saveInt("rgroupsize", 10);
    } else {
      error = body['errors'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'スラックアプリ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(126, 22, 139, 14),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Visibility(
                visible: _isTextBoxVisible,
                child: Container(
                  width: 450.0,
                  color: const Color.fromARGB(
                      255, 233, 201, 211), // Background color
                  padding: const EdgeInsets.all(8.0), // Padding around the text
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
              const SizedBox(
                height: 30,
              ),
              const Text(
                'ワークスペース名',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: workspaceNameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.all(5.0)),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'メール',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.all(5.0)),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'パスワード',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.all(5.0)),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: 110,
                  child: TextButton(
                    onPressed: () async {
                      await CreateSignIn(
                        workspaceNameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                      if (error == '') {
                        setState(() {
                          _isTextBoxVisible = false;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage(
                                      title: "Slack App",
                                    )),
                            (route) => false);
                      } else {
                        setState(() {
                          _isTextBoxVisible = true;
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(126, 22, 139, 14),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                    child: const Text(
                      'ログイン',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
