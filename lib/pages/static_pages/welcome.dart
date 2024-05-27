import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:flutter/material.dart';
import 'package:Team2SlackApp/pages/m_workspace/new.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
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
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Stack(
            key: _formKey,
            children: [
              ClipPath(
                clipper: DrawClip1(),
                child: Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      const Color(0xFF21D375).withOpacity(0.3),
                      const Color(0xFF21D375).withOpacity(0.3)
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topLeft,
                  )),
                ),
              ),
              ClipPath(
                clipper: DrawClip2(),
                child: Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      const Color(0xFF85C285).withOpacity(0.5),
                      const Color(0xFF85C285).withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                  )),
                ),
              ),
              ClipPath(
                clipper: DrawClip3(),
                child: Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    const Color(0xFF4FA64F).withOpacity(0.5),
                    const Color(0xFF4FA64F).withOpacity(0.5)
                  ], begin: Alignment.bottomRight, end: Alignment.topLeft)),
                ),
              ),
              SizedBox(
                height: size.height,
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 50, top: 90),
                      child: Text(
                        "ログイン",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Visibility(
                        visible: _isTextBoxVisible,
                        child: Container(
                          width: 450.0,
                          // color: const Color.fromARGB(
                          //     255, 233, 201, 211), // Background color
                          padding: const EdgeInsets.all(
                              5.0), // Padding around the text
                          child: Center(
                            child: Text(
                              error,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 223, 59, 47),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 // Text color
                                  // Add more text styling as needed
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 40, top: 20, right: 50),
                      child: TextFormField(
                        controller: workspaceNameController,
                        decoration: const InputDecoration(
                          hintText: "ワークスペース名",
                          contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff46ddbf), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 40, top: 10, right: 50),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "メール",
                          contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff46ddbf), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 40, top: 10, right: 50),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "パスワード",
                          contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff46ddbf), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
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
                            FocusScope.of(context).unfocus();
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
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00A36C),
                                    const Color(0xFF00A36C).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xff31b8b1), width: 2),
                            ),
                            height: 40,
                            child: const Center(
                              child: Text(
                                "ログイン",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Center(
                      child: Text(
                        "ワークスペースを作成するには",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const workspacenew(),
                            ),
                          );
                        },
                        child: const Text(
                          'サインアップ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 49, 184, 177),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawClip1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width, 50), radius: 150));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class DrawClip2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width, 50), radius: 200));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class DrawClip3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width, 10), radius: 100));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
