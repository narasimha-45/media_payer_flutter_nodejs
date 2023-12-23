import 'dart:convert';
import 'package:final_media_player/modules/home_page.dart';
import 'package:final_media_player/modules/register_page.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  Map userData = {};
  late SharedPreferences prefs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> gotoHomePage() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Future<void> pageChange() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  Future<void> _showLoginFailedDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'INVALID USERNAME OR PASSWORD',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'ok');
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> getLoggedIn() async {
    print("LoginPage");
    if (_formkey.currentState!.validate()) {
      print("login button");
      print(usernameController.text + passwordController.text);
      final response = await http.post(
          Uri.parse("http://10.0.2.2:5500/usersApi/login-user"),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": usernameController.text,
            "password": passwordController.text
          }));
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (jsonResponse["status"] == true) {
        print("LOGGED in");
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        gotoHomePage();
      } else {
        if (!context.mounted) return;
        _showLoginFailedDialog(context);
      }
    } else {
      print("No If");
    }
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }
  
  @override
  void initState() {
    initSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
            color: const Color(0x00e8bcb9),
            child: SingleChildScrollView(
                child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 160),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 35,
                        color: Color.fromARGB(255, 101, 10, 10),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 20, right: 20),
                      child: TextFormField(
                        controller: usernameController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'username required'),
                        ]),
                        decoration: const InputDecoration(
                            hintText: 'username',
                            labelText: 'username',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20, top: 10),
                      child: TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: passwordController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'password required'),
                        ]),
                        decoration: const InputDecoration(
                            hintText: 'password',
                            labelText: 'password',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(200, 50)),
                        child: const Text("login",
                            style: TextStyle(
                                color: Color.fromARGB(255, 20, 187, 217),
                                fontSize: 28)),
                        onPressed: getLoggedIn,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextButton(
                        onPressed: pageChange,
                        child: const Text("new user?Register here"),
                      ),
                    )
                  ],
                ),
              ),
            ]))),
      ),
    );
  }
}
