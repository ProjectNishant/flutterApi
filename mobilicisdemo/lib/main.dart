import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'constants.dart';
import 'dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _userName = TextEditingController();
  TextEditingController _passwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _authWidget(context));
  }

  void _loginApi() async {
    final response = await http.post(
      Uri.parse('https://ssdqa.mobilicis.com/smartrouting/api/auth/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _userName.text.toString(),
        'password': _passwd.text.toString(),
      }),
    );

    print(json.decode(response.body).toString());

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      Constants.accessToken = responseJson['accessToken'];
      Constants.tokenType = responseJson['tokenType'];

      Toast.show('Welcome User', context, duration: Toast.LENGTH_SHORT, backgroundColor: Colors.green);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Dashboard();
          },
        ),
      );
    } else {
      Toast.show('Authentication Failed \n'+'Status code: ${response.statusCode}', context, duration: Toast.LENGTH_SHORT, backgroundColor: Colors.red);

      throw Exception('Failed to load album');

    }
  }

  Widget _authWidget(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('MOBILICIS DEMO APP'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Personal Information'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: textStyle,
//              validator: emailValidator,
              controller: _userName,
              decoration: InputDecoration(
                  labelText: 'User Name',
                  hintText: 'Enter user name',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: textStyle,
//              validator: emailValidator,
              controller: _passwd,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: _loginApi,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.shade200,
                          offset: Offset(2, 4),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.lightBlueAccent, Colors.blueAccent])),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
