import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class AllUnread extends StatefulWidget {
  const AllUnread({super.key});
  @override
  State<AllUnread> createState() => _AllUnreadState();
}

class _AllUnreadState extends State<AllUnread> {
  dynamic t_direct_messages = [];
  dynamic t_direct_threads = [];
  dynamic t_user_channelids = [];
  dynamic t_user_threadids = [];
  dynamic t_group_messages = [];
  dynamic t_group_threads = [];
  dynamic channelIds = [];

  String? token = "";
  int? user_id;
  int? workspace_id;
  // int numberForGroup = 1;
  // int numberForGroupThread = 1;

  @override
  void initState() {
    super.initState();
    _fetchDirectUnreadMsg();
  }

  Future<void> _fetchDirectUnreadMsg() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");

    try {
      final response = await http.get(
        Uri.parse(
            "https://slackapi-team2.onrender.com/allunread?user_id=$user_id&workspace_id=$workspace_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("All Unread data $data");
        setState(() {
          t_direct_messages = data['t_direct_messages'];
          t_direct_threads = data['t_direct_threads'];
          t_user_channelids = data['t_user_channelids'];
          t_user_threadids = data["t_user_channelthreadids"];
          t_group_messages = data['t_group_messages'];
          t_group_threads = data['t_group_threads'];

          print(t_direct_threads);
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    int numberForGroupThread = 1;
    int numberForGroup = 1;
    return Scaffold(
      appBar: const MyAppBarWidget(),
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 25),
                Center(
                  child: Text(
                    '未読リスト',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'ダイレクト未読メッセージ',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(126, 22, 139, 14),
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final tDirect = t_direct_messages[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  color: const Color.fromARGB(226, 233, 238, 239),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tDirect['name'],
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 60.0),
                          Text(
                            DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                DateTime.parse(tDirect['created_at'])
                                    .toLocal()),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '--> ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 10,
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
              },
              childCount: t_direct_messages.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(thickness: 1, color: Colors.grey),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),
          const SliverToBoxAdapter(
            child: Text(
              'ダイレクト未読スレッド',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(126, 22, 139, 14),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final tThread = t_direct_threads[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  color: const Color.fromARGB(226, 233, 238, 239),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tThread['name'],
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                DateTime.parse(tThread['created_at'])
                                    .toLocal()),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '--> ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: Text(
                              tThread['directthreadmsg'],
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
              },
              childCount: t_direct_threads.length,
            ),
          ),

          //Group Unread Messages
          const SliverToBoxAdapter(
            child: Divider(thickness: 1, color: Colors.grey),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),
          const SliverToBoxAdapter(
            child: Text(
              'グループ未読メッセージ',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(126, 22, 139, 14),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final tGroup = t_group_messages[index];
                for (var tUserChannelId in t_user_channelids) {
                  if (int.parse(tUserChannelId) == tGroup["id"]) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          color: const Color.fromARGB(226, 233, 238, 239),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tGroup["channel_name"],
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${numberForGroup++}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tGroup['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                        DateTime.parse(tGroup['created_at'])
                                            .toLocal()),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const SizedBox(width: 25),
                                  const Expanded(
                                    child: Text(
                                      '--> ',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Text(
                                      tGroup['groupmsg'],
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
                    );
                  }
                }

                return Container();
              },
              childCount: t_group_messages.length,
            ),
          ),

          //Group Thread Unread Messages
          const SliverToBoxAdapter(
            child: Divider(thickness: 1, color: Colors.grey),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),
          const SliverToBoxAdapter(
            child: Text(
              'グループ未読スレッド',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(126, 22, 139, 14),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final tGroupThread = t_group_threads[index];
                for (var tUserThreadId in t_user_threadids) {
                  if (int.parse(tUserThreadId) == tGroupThread["id"]) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      color: const Color.fromARGB(226, 233, 238, 239),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${numberForGroupThread++}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tGroupThread['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                    DateTime.parse(tGroupThread['created_at'])
                                        .toLocal()),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const SizedBox(width: 25),
                              const Expanded(
                                child: Text(
                                  '--> ',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Text(
                                  tGroupThread['groupthreadmsg'],
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
                  }
                }
                return Container();
              },
              childCount: t_group_threads.length,
            ),
          ),
        ],
      ),
      drawer: const Leftpannel(),
    );
  }
}
