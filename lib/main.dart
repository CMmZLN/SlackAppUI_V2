import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:Team2SlackApp/pages/static_pages/deep_link_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Portal(
      child: MaterialApp(
    home: DeepLinkHandler(),
    debugShowCheckedModeBanner: false,
  )));
}
