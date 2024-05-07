import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';

import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class DirectThreadShow extends StatefulWidget {
  const DirectThreadShow({super.key, required this.id});
  final int id;
  @override
  State<DirectThreadShow> createState() => _DirectThreadShowState();
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

class DirectThreadMessageLists extends StatefulWidget {
  final int id;
  const DirectThreadMessageLists({super.key, required this.id});

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
    print("Direct Thread Working");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/directthreadmsg?t_direct_message_id=$tDirectMessageId&user_id=$user_id&s_user_id=$s_user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      // setState(() {
      final data = jsonDecode(response.body);
      print('data.........');
      print(data);
      s_user_name = data['s_user']['name'];
      t_direct_msg = data['t_direct_message'];
      t_direct_thread = data['t_direct_threads'];
      t_direct_star_thread_msgids = data['t_direct_star_thread_msgids'];
      send_user_name = data['send_user']["name"];
      directMsg = data['t_direct_message']["directmsg"];
      directMsgDate = DateFormat('yyyy-MM-dd hh:m a')
          .format(DateTime.parse(t_direct_msg['created_at'].toString()));
      // });
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
    super.initState();
    _fetchDirectThreadMsg(widget.id);
    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
              _fetchDirectThreadMsg(widget.id);
            }));

    // timer = Timer.periodic(
    //     const Duration(seconds: 2),
    //     (Timer t) => {
    //           if (timer?.isActive == true) {_fetchDirectThreadMsg(widget.id)}
    //         });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  ScrollController directThreadMessageScroller = ScrollController();
  @override
  Widget build(BuildContext context) {
    if (directThreadMessageScroller.hasClients && isScroll) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        directThreadMessageScroller.animateTo(
          directThreadMessageScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
        print("Scroller Work in directThread.");
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
                        Text(
                          s_user_name,
                          style: const TextStyle(
                            fontSize: 30,
                          ),
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
                color: const Color.fromARGB(226, 233, 238, 239),
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
                  color: const Color.fromARGB(226, 233, 238, 239),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd hh:m a').format(DateTime.parse(
                            t_direct_thread[index]['created_at'])),
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

  Future<void> _sendDirectThread(int id) async {
    final String message = messageController.text;
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");

    if (message.isEmpty) {
      print(
          "messge is empty"); // Show an error message or handle empty message case
      return;
    } else {
      print(message);
    }
    final response = await http.post(
        Uri.parse(
            "https://slackapi-team2.onrender.com/directthreadmsg?t_direct_message_id=$id&m_user_id=$user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, dynamic>{'directthreadmsg': message},
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
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await _sendDirectThread(widget.id);
              if (status == true) {
                messageController.clear();
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
