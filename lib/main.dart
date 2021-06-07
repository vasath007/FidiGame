import 'package:fidi_game/screens/home.dart';
import 'package:fidi_game/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fidi_game/utils/constants.dart' as global;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString(global.id);
  runApp(MyApp(id));
}

class MyApp extends StatelessWidget {
  String id;
  MyApp(this.id):super();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: id == null?LoginPage():Home(),
    );
  }
}
