import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:Team2SlackApp/pages/static_pages/welcome.dart';

class workspacenew extends StatefulWidget {
  const workspacenew({super.key});
  @override
  State<workspacenew> createState() => _workspacenewState();
}

class _workspacenewState extends State<workspacenew> {
  late TextEditingController workspaceNameController = TextEditingController();
  late TextEditingController channelNameController = TextEditingController();
  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController passwordConfirmController =
      TextEditingController();
  List<dynamic> error = [];
  bool _isTextBoxVisible = false;
  bool status = false;
  Future<bool> createMWorkspace(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String profileImage,
    String rememberDigest,
  ) async {
    final response = await http.post(
        Uri.parse("https://slackapi-team2.onrender.com/m_users"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'profile_image': profileImage,
          'remember_digest': rememberDigest,
          'admin': 1,
        }));
    final responseJson = jsonDecode(response.body);
    // if response.status == 201
    //     status = true;
    // end
    if (response.statusCode == 201) {
      setState(() {
        status = true;
      });
      return status;
    } else {
      setState(() {
        error = responseJson['error'];
      });
      return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "スラックアプリ",
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(126, 22, 139, 14),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: 40,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              8.0, 0, 8.0, 8.0), // Adjust top padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'ワークスペース作成',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23.0,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Visibility(
              //   visible: _isTextBoxVisible,
              //   child: Container(
              //     color: const Color.fromARGB(
              //         255, 208, 104, 138), // Background color
              //     padding: const EdgeInsets.all(8.0), // Padding around the text
              //     child: Text(
              //       'フォームには ${error.length.toString()} 以下が含まれています。',
              //     ),
              //   ),
              // ),
              Visibility(
                visible: _isTextBoxVisible,
                child: ListView.builder(
                  shrinkWrap: true, // Adjust to fit children size
                  itemCount: error.length, // Number of error messages
                  itemBuilder: (context, index) {
                    return Row(
                      // Row to add bullets before each error message
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align messages to the top
                      children: [
                        Container(
                          // Bullet container
                          margin: const EdgeInsets.only(
                              top: 4.0), // Align bullet with the text
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: Colors.red, // Bullet color
                            shape: BoxShape.circle, // Bullet shape
                          ),
                        ),
                        const SizedBox(
                            width: 8.0), // Spacing between bullet and text
                        Expanded(
                          // Expanded to fill available width
                          child: Text(
                            error[index], // Display current error message
                            style: const TextStyle(
                                color: Colors.red), // Text color
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10,),
              const Text(
                'ワークスペース名',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: workspaceNameController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'チャンネル名',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: channelNameController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '名前',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'メール',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'パスワード',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'パスワード確認',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: true,
                  controller: passwordConfirmController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool status1 = await createMWorkspace(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      passwordConfirmController.text,
                      channelNameController.text,
                      workspaceNameController.text,
                    );
                    if (status1 == true) {
                      showSuccessDialog(context);
                    } else {
                      _isTextBoxVisible = true;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(126, 22, 139, 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: const Text(
                    'アカウントを作る',
                    style: TextStyle(fontSize: 20, color: Colors.white),
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

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(15),
        content: const Text(
          'おめでとう！サインアップは成功しました。',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome()),
                  (route) => false);
            },
            child: const Text(
              'はい',
              style: TextStyle(
                  color: Color.fromARGB(126, 22, 139, 14), fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}
