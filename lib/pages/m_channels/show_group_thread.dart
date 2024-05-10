import 'dart:async';
import 'dart:convert';
import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/m_channels/show_channel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class ShowGroupThread extends StatefulWidget {
  ShowGroupThread({
    super.key,
    required this.message,
    required this.channelId,
  });

  dynamic message;
  int channelId;

  @override
  State<ShowGroupThread> createState() => _ShowGroupThreadState();
}

class _ShowGroupThreadState extends State<ShowGroupThread> {
  dynamic channelData;
  String channelName = "";
  int userCount = 0;
  String tGroupMessage = "";
  int tGroupMessageId = 0;
  String tGroupMessageUsername = "";
  final DateFormat formatter = DateFormat('jm');
  final DateFormat ymd = DateFormat('yyyy-MM-dd');
  String tGroupMessageSendHour = "";
  String tGroupMessageYMD = "";
  dynamic tGroupThread = [];
  dynamic tGroupThreadStarMsgids = [];
  dynamic channelUsersLists = [];
  // List<Map<String, dynamic>> channelUsers = [];
  String? token;
  int? user_id;
  int? workspace_id;
  bool isLoading = true;

  Timer? timer;

  bool isScroll = true;
  ScrollController threadScroller = ScrollController();

  Future showThreadMessage(int channelId, int messageId) async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");

    print("fetching showThreadMessage");
    final respone = await http.post(
        Uri.parse(
            "https://slackapi-team2.onrender.com/t_group_message/?s_channel_id=$channelId&user_id=$user_id&s_group_message_id=$messageId&workspace_id=$workspace_id"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        });
    final dynamic data = json.decode(respone.body);

    if (respone.statusCode == 200) {
      setState(() {
        isLoading = false;
        channelData = data["retrieveGroupThread"]["s_channel"];
        channelName = data["retrieveGroupThread"]["s_channel"]["channel_name"];
        userCount = data["retrieveGroupThread"]["u_count"];
        tGroupMessage =
            data["retrieveGroupThread"]["t_group_message"]["groupmsg"];
        tGroupMessageId = data["retrieveGroupThread"]["t_group_message"]["id"];
        tGroupMessageUsername = widget.message["name"];
        dynamic tGroupMessageTime = widget.message["created_at"];
        DateTime time = DateTime.parse(tGroupMessageTime);
        tGroupMessageSendHour = formatter.format(time);
        tGroupMessageYMD = ymd.format(time);
        tGroupThread = data["retrieveGroupThread"]["t_group_threads"];
        tGroupThreadStarMsgids =
            data["retrieveGroupThread"]["t_group_star_thread_msgids"];
      });
    } else {
      throw Exception("failed to load");
    }
  }

  Future<void> retrieveGroupMessage() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");

    print("fetching fetrieveGroupMessage");
    final response = await http.get(
        Uri.parse(
            "https://slackapi-team2.onrender.com/m_channels/channelshow/?id=${widget.channelId}&user_id=$user_id&workspace_id=$workspace_id"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        });
    final dynamic data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        channelUsersLists = data["retrieveGroupMessage"]["m_channel_users"];
      });
    }
  }

  @override
  // void initState() {
  //   super.initState();
  //   showThreadMessage(widget.channelId, widget.message["id"]);
  //   retrieveGroupMessage();
  // }
  @override
  void initState() {
    super.initState();

    showThreadMessage(widget.channelId, widget.message["id"]);
    retrieveGroupMessage();

    // timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
    //   if (timer?.isActive == true) {
    //     showThreadMessage(widget.channelId, widget.message["id"]);
    //     retrieveGroupMessage();
    //   }
    // });

    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
              print("Channel  thread Timer");
              print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Logout()),
                    (route) => false);
              }
              showThreadMessage(widget.channelId, widget.message["id"]);
              retrieveGroupMessage();
              
            }));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        threadScroller.animateTo(
          threadScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      });
      print("Scroller Hello Channel Thread");
      isScroll = false;
    }

    return Scaffold(
      appBar: const MyAppBarWidget(),
      drawer: const Leftpannel(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ShowChannel(channelData: channelData)),
                                (route) => false);
                          },
                          icon: const Icon(Icons.arrow_back_ios_rounded)),
                      Text(channelName,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 22.0)),
                      const SizedBox(width: 22.0),
                      const Icon(Icons.people, color: Colors.black),
                      const SizedBox(width: 10.0),
                      Text(userCount.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 22.0)),
                      const SizedBox(width: 10.0),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("1",
                          style:  TextStyle(fontSize: 20.0)),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(tGroupMessageUsername,
                            style: const TextStyle(fontSize: 20.0)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text("$tGroupMessageYMD/$tGroupMessageSendHour",
                            style: const TextStyle(fontSize: 18.0)),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(tGroupMessage,
                                style: const TextStyle(fontSize: 20.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 20),
                  child: Text("返事",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                          color: Color.fromARGB(126, 22, 139, 14))),
                ),
                // const Padding(
                //   padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                //   child: Divider(
                //     color: Colors.grey,
                //     thickness: 1.0,
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    controller: threadScroller,
                    itemCount: tGroupThread.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    tGroupThread[index]["name"],
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    "${ymd.format(DateTime.parse(tGroupThread[index]["created_at"]))}/${formatter.format(DateTime.parse(tGroupThread[index]["created_at"]))}",
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_forward),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    child: Text(
                                      tGroupThread[index]["groupthreadmsg"],
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (tGroupThreadStarMsgids
                                      .contains(tGroupThread[index]["id"]))
                                    IconButton(
                                      onPressed: () async {
                                        await destroyThreadStar(
                                            tGroupThread[index]["id"]);
                                        // if (status == true) {
                                        //   Navigator.pushAndRemoveUntil(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               ShowGroupThread(
                                        //                   message:
                                        //                       widget.message,
                                        //                   channelId: widget
                                        //                       .channelId)),
                                        //       (route) => false);
                                        // }
                                      },
                                      icon: const Icon(
                                        Icons.star,
                                        color: Color.fromARGB(126, 22, 139, 14),
                                      ),
                                    )
                                  else
                                    IconButton(
                                      onPressed: () async {
                                        await createThreadStar(
                                            tGroupThread[index]["id"]);
                                        // if (status == true) {
                                        //   Navigator.pushAndRemoveUntil(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               ShowGroupThread(
                                        //                   message:
                                        //                       widget.message,
                                        //                   channelId: widget
                                        //                       .channelId)),
                                        //       (route) => false);
                                        // }
                                      },
                                      icon: const Icon(
                                        Icons.star_outline,
                                        color: Color.fromARGB(126, 22, 139, 14),
                                      ),
                                    ),
                                  if (user_id ==
                                      tGroupThread[index]["m_user_id"])
                                    IconButton(
                                        onPressed: () async {
                                          await deleteGroupThreadMessage(
                                              tGroupThread[index]["id"],
                                              widget.channelId);
                                          // if (status == true) {
                                          //   Navigator.pushAndRemoveUntil(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) =>
                                          //               ShowGroupThread(
                                          //                   message:
                                          //                       widget.message,
                                          //                   channelId: widget
                                          //                       .channelId)),
                                          //       (route) => false);
                                          // }
                                        },
                                        icon: const Icon(
                                            Icons.delete_outline_outlined,
                                            color: Color.fromARGB(
                                                126, 22, 139, 14)))
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: sendGroupMessageInput(
                    sGroupMessageId: widget.message["id"],
                    message: widget.message,
                    channelId: widget.channelId,
                    channelUsersLists: channelUsersLists,
                  ),
                )
              ],
            ),
    );
  }

// sendGroupMessageInput(,
//                       context, widget.message, widget.channelId)
}

Future createThreadStar(int msgId) async {
  String? token;
  int? userId;
  token = await SharedPrefUtils.getStr("token");
  userId = await SharedPrefUtils.getInt("userid");
  final request = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/groupstarthread"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'threadmsgid': msgId,
        'user_id': userId,
      }));

  if (request.statusCode == 201) {
    status = true;
  }
}

Future destroyThreadStar(int msgId) async {
  String? token;
  int? userId;
  int? workspaceId;
  token = await SharedPrefUtils.getStr("token");
  userId = await SharedPrefUtils.getInt("userid");
  workspaceId = await SharedPrefUtils.getInt("workspaceid");

  final request = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/groupunstarthread"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'threadmsgid': msgId,
        'user_id': userId,
      }));

  if (request.statusCode == 201) {
    status = true;
  }
}

Future deleteGroupThreadMessage(int msgId, int channelId) async {
  String? token;
  int? userId;
  token = await SharedPrefUtils.getStr("token");
  userId = await SharedPrefUtils.getInt("userid");

  final request = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/delete_groupthread"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'threadmsgid': msgId,
        'user_id': userId,
        's_channel_id': channelId
      }));

  if (request.statusCode == 200) {
    status = true;
  }
}

// Widget sendGroupThreadMessageInput( BuildContext context,
//       ) {

//     return
//   }

class sendGroupMessageInput extends StatefulWidget {
  int sGroupMessageId;
  dynamic message;
  int channelId;
  dynamic channelUsersLists = [];
  List<Map<String, dynamic>> channelUsers = [];

  sendGroupMessageInput(
      {super.key,
      required this.sGroupMessageId,
      required this.message,
      required this.channelId,
      required this.channelUsersLists});

  @override
  State<sendGroupMessageInput> createState() => _sendGroupMessageInputState();
}

class _sendGroupMessageInputState extends State<sendGroupMessageInput> {
  String threadMsg = "";

  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();

  List mentionedNameList = [];
  @override
  Widget build(BuildContext context) {
    for (var user in widget.channelUsersLists) {
      widget.channelUsers
          .add({"id": user["id"].toString(), "display": user["name"]});
    }
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: FlutterMentions(
              onMentionAdd: addMentionedUser,
              onChanged: (value) {
                threadMsg = value;
              },
              key: key,
              suggestionPosition: SuggestionPosition.Top,
              maxLines: 1,
              minLines: 1,
              decoration: const InputDecoration(
                  hintText: 'メッセージを入力してください',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
              mentions: [
                Mention(
                    trigger: '@',
                    style: const TextStyle(color: Colors.blue, fontSize: 18),
                    data: widget.channelUsers,
                    matchAll: false,
                    suggestionBuilder: (data) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    data['display'],
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                Mention(
                  trigger: '#',
                  disableMarkup: true,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                  matchAll: true,
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 5.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 5, right: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(126, 22, 139, 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            onPressed: () async {
              await sendGroupThreadMessage(
                  threadMsg, widget.sGroupMessageId, widget.channelId);
              if (status == true) {
                key.currentState?.controller?.clear();
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ShowGroupThread(
                //             message: widget.message,
                //             channelId: widget.channelId)),
                //     (route) => false);
              }
            },
            child: const Text("送信",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                )),
          ),
        )
      ],
    );
  }

  void addMentionedUser(Map userData) {
    String userId = userData["id"];
    String userName = userData["display"];
    mentionedNameList.add(userName);
  }

  Future sendGroupThreadMessage(
      String message, int sGroupMessageId, int channelId) async {
    String mentionName = message.split(" ")[0].trim();
    String? token;
    int? userId;
    int? workspaceId;
    token = await SharedPrefUtils.getStr("token");
    userId = await SharedPrefUtils.getInt("userid");
    workspaceId = await SharedPrefUtils.getInt("workspaceid");
    List sendMessageWords = message.split(" ");

    // for (var word in sendMessageWords) {
    //   if (word.startsWith("@")) {
    //     mentionedNameList.add(word);
    //   }
    // }

    if (message.isEmpty) {
      return;
    } else {
      print('channel id ............');
      print(channelId);
      final request = await http.post(
          Uri.parse("https://slackapi-team2.onrender.com/groupthreadmsg"),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'threadmsg': message,
            'workspace_id': workspaceId,
            'user_id': userId,
            's_group_message_id': sGroupMessageId,
            'mention_name': mentionedNameList,
            's_channel_id': channelId
          }));
      if (request.statusCode == 201) {
        status = true;
      }
    }
  }
}
