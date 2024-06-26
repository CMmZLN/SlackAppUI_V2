import 'dart:async';
import 'package:Team2SlackApp/pages/direct_show/show.dart';
import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';

import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

ScrollController directThreadMessageScroller = ScrollController();

class DirectThreadShow extends StatefulWidget {
  const DirectThreadShow({super.key, required this.id});
  final int id;
  @override
  State<DirectThreadShow> createState() => _DirectThreadShowState();
}

class DirectThreadMessageLists extends StatefulWidget {
  int? id;
  DirectThreadMessageLists({super.key, required this.id});

  @override
  State<DirectThreadMessageLists> createState() =>
      _DirectThreadMessageListsState();
}

class _DirectThreadMessageListsState extends State<DirectThreadMessageLists> {
  // final data;
  String s_user_name = "";
  dynamic t_direct_msg = [];
  dynamic t_direct_thread = [];
  dynamic t_direct_star_msgids = [];
  dynamic t_direct_star_thread_msgids = [];
  String send_user_name = "";
  String? token = "";
  int? user_id;
  int? s_user_id;
  String directMsg = "";
  String directMsgDate = "";

  Timer? timer;

  bool isScroll = true;

  // Map<String,dynamic>? t_direct;

  Future<void> _fetchDirectThreadMsg(int tDirectMessageId) async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");

    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/directthreadmsg?t_direct_message_id=$tDirectMessageId&user_id=$user_id&s_user_id=$s_user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        // print(data);
        s_user_name = data['s_user']['name'];
        t_direct_msg = data['t_direct_message'];
        t_direct_thread = data['t_direct_threads'];
        t_direct_star_thread_msgids = data['t_direct_star_thread_msgids'];
        send_user_name = data['send_user']["name"];
        directMsg = data['t_direct_message']["directmsg"];
        directMsgDate = DateFormat('yyyy-MM-dd hh:m a')
            .format(DateTime.parse(t_direct_msg['created_at']).toLocal());

        print(directMsg);
        print(t_direct_thread);
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<void> _deleteDirectThreadMsg(int id) async {
    int sDirectMessageId = t_direct_msg['id'];
    token = await SharedPrefUtils.getStr("token");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");
    user_id = await SharedPrefUtils.getInt("userid");

    try {
      final response = await http.delete(
        Uri.parse(
            "https://slackapi-team2.onrender.com/directthreadmsg?directthreadid=$id&user_id=$user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      // if (response.statusCode == 200) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => DirectThreadShow(id: sDirectMessageId)),
      //   );
      // } else {
      //   throw Exception('Failed to delete data');
      // }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _createStarDirectThreadMsg(int id) async {
    int tDirectMessageId = t_direct_msg['id'];
    token = await SharedPrefUtils.getStr("token");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");
    user_id = await SharedPrefUtils.getInt("userid");

    try {
      final response = await http.post(
          Uri.parse(
              "https://slackapi-team2.onrender.com/starthread?directthreadid=$id&user_id=$user_id&s_user_id=$s_user_id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            't_direct_message_id': tDirectMessageId,
          }));
      // if (response.statusCode == 200) {
      //   setState(() {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => DirectThreadShow(id: tDirectMessageId)),
      //     );
      //   });
      // } else {
      //   throw Exception('Failed to star message');
      // }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _deleteStarDirectThreadMsg(int id) async {
    int tDirectMessageId = t_direct_msg['id'];
    token = await SharedPrefUtils.getStr("token");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");
    user_id = await SharedPrefUtils.getInt("userid");

    try {
      final response = await http.delete(
          Uri.parse(
              "https://slackapi-team2.onrender.com/unstarthread?directthreadid=$id&user_id=$user_id&s_user_id=$s_user_id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            't_direct_message_id': tDirectMessageId,
          }));
      if (response.statusCode == 200) {
        // setState(() {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => DirectThreadShow(id: tDirectMessageId)),
        //   );
        // });
      } else {
        throw Exception('Failed to unstar message');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    _fetchDirectThreadMsg(widget.id!);
    // timer = Timer.periodic(
    //     const Duration(seconds: 2),
    //     (Timer t) => setState(() {
    //           _fetchDirectThreadMsg(widget.id);
    //         }));

    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
              print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Logout()),
                    (route) => false);
              }
              _fetchDirectThreadMsg(widget.id!);
            }));

    // timer = Timer.periodic(
    //     const Duration(seconds: 2),
    //     (Timer t) => {
    //           if (timer?.isActive == true) {_fetchDirectThreadMsg(widget.id)}
    //         });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (directThreadMessageScroller.hasClients && isScroll) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        directThreadMessageScroller.animateTo(
          directThreadMessageScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      });
      isScroll = false;
    }
    return CustomScrollView(
      controller: directThreadMessageScroller,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const directmsgshow()),
                                      (route) => false);
                                },
                                icon: const Icon(Icons.arrow_back_ios_rounded)),
                            Text(
                              s_user_name,
                              style: const TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 119, 199, 119)
                        .withOpacity(0.4),
                    width: 2,
                  ),
                  color: user_id == t_direct_msg["send_user_id"]
                      ? const Color.fromARGB(255, 119, 199, 119)
                          .withOpacity(0.4)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      directMsgDate,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(126, 22, 139, 14),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Text(
                          '${1}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            send_user_name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 120,
                        // ),
                      ],
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
                            directMsg,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const Padding(
                padding:
                    EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                child: Text(
                  '返事',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(126, 22, 139, 14),
                  ),
                ),
              ),
              // Add some space between "Reply" and the list items
              for (int index = 0; index < t_direct_thread.length; index++)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromARGB(255, 119, 199, 119)
                          .withOpacity(0.4),
                      width: 2,
                    ),
                    color: user_id == t_direct_thread[index]["m_user_id"]
                        ? const Color.fromARGB(255, 119, 199, 119)
                            .withOpacity(0.4)
                        : Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd hh:m a').format(DateTime.parse(
                                t_direct_thread[index]['created_at'].toString())
                            .toLocal()),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(126, 22, 139, 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Text(
                              t_direct_thread[index]["name"],
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 120),
                          if (t_direct_star_thread_msgids
                              .contains(t_direct_thread[index]['id']))
                            Expanded(
                              child: IconButton(
                                onPressed: () {
                                  _deleteStarDirectThreadMsg(
                                      t_direct_thread[index]['id']);
                                },
                                icon: const Icon(
                                  Icons.star,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                            ),
                          if (!t_direct_star_thread_msgids
                              .contains(t_direct_thread[index]['id']))
                            Expanded(
                              child: IconButton(
                                onPressed: () {
                                  _createStarDirectThreadMsg(
                                      t_direct_thread[index]['id']);
                                },
                                icon: const Icon(
                                  Icons.star_border_outlined,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                            ),
                          if (user_id == t_direct_thread[index]["m_user_id"])
                            Expanded(
                              child: IconButton(
                                onPressed: () {
                                  _deleteDirectThreadMsg(
                                      t_direct_thread[index]['id']);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          const Text(
                            '--> ',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              t_direct_thread[index]['directthreadmsg'],
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SendDirectThreadMessage extends StatefulWidget {
  const SendDirectThreadMessage({super.key, required this.id});
  final int id;

  @override
  State<SendDirectThreadMessage> createState() =>
      _SendDirectThreadMessageState();
}

class _SendDirectThreadMessageState extends State<SendDirectThreadMessage> {
  late TextEditingController messageController = TextEditingController();
  String s_user_name = "";
  bool status = false;
  String? token = "";
  int? user_id;
  int? s_user_id;

  bool _btnActive = false;
  String sendThreadText = "";

  Future<void> _sendDirectThread(String message, int id) async {
    // final String message = messageController.text;
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    s_user_id = await SharedPrefUtils.getInt("s_user_id");

    if (message.isEmpty) {
      print(
          "messge is empty"); // Show an error message or handle empty message case
      return;
    } else {
      print(message);
    }
    final response = await http.post(
        Uri.parse(
            "https://slackapi-team2.onrender.com/directthreadmsg?t_direct_message_id=$id&m_user_id=$user_id&receive_user_id=$s_user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, dynamic>{'directthreadmsg': message.trim()},
        ));
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
              controller: messageController,
              decoration: const InputDecoration(
                  hintText: "メッセージを入力してください",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.all(5)),
              onChanged: (dynamic value) {
                sendThreadText = value;
                setState(() {
                  _btnActive = value.isNotEmpty && value[0] != " " ||
                          value.contains(RegExp(
                              r"[a-zA-Z一-龯ぁ-んァ-ン0-9$&+,:;=?@#|'<>.^*()%!-]"))
                      ? true
                      : false;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {
              _btnActive ? _sendDirectThread(sendThreadText, widget.id) : null;
              if (_btnActive == true) {
                messageController.clear();
                setState(() {
                  _btnActive = false;
                });
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  directThreadMessageScroller.animateTo(
                    directThreadMessageScroller.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 60),
                    curve: Curves.easeOut,
                  );
                });

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => DirectThreadShow(
                //         id: widget.id,
                //       ),
                //     ));
              }
            },
            style: TextButton.styleFrom(
                fixedSize: const Size(80, 48),
                backgroundColor: _btnActive
                    ? const Color.fromARGB(126, 22, 139, 14)
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: Text(
              '送信',
              style: TextStyle(
                color: _btnActive
                    ? Colors.white
                    : const Color.fromARGB(126, 22, 139, 14),
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

class _DirectThreadShowState extends State<DirectThreadShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: DirectThreadMessageLists(id: widget.id),
          ),
          // SizedBox(width: 10),
          SizedBox(
            height: 70,
            child: SendDirectThreadMessage(id: widget.id),
          ),
        ],
      ),
      drawer: const Leftpannel(),
    );
  }
}
