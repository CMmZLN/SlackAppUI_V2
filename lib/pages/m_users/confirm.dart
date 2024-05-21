import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'dart:convert';

import 'package:Team2SlackApp/pages/static_pages/welcome.dart';

class MemberConfirm extends StatefulWidget {
  String? email;
  String? channel_name;
  String? workspace_name;
  String? workspaceid;
  MemberConfirm(
      this.email, this.channel_name, this.workspace_name, this.workspaceid,
      {super.key});
  @override
  _MemberConfirmState createState() {
    print("Route1111");
    print(email);
    print(workspaceid);
    return _MemberConfirmState(
        email, channel_name, workspace_name, workspaceid);
  }
  // State<MemberConfirm> createState() => _MemberConfirmState(email);
}

class _MemberConfirmState extends State<MemberConfirm> {
  String? email;
  String? channel_name;
  String? workspace_name;
  String? workspaceid;
  _MemberConfirmState(
      this.email, this.channel_name, this.workspace_name, this.workspaceid);

  late TextEditingController nameController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController passwordConfirmController =
      TextEditingController();

  List<dynamic> error = [];
  bool _isTextBoxVisible = false;
  bool status = false;
  String? token;

  Future<bool> createNewMember(
    String name,
    // String email,
    String password,
    String passwordConfirmation,
    // String profile_image,
    // String remember_digest,
  ) async {
    token = await SharedPrefUtils.getStr("token");
    final response = await http.post(
        Uri.parse(
            "https://slackapi-team2.onrender.com/m_users?invite_workspaceid=$workspaceid"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'profile_image': channel_name,
          'remember_digest': workspace_name,
          'admin': 0,
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
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
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
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                )),
              ),
            ),
            ClipPath(
              clipper: DrawClip3(),
              child: Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4FA64F).withOpacity(0.5),
                    const Color(0xFF4FA64F).withOpacity(0.5)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                )),
              ),
            ),
            ClipPath(
              clipper: DrawClip4(),
              child: Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    const Color(0xFF85C285).withOpacity(0.5),
                    const Color(0xFF85C285).withOpacity(0.5)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                )),
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
                      "メンバー 確認",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                    ),
                    child: Visibility(
                      visible: _isTextBoxVisible,
                      child: ListView.builder(
                        shrinkWrap: true, // Adjust to fit children size
                        itemCount: error.length, // Number of error messages
                        itemBuilder: (context, index) {
                          return Row(
                            // Row to add bullets before each error message
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align messages to the top
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
                                  width:
                                      8.0), // Spacing between bullet and text
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
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, top: 20, right: 50),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '${widget.workspace_name}',
                        contentPadding:
                            const EdgeInsets.only(top: 15, bottom: 15),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0)),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, top: 10, right: 50),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '${widget.channel_name}',
                        contentPadding:
                            const EdgeInsets.only(top: 15, bottom: 15),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0)),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, top: 10, right: 50),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "名前",
                        contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, top: 10, right: 50),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '${widget.email}',
                        contentPadding:
                            const EdgeInsets.only(top: 15, bottom: 15),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0)),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
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
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, top: 10, right: 50),
                    child: TextFormField(
                      controller: passwordConfirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "パスワード確認",
                        contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff46ddbf), width: 1.0),
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
                        bool status1 = await createNewMember(
                          nameController.text,
                          passwordController.text,
                          passwordConfirmController.text,
                        );
                        if (status1 == true) {
                          showSuccessDialog(context);
                        } else {
                          _isTextBoxVisible = true;
                        }
                      },
                      child: SingleChildScrollView(
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 200,
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
                                  color:
                                      const Color(0xff31b8b1).withOpacity(0.5),
                                  width: 2),
                            ),
                            height: 40,
                            child: const Center(
                              child: Text(
                                "アカウントを作る",
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
                  ),
                ],
              ),
            ),
          ],
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

class DrawClip4 extends CustomClipper<Path> {
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
