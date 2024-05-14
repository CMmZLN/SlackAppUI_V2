import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class MentionLists extends StatefulWidget {
  const MentionLists({super.key});

  @override
  State<MentionLists> createState() => _MentionListsState();
}

class _MentionListsState extends State<MentionLists> {
  dynamic t_group_messages = [];
  dynamic t_group_threads = [];
  dynamic t_group_star_msgids = [];
  dynamic t_group_star_thread_msgids = [];
  String? token = "";
  int? user_id;

  @override
  void initState() {
    super.initState();
    _fetchThread();
  }

  Future<void> _fetchThread() async {
    token = await SharedPrefUtils.getStr("token");
    user_id = await SharedPrefUtils.getInt("userid");

    try {
      final response = await http.get(
        Uri.parse(
            "https://slackapi-team2.onrender.com/mentionlists?user_id=$user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          t_group_messages = data['t_group_messages'];
          t_group_threads = data['t_group_threads'];
          t_group_star_msgids = data['t_group_star_msgids'];
          t_group_star_thread_msgids = data['t_group_star_thread_msgids'];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBarWidget(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'メンションリスト',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'グループメンションリスト',
                    style: TextStyle(
                      fontSize: 23,
                      color: Color.fromARGB(126, 22, 139, 14),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    itemCount: t_group_messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final tGroup = t_group_messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tGroup['channel_name'],
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
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
                                    tGroup['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 60.0),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    flex: 6,
                                    child: Text(
                                      tGroup['groupmsg'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  if (t_group_star_msgids
                                      .contains(tGroup['id']))
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star,
                                          size: 25,
                                          color:
                                              Color.fromARGB(126, 22, 139, 14),
                                        ),
                                      ),
                                    ),
                                  if (!t_group_star_msgids
                                      .contains(tGroup['id']))
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star_border_outlined,
                                          size: 25,
                                          color:
                                              Color.fromARGB(126, 22, 139, 14),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                  // ----------GROUP THREAD MENTION LISTS-----------
                  const Text(
                    'グループスレッドメンションリスト',
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 23,
                      color: Color.fromARGB(126, 22, 139, 14),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    itemCount: t_group_threads.length,
                    itemBuilder: (BuildContext context, int index) {
                      final tGroupThread = t_group_threads[index];
                      int count = 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tGroupThread['channel_name'],
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
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
                                    tGroupThread['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 60.0),
                                  Text(
                                    DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                        DateTime.parse(
                                                tGroupThread['created_at'])
                                            .toLocal()),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    flex: 6,
                                    child: Text(
                                      tGroupThread['groupthreadmsg'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  if (t_group_star_thread_msgids
                                      .contains(tGroupThread['id']))
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star,
                                          size: 25,
                                          color:
                                              Color.fromARGB(126, 22, 139, 14),
                                        ),
                                      ),
                                    ),
                                  if (!t_group_star_thread_msgids
                                      .contains(tGroupThread['id']))
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star_border_outlined,
                                          size: 25,
                                          color:
                                              Color.fromARGB(126, 22, 139, 14),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const Leftpannel(),
    );
  }
}
