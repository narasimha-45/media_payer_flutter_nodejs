import 'package:final_media_player/modules/home_page.dart';
import 'package:final_media_player/modules/login_page.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp( MaterialApp(
    home: (token != null && JwtDecoder.isExpired(token) == false)?HomePage():LoginPage(),
  ));
}
