import 'dart:convert';
import 'package:final_media_player/modules/login_page.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:username_validator/username_validator.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  Map userData = {};
  Future<void> pageChange() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  final usernameHandler = TextEditingController();
  final passwordHandler = TextEditingController();
  final reEnterpasswordHandler = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  Future<void> _showRegisterConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'USER REGISTERED SUCCESSFULLY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Now login',
                style: TextStyle(fontSize: 14),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'ok');
                    pageChange();
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  Future<void> _showRegisterFailedDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'USER ALREADY EXIST',
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

  Future<void> getRegister() async {
    print("Register");
    if (_formkey.currentState!.validate()) {
      var response = await http.post(
          Uri.parse('http://10.0.2.2:5500/usersApi/create-user'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": usernameHandler.text,
            "password": passwordHandler.text
          }));
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (jsonResponse['status'] == true) {
        _showRegisterConfirmationDialog(context);
      } else {
        _showRegisterFailedDialog(context);
      }
    }
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
                padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: Text(
                    "Registration",
                    style: TextStyle(
                        fontSize: 35,
                        color: Color.fromARGB(255, 101, 10, 10),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(40),
              ),
              Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          controller: usernameHandler,
                          validator: (String? value) {
                            if (!RequiredValidator(errorText: 'Enter username')
                                .isValid(value)) {
                              return "Enter username";
                            } else if (!UValidator.validateThis(
                                username: value!, pattern: RegPattern.strict)) {
                              return "Invalid username";
                            }
                            return null;
                          },
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
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          obscureText: true,
                          obscuringCharacter: '*',
                          controller: passwordHandler,
                          validator: (String? value) {
                            if (!(RequiredValidator(errorText: 'enter password')
                                .isValid(value))) {
                              return "enter password";
                            } else if (!PatternValidator(r'^(?=.*?[A-Z])',
                                    errorText: "Invalid password")
                                .isValid(value)) {
                              return "password must contain capital letter";
                            } else if (!PatternValidator(r'(?=.*?[a-z])',
                                    errorText: "inavlid")
                                .isValid(value)) {
                              return "password must contain small letter";
                            } else if (!PatternValidator(r'(?=.*?[0-9])',
                                    errorText: "inavlid")
                                .isValid(value)) {
                              return "password must contain numeric";
                            } else if (!PatternValidator(r'(?=.*?[!@#\$&*~])',
                                    errorText: "inavlid")
                                .isValid(value)) {
                              return "password must contain special character";
                            } else if (!MinLengthValidator(8,
                                    errorText: "invlaid")
                                .isValid(value)) {
                              return "password must be min 8 characters";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                              hintText: 'craete password',
                              labelText: 'create password',
                              prefixIcon: Icon(
                                Icons.password_sharp,
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
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          obscureText: true,
                          obscuringCharacter: '*',
                          controller: reEnterpasswordHandler,
                          validator: (String? value) {
                            if (value != passwordHandler.text) {
                              return "password doesn't match";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hintText: 'confirm password',
                              labelText: 'confirm password',
                              prefixIcon: Icon(
                                Icons.password_sharp,
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
                          onPressed: getRegister,
                          child: const Text("Register",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 20, 187, 217),
                                  fontSize: 28)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: pageChange,
                          child: const Text(
                            "Already registered?login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
