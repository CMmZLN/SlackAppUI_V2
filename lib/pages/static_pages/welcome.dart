// import 'package:flutter/material.dart';
// import 'package:Team2SlackApp/pages/m_workspace/new.dart';
// import 'package:Team2SlackApp/pages/sessions/new.dart';

// class Welcome extends StatefulWidget {
//   const Welcome({super.key});

//   @override
//   State<Welcome> createState() => _WelcomeState();
// }

// class _WelcomeState extends State<Welcome> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           "スラックアプリ",
//           style: TextStyle(
//             fontSize: 30,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(126, 22, 139, 14),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Center(
//               child: Text(
//                 'スラックアプリ',
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Center(
//               child: Text(
//                 'からようこそ',
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const Login(),
//                   ),
//                 );
//               },
//               style: TextButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(126, 22, 139, 14),
//                   shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5)))),
//               child: const Text(
//                 'ログイン',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const workspacenew(),
//                   ),
//                 );
//               },
//               style: TextButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(126, 22, 139, 14),
//                   shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5)))),
//               child: const Text(
//                 'ワークスペース作成',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
    return Scaffold(
      body: Form(
        child: Stack(
         key: _formKey,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/newlogin.jpg', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),         
            Center(
                child: SizedBox(
                  height: 450,
                  width: 400,
                  child: Card(
                    // elevation: 0.3,
                    // shadowColor: Colors.green.withOpacity(0.5),
                  
                     color: const Color.fromARGB(255, 119, 199, 119).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Set border radius
                      side: const BorderSide(
                        color: Color.fromARGB(255, 212, 195, 195),
                        width: 2,
                      ), 
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20), // Match the border radius of the Card
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.5), // Set the color of the border
                          width: 2, // Set the width of the border
                        ),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding:  EdgeInsets.fromLTRB(20, 8, 20, 5),
                            child:  Text('ログイン',
                            style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),),
                          ),
                          Visibility(
                            visible: _isTextBoxVisible,
                            child: Container(
                              width: 450.0,
                              // color: const Color.fromARGB(
                              //     255, 233, 201, 211), // Background color
                              padding: const EdgeInsets.all(5.0), // Padding around the text
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
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  controller: workspaceNameController,
                                  decoration: const InputDecoration(
                                    hintText:  'ワークスペース名',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                      contentPadding: EdgeInsets.all(5.0)),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'メール',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                      contentPadding: EdgeInsets.all(5.0)),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      hintText: 'パスワード',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5))),
                                      contentPadding: EdgeInsets.all(5.0)),
                                ),
                                const SizedBox(height: 20,),
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
                                      // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                      shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)))
                                    ), 
                                    child: const Text('ログイン',
                                      style: TextStyle(fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),)
                                      ,),
                                  ),
                                // const SizedBox(height: 10,),
                                Center(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "ワークスペースを作成するには",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const
                                              workspacenew(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'サインアップ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Color.fromARGB(255, 242, 235, 245),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
