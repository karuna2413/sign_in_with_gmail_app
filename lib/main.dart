import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool? _checking = true;
  var user;
  GoogleSignIn googleSign = GoogleSignIn(scopes: ['email']);
  Future login() => googleSign.signIn();

  Future sign() async {
    if (Platform.isIOS || Platform.isMacOS) {
      googleSign = GoogleSignIn(
        clientId:
            "437094400885-ib3t0rv9aj3si67f4o4999rek59v8she.apps.googleusercontent.com",
        scopes: [
          'email',
        ],
      );
    }
    user = await login();
    setState(() {});
    print('user$user');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('log in with google account successful')));
  }

  _ifUserIsLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      _accessToken = loginResult.accessToken;
      final userInfo = await FacebookAuth.instance.getUserData();
      _userData = userInfo;
      setState(() {});
      print(_userData);
    } else {
      print('ResultStatus: ${loginResult.status}');
      print('Message: ${loginResult.message}');
    }
  }

  _logOut() {
    FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
  }

  @override
  // void initState() {
  //   super.initState();
  //   _ifUserIsLoggedIn();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            // _checking!
            //     ? const Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     :
            Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Welcome'),
          _userData != null
              ? Text(
                  '${_userData!['name']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 28),
                )
              : Container(),
          // _userData != null
          //     ? Container(
          //   child: Image.network(
          //      ' $_userData\['picture'\]['data']['url']'),
          // )
          //     : Container(),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              _ifUserIsLoggedIn();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('log in with facebook account successful')));
            },
            child: const Text('Log in with fb'),
          ),
          ElevatedButton(
            onPressed: () {
              _logOut();
              _userData = null;
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('log out with facebook account')));

              // Navigator.pop(context);
            },
            child: const Text('Log Out'),
          ),
          user != null ? Text(user['email']) : Text(''),
          ElevatedButton.icon(
              onPressed: sign,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('login with gmail')),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  googleSign.disconnect();
                  user = null;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('log out with google account')));
                },
                child: const Text('log out')),
          ),
        ],
      ),
    ));
  }
}
