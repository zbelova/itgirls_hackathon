import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:itgirls_hackathon/data/firebase_datasource.dart';

import '../data/auth_datasource.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _notes = [];
  FirebaseDatasource _notesDatasource = FirebaseDatasource();
  AuthDatasource _authDatasource = AuthDatasource();

  @override
  void initState() {
    super.initState();
    //_authDatasource.login('a@a.com', '111111');
    //_notesDatasource.write('test note2');
    // var id = FirebaseAuth.instance.currentUser?.uid;
    // print(id);
    // final ref = FirebaseDatabase.instance.ref("users/$id");
    // print(ref);
    // ref.push().set({'email': 'a@a.com', 'name': "name"});
    // ref.push().set('test user');
    _initData();

  }

  void _initData() {
    _notesDatasource.readAll().listen((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        setState(() {
          _notes = map.values.map((e) => e as String).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed:  () async {
                  await _authDatasource.logout();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Text('Выйти'))
          ],
        ),
      ),
    );
  }
}