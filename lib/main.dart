import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/following_screen.dart';
import 'screens/headlines_screen.dart';
import 'screens/news_screen.dart';
import 'screens/newsstand_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsWave',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => NewsScreen(),
        '/headlines': (context) => HeadlinesScreen(),
        '/following': (context) => FollowingScreen(),
        '/newsstand': (context) => NewsstandScreen(),
      },
    );
  }
}
