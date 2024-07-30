import 'package:flutter/material.dart';

import 'home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SQLite Plantas",
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.green,
          useMaterial3: true),
      home: const Home(),
    );
  }
}
