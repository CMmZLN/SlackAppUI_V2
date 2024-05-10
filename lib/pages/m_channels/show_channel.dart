// ignore_for_file: avoid_unnecessary_containers

import 'dart:async';
import 'dart:convert';
import 'package:Team2SlackApp/pages/layouts/log_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/m_channels/channel_users.dart';
import 'package:Team2SlackApp/pages/m_channels/edit_channel.dart';
import 'package:Team2SlackApp/pages/m_channels/show_group_thread.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';
import 'package:Team2SlackApp/pages/static_pages/home.dart';

bool status = false;

GlobalKey<FlutterMentionsState> keyForFlutterMention =
    GlobalKey<FlutterMentionsState>();

class ShowChannel extends StatefulWidget {
  ShowChannel({super.key, required this.channelData});

  dynamic channelData;

  @override
  State<ShowChannel> createState() => _ShowChannelState();
}

class _ShowChannelState extends State<ShowChannel> {
  int userCount = 0;
  dynamic tGroupMessage = [];
  dynamic tGroupMessageDates = [];
  dynamic tGroupMessageDatesSizes = [];
  dynamic tGroupStarMsgids = [];
  final DateFormat formatter = DateFormat('jm');
  final DateFormat ymd = DateFormat('yyyy-MM-dd');
  int channelId = 0;
  dynamic channelData = [];
  dynamic channelUsersLists = [];

  String channelName = "";
  int? mUserId;
  int? user_id;
  int? workspace_id;
  String? token = "";
  dynamic mChannelIds = [];
  bool isLoading = true;
  bool isScroll = true;
  Timer? timer;
  Future<void> fetchData() async {
    
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/home?workspace_id=$workspace_id&user_id=$user_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final dynamic body = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        mChannelIds = body["m_channelsids"];
      });
    }
  }

  Future<void> retrieveGroupMessage() async {
   
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    final response = await http.get(
      Uri.parse(
          "https://slackapi-team2.onrender.com/m_channels/channelshow?id=${widget.channelData["id"]}&user_id=$user_id&workspace_id=$workspace_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final dynamic data = json.decode(response.body);
    if (response.statusCode == 200) {
      isLoading = false;
      setState(() {
        userCount = data["retrieveGroupMessage"]["u_count"];
        tGroupMessageDates =
            data["retrieveGroupMessage"]["t_group_message_dates"];
        tGroupMessageDatesSizes =
            data["retrieveGroupMessage"]["t_group_message_datesize"];
        tGroupMessage = data["retrieveGroupMessage"]["t_group_messages"];
        channelId = data["retrieveGroupMessage"]["s_channel"]["id"];
        channelData = data["retrieveGroupMessage"]["s_channel"];
        channelName = data["retrieveGroupMessage"]["s_channel"]["channel_name"];
        tGroupStarMsgids = data["retrieveGroupMessage"]["t_group_star_msgids"];
        channelUsersLists = data["retrieveGroupMessage"]["m_channel_users"];
      });
      
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   retrieveGroupMessage();
  //   fetchData();
  // }
  @override
  void initState() {
    super.initState();
    //   if (timer?.isActive == true) {
    //     retrieveGroupMessage();
    //     fetchData();
    //   }
    // });
    timer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer t) => setState(() {
              
              // print(member_status);
              if (member_status == false) {
                timerHome?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Logout()),
                    (route) => false);
              }
              retrieveGroupMessage();
              fetchData();
            }));
  }

  @override
  void dispose() {
  
    timer?.cancel();

    super.dispose();
  }

  Widget showMessages(
      dynamic tGroupMessageDates,
      dynamic tGroupMessageDatesSizes,
      dynamic tGroupMessage,
      DateFormat formatter,
      DateFormat ymd,
      dynamic tGroupStarMsgids,
      dynamic channelData) {
    ScrollController groupMessageDateScroller = ScrollController();
    ScrollController groupMessageScroller = ScrollController();
    // bool isScroll = true;

    if (isScroll) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        groupMessageDateScroller.animateTo(
          groupMessageDateScroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      });
      
      isScroll = false;
    }

    return Scrollbar(
      child: ListView.builder(
        controller: groupMessageDateScroller,
        itemCount: tGroupMessageDates.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index1) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tGroupMessageDatesSizes
                .contains(tGroupMessageDates[index1]["created_date"]))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child: Text(
                      tGroupMessageDates[index1]["created_date"],
                      style: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(126, 22, 139, 14)),
                    ),
                  ),
                  ListView.builder(
                    controller: groupMessageScroller,
                    shrinkWrap: true, // important
                    itemCount: tGroupMessage.length,
                    itemBuilder: (context, index) => Column(
                      children: <Widget>[
                        if (tGroupMessageDates[index1]["created_date"]
                                .toString() ==
                            ymd.format(DateTime.parse(
                                tGroupMessage[index]["created_at"].toString())))
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${index + 1}",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      tGroupMessage[index]["name"],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      formatter.format(DateTime.parse(
                                          tGroupMessage[index]["created_at"])),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                        onPressed: () {
                                          timer?.cancel();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShowGroupThread(
                                                        message: tGroupMessage[
                                                            index],
                                                        channelId:
                                                            channelData["id"])),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.message,
                                          size: 15,
                                          color:
                                              Color.fromARGB(126, 22, 139, 14),
                                        ),
                                        label: Text(
                                          tGroupMessage[index]["count"]
                                              .toString(),
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  126, 22, 139, 14)),
                                        )),
                                    if (tGroupStarMsgids
                                        .contains(tGroupMessage[index]["id"]))
                                      IconButton(
                                          onPressed: () async {
                                            await destroyStar(
                                                tGroupMessage[index]["id"]);
                                            // if (status == true) {
                                            //   Navigator.pushAndRemoveUntil(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               ShowChannel(
                                            //                   channelData:
                                            //                       channelData)),
                                            //       (route) => false);
                                            // }
                                          },
                                          icon: const Icon(Icons.star),
                                          color: const Color.fromARGB(
                                              126, 22, 139, 14))
                                    else
                                      IconButton(
                                          onPressed: () async {
                                            await createStar(
                                                tGroupMessage[index]["id"]);
                                            // if (status == true) {
                                            //   Navigator.pushAndRemoveUntil(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               ShowChannel(
                                            //                   channelData:
                                            //                       channelData)),
                                            //       (route) => false);
                                            // }
                                          },
                                          icon: const Icon(Icons.star_outline),
                                          color: const Color.fromARGB(
                                              126, 22, 139, 14)),
                                    if (user_id ==
                                        tGroupMessage[index]["m_user_id"])
                                      IconButton(
                                        onPressed: () async {
                                          await deleteGroupMessage(
                                              tGroupMessage[index]["id"],
                                              channelData["id"]);
                                          // if (status == true) {
                                          //   Navigator.pushAndRemoveUntil(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) =>
                                          //               ShowChannel(
                                          //                   channelData:
                                          //                       channelData)),
                                          //       (route) => false);
                                          // }
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                        color: const Color.fromARGB(
                                            126, 22, 139, 14),
                                      )
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(60, 0, 20, 20),
                                    child: Icon(Icons.arrow_forward),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 20),
                                      child: Text(
                                          tGroupMessage[index]["groupmsg"],
                                          style: const TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  width: 370.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 206, 205, 205),
                                          width: 1.0),
                                    ),
                                  )),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Text("Error"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        // keyForFlutterMention.currentState?.controller?.clear()
      },
      child: Scaffold(
        appBar: const MyAppBarWidget(),
        drawer: const Leftpannel(),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(channelName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10.0),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChannelUsers(channelData: channelData)),
                            );
                          },
                          icon: const Icon(Icons.people, color: Colors.black),
                          label: Text(userCount.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20.0)),
                        ),
                        const SizedBox(width: 10.0),
                        Row(
                          children: [
                            if (mChannelIds.contains(channelId))
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditChannel(
                                            channelData: widget.channelData,
                                            channelName: channelName)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    // Set the background color to gray
                                    elevation: 0,
                                    shadowColor: Colors.transparent),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit,
                                        color: Colors.black), // Edit icon
                                    SizedBox(
                                        width:
                                            8), // Add spacing between icon and text
                                    // Button text
                                  ],
                                ),
                              ),
                            if (mChannelIds.contains(channelId))
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent),
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    insetPadding: const EdgeInsets.all(10),
                                    title: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: const Text(
                                          '削除してもよろしいですか。',
                                          style: TextStyle(letterSpacing: 1),
                                        )),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'キャンセル'),
                                        child: const Text('キャンセル'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          timer?.cancel();
                                          deleteChannel(
                                              widget.channelData["id"]);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MyHomePage(
                                                        title: 'SLACK APP',
                                                      )),
                                              (route) => false);
                                        },
                                        child: const Text('はい'),
                                      ),
                                    ],
                                  ),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.black),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Expanded(
                      flex: 3,
                      child: showMessages(
                          tGroupMessageDates,
                          tGroupMessageDatesSizes,
                          tGroupMessage,
                          formatter,
                          ymd,
                          tGroupStarMsgids,
                          channelData)),
                  isLoading
                      ? const Text("")
                      : Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: mChannelIds.contains(channelId)
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: SendGroupMessageInput(
                                      channelData: channelData,
                                      channelId: channelId,
                                      channelUsersLists: channelUsersLists))
                              : SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        await channelJoin(channelId);
                                       
                                        if (status == true) {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowChannel(
                                                          channelData:
                                                              channelData)),
                                              (route) => false);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          backgroundColor: const Color.fromARGB(
                                              126, 22, 139, 14)),
                                      child: const Text("参加",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                ))
                ],
              ),
      ),
    );
  }
}

Future channelJoin(int sChannelId) async {
  String? token;
  int? userId;
  token = await SharedPrefUtils.getStr("token");
  userId = await SharedPrefUtils.getInt("userid");

  final request = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/channelUserJoin"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic>{'s_channel_id': sChannelId, 'userid': userId}));

  if (request.statusCode == 200) {
    status = true;
  }
}

Future createStar(int msgId) async {
  String? token;
  int? userId;
  userId = await SharedPrefUtils.getInt("userid");
  token = await SharedPrefUtils.getStr("token");
  final response = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/groupstarmsg"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'msgid': msgId,
        'user_id': userId,
      }));

  // if (response.statusCode == 201) {
  //   status = true;
  // }
}

Future destroyStar(int msgId) async {
  String? token;
  int? userId;
  userId = await SharedPrefUtils.getInt("userid");
  token = await SharedPrefUtils.getStr("token");
  final response = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/groupunstar"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'msgid': msgId,
        'user_id': userId,
      }));
  if (response.statusCode == 200) {
    status = true;
  }
}

Future deleteGroupMessage(int msgId, int channelId) async {
  String? token;
  int? userId;
  userId = await SharedPrefUtils.getInt("userid");
  token = await SharedPrefUtils.getStr("token");
  final request = await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/delete_groupmsg"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': msgId,
        'user_id': userId,
        'channel_id': channelId
      }));

  if (request.statusCode == 200) {
    status = true;
  }
}

Future deleteChannel(int channelId) async {
  String? token;
  token = await SharedPrefUtils.getStr("token");
  await http.post(
      Uri.parse("https://slackapi-team2.onrender.com/delete_channel"),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'s_channel_id': channelId}));
}

class SendGroupMessageInput extends StatefulWidget {
  dynamic channelData;
  int channelId;
  dynamic channelUsersLists;
  List<Map<String, dynamic>> channelUsers = [];
  SendGroupMessageInput(
      {super.key,
      required this.channelData,
      required this.channelId,
      required this.channelUsersLists});

  @override
  State<SendGroupMessageInput> createState() => _SendGroupMessageInputState();
}

class _SendGroupMessageInputState extends State<SendGroupMessageInput> {
  List<String> mentionedNameList = [];
  String sendText = "";

  @override
  Widget build(BuildContext context) {
    for (var user in widget.channelUsersLists) {
      widget.channelUsers
          .add({"id": user["id"].toString(), "display": user["name"]});
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            child: FlutterMentions(
              onMentionAdd: addMentionedUser,
              onChanged: (value) {
                sendText = value;
              },
              key: keyForFlutterMention,
              suggestionPosition: SuggestionPosition.Top,
              maxLines: 1,
              minLines: 1,
              suggestionListDecoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(10.0), // Border radius
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2), blurRadius: 5.0)
                ], // Shadow
              ),
              decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  hintText: 'メッセージを入力してください',
                  border: OutlineInputBorder()),
              mentions: [
                Mention(
                    trigger: '@',
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(50, 50),
              backgroundColor: const Color.fromARGB(126, 22, 139, 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: () async {
            await sendGroupMessage(sendText, widget.channelId);
            if (status == true) {
              keyForFlutterMention.currentState?.controller?.clear();
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             ShowChannel(channelData: widget.channelData)),
              //     (route) => false);
            }
          },
          child: const Text("送信",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  void addMentionedUser(Map userData) {
    String userId = userData["id"];
    String userName = userData["display"];
    mentionedNameList.add(userName);
  }

  Future sendGroupMessage(String message, int channelId) async {
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
      final response = await http.post(
          Uri.parse("https://slackapi-team2.onrender.com/groupmsg"),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'message': message,
            'workspace_id': workspaceId,
            'user_id': userId,
            's_channel_id': channelId,
            'mention_name': mentionedNameList
          }));
      setState(() {
        if (response.statusCode == 200) {
          status = true;
        }
      });
    }
  }
}
