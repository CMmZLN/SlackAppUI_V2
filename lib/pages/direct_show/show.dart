import 'dart:async';
// import 'dart:html';

import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/direct_thread_show/showthread.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class directmsgshow extends StatefulWidget {
  const directmsgshow({super.key});

  @override
  State<directmsgshow> createState() => _directmsgshowState();
}

class _directmsgshowState extends State<directmsgshow> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: DirectMessageLists(),
          ),
          // SizedBox(width: 10),
          SizedBox(
            height: 70,
            child: SendDirectMessage(),
          ),
        ],
      ),
      drawer: Leftpannel(),
    );
  }
}

class DirectMessageLists extends StatefulWidget {
  const DirectMessageLists({super.key});

  @override
  State<DirectMessageLists> createState() => _DirectMessageListsState();
}

class _DirectMessageListsState extends State<DirectMessageLists> {
  // final data;
  String s_user_name = "";
  dynamic t_direct_msg = [];
  dynamic t_direct_star_msgids = [];
  String? token = "";
  int? user_id;
  int? s_user_id;
  int? r_direct_size;
  int? workspace_id;
  Timer? timer;
  bool isScroll = true;

  // int? mUserId;
  ScrollController directMessageScroller = ScrollController();

  // Map<String,dynamic>? t_direct;

  Future<void> _fetchDirectMsgLists() async {
    print('timer loaded............');
    token = await SharedPrefUtils.getStr("token");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");
    user_id = await SharedPrefUtils.getInt("userid");
    r_direct_size = await SharedPrefUtils.getInt("rdirectsize");

    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/m_users/$s_user_id?user_id=$user_id&r_direct_size=$r_direct_size"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        s_user_name = data['s_user']['name'];
        t_direct_msg = data['t_direct_messages'];
        t_direct_star_msgids = data['t_direct_star_msgids'];
      });
      print(t_direct_msg);
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<void> _deleteDirectMsg(int id) async {
    try {
      final response = await http.delete(
          Uri.parse("https://slackapi-team2.onrender.com/directmsg/$id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // if (response.statusCode == 200) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const directmsgshow()),
      //   );
      // } else {
      //   throw Exception('Failed to delete data');
      // }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _createStarDirectMsg(int id) async {
    try {
      final response = await http.post(
          Uri.parse(
              "https://slackapi-team2.onrender.com/star?directmsgid=$id&user_id=$user_id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // if (response.statusCode == 200) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const directmsgshow()),
      //   );
      // } else {
      //   throw Exception('Failed to star message');
      // }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _deleteStarDirectMsg(int id) async {
    try {
      final response = await http.delete(
          Uri.parse(
              "https://slackapi-team2.onrender.com/unstar?directmsgid=$id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // if (response.statusCode == 200) {
      //   setState(() {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const directmsgshow()),
      //     );
      //   });
      // } else {
      //   throw Exception('Failed to unstar message');
      // }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _directmsgshow(int id) async {
    // setState(() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DirectThreadShow(id: id)),
    );
    // });
  }

  Future<void> _refreshDirectMessages() async {
    r_direct_size = await SharedPrefUtils.getInt("rdirectsize");
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");

    try {
      final response = await http.get(
          Uri.parse(
              "https://slackapi-team2.onrender.com/refresh_direct?r_direct_size=$r_direct_size&user_id=$user_id&workspace_id=$workspace_id&id=$s_user_id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          SharedPrefUtils.saveInt("rdirectsize", data);
          _fetchDirectMsgLists();
          // s_user_name = data['refresh_direct']['s_user']['name'];
          // t_direct_msg = data['refresh_direct']['t_direct_messages'];
          // t_direct_star_msgids = data['refresh_direct']['t_direct_star_msgids'];
          // if (showLastTen) {
          //   t_direct_msg = t_direct_msg.reversed.take(10).toList(); // Reversed
          // } else {
          //   t_direct_msg = t_direct_msg.reversed.toList(); // Unreversed
          // }
          // showLastTen = !showLastTen; // Toggle showLastTen state
        });
      } else {
        throw Exception("Failed to refresh direct messages");
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDirectMsgLists();
    timer = Timer.periodic(
        Duration(seconds: 2),
        (Timer t) => setState(() {
              print("DirectTimer");
              print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Logout()),
                    (route) => false);
              }
              _fetchDirectMsgLists();
            }));
  }

  @override
  void dispose() {
    print("in dispose>>>>");
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("Scrolll");
    // print(isScroll);

    // Perform your task
    if (directMessageScroller.hasClients && isScroll) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        directMessageScroller.animateTo(
          directMessageScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      });
      isScroll = false;
    }

    // if (!isScroll) {
    //   print("method");
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     directMessageScroller.animateTo(
    //       directMessageScroller.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 60),
    //       curve: Curves.easeOut,
    //     );
    //   });
    //   isScroll = true;
    // }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s_user_name,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
              // const SizedBox(
              //   height: 3,
              // ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Scrollbar(
          child: SizedBox(
            height: 550,
            child: ListView.builder(
                controller: directMessageScroller,
                itemCount: t_direct_msg.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final tDirect = t_direct_msg[index];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    color: const Color.fromARGB(226, 233, 238, 239),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd hh:m a')
                              .format(DateTime.parse(tDirect['created_at'])),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(126, 22, 139, 14),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                tDirect['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // const SizedBox(
                            //   width: 120,
                            // ),
                            IconButton(
                              onPressed: () {
                                _directmsgshow(tDirect['id']);
                              },
                              icon: const Icon(
                                Icons.message_rounded,
                                size: 25,
                                color: Color.fromARGB(126, 22, 139, 14),
                              ),
                            ),
                            Text(tDirect['count'].toString()),
                            if (t_direct_star_msgids.contains(tDirect['id']))
                              IconButton(
                                onPressed: () {
                                  _deleteStarDirectMsg(tDirect['id']);
                                },
                                icon: const Icon(
                                  Icons.star,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                            if (!t_direct_star_msgids.contains(tDirect['id']))
                              IconButton(
                                onPressed: () {
                                  _createStarDirectMsg(tDirect['id']);
                                },
                                icon: const Icon(
                                  Icons.star_border_outlined,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                            if (user_id == tDirect["send_user_id"])
                              IconButton(
                                onPressed: () {
                                  _deleteDirectMsg(tDirect['id']);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            const Text(
                              '--> ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tDirect['directmsg'],
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    ]);
  }
}

class SendDirectMessage extends StatefulWidget {
  const SendDirectMessage({super.key});

  @override
  State<SendDirectMessage> createState() => _SendDirectMessageState();
}

class _SendDirectMessageState extends State<SendDirectMessage> {
  String s_user_name = ''; // Variable to hold sender's name
  String t_direct_msg = ''; // Variable to hold direct messages
  late final TextEditingController _messageController = TextEditingController();
  bool status = false;
  String? token = "";
  int? user_id;
  int? s_user_id;

  Future<void> _sendDirectmsgLists() async {
    token = await SharedPrefUtils.getStr("token");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");
    user_id = await SharedPrefUtils.getInt("userid");

    final String message = _messageController.text;
    if (message.isEmpty) {
      print(
          "messge is empty"); // Show an error message or handle empty message case
      return;
    } else {
      print(message);
    }
    final response = await http.post(
      Uri.parse(
          "https://slackapi-team2.onrender.com/directmsg?send_user_id=$user_id&receive_user_id=$s_user_id"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'message': message,
      }),
    );
    // final data = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        status = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: "メッセージを入力してください",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.all(5)),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await _sendDirectmsgLists();
              if (status == true) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const directmsgshow()),
                // );
                _messageController.clear();
              }
            },
            style: TextButton.styleFrom(
                fixedSize: const Size(80, 48),
                backgroundColor: const Color.fromARGB(126, 22, 139, 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Text(
              '送信',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
