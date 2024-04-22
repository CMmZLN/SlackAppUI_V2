import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:Team2SlackApp/pages/layouts/appbar.dart';
import 'package:Team2SlackApp/pages/leftpannels/leftpannel.dart';
import 'package:Team2SlackApp/pages/share_pref_utils.dart';

class Thread extends StatefulWidget {
  const Thread({super.key});

  @override
  State<Thread> createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  dynamic t_direct_messages = [];
  dynamic t_direct_threads = [];
  dynamic t_group_messages = [];
  dynamic t_group_threads = [];
  dynamic t_direct_star_msgids = [];
  dynamic t_direct_star_thread_msgids = [];
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
            "https://slackapi-team2.onrender.com/thread?user_id=$user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          t_direct_messages = data['t_direct_messages'];
          t_direct_threads = data['t_direct_threads'];
          t_group_messages = data['t_group_messages'];
          t_group_threads = data['t_group_threads'];
          t_direct_star_msgids = data['t_direct_star_msgids'];
          t_direct_star_thread_msgids = data['t_direct_star_thread_msgids'];
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
                'スレッドリスト',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ダイレクトスレッドリスト',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
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
                    itemCount: t_direct_messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      int count = 1;
                      final tDirect = t_direct_messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tDirect['name'],
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(126, 22, 139, 14),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${index + 1}.',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      tDirect['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                          DateTime.parse(
                                              tDirect['created_at'])),
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const SizedBox(width: 10),
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
                                  if (t_direct_star_msgids
                                      .contains(tDirect['id']))
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star,
                                          size: 25,
                                          color: Color.fromARGB(126, 22, 139, 14),
                                        ),
                                      ),
                                    ),
                                  if (!t_direct_star_msgids
                                      .contains(tDirect['id']))
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.star_border_outlined,
                                          size: 25,
                                          color: Color.fromARGB(126, 22, 139, 14),
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
                          const Text(
                            '返事',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color:  Color.fromARGB(126, 22, 139, 14),
                            ),
                          ),
                          Column(
                            children: List.generate(t_direct_threads.length,
                                (indexThread) {
                              final tThread = t_direct_threads[indexThread];
                              if (tDirect['id'] ==
                                  tThread['t_direct_message_id']) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${count++}.',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            tThread['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            DateFormat('yyyy-MM-dd/ hh:mm a')
                                                .format(DateTime.parse(
                                                    tThread['created_at'])),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
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
                                        if (t_direct_star_thread_msgids
                                            .contains(tThread['id']))
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.star,
                                                size: 25,
                                                color: Color.fromARGB(126, 22, 139, 14),
                                              ),
                                            ),
                                          ),
                                        if (!t_direct_star_thread_msgids
                                            .contains(tThread['id']))
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.star_border_outlined,
                                                size: 25,
                                                color: Color.fromARGB(126, 22, 139, 14),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox
                                    .shrink(); // or any other widget as per your requirement
                              }
                            }),
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
                  // ----------group lists-----------
                  const Text(
                    'グループスレッドリスト',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
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
                      int count = 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tGroup['channel_name'],
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  tGroup['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  DateFormat('yyyy-MM-dd/ hh:mm a').format(
                                      DateTime.parse(tGroup['created_at'])),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const SizedBox(width: 10),
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
                                  tGroup['groupmsg'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (t_group_star_msgids.contains(tGroup['id']))
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.star,
                                      size: 25,
                                      color: Color.fromARGB(126, 22, 139, 14),
                                    ),
                                  ),
                                ),
                              if (!t_group_star_msgids.contains(tGroup['id']))
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.star_border_outlined,
                                      size: 25,
                                      color:  Color.fromARGB(126, 22, 139, 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            '返事',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:  Color.fromARGB(126, 22, 139, 14),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children:
                                List.generate(t_group_threads.length, (index) {
                              final tGroupThread = t_group_threads[index];
                              if (tGroup['id'] ==
                                  tGroupThread['t_group_message_id']) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${count++}.',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            tGroupThread['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            DateFormat('yyyy-MM-dd/ hh:mm a')
                                                .format(DateTime.parse(
                                                    tGroupThread[
                                                        'created_at'])),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
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
                                            tGroupThread['groupthreadmsg'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        if (t_group_star_thread_msgids
                                            .contains(tGroupThread['id']))
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.star,
                                                size: 25,
                                                color: Color.fromARGB(126, 22, 139, 14),
                                              ),
                                            ),
                                          ),
                                        if (!t_group_star_thread_msgids
                                            .contains(tGroupThread['id']))
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.star_border_outlined,
                                                size: 25,
                                                color: Color.fromARGB(126, 22, 139, 14),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox
                                    .shrink(); // or any other widget as per your requirement
                              }
                            }),
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
