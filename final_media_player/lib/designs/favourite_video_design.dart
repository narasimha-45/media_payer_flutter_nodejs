import 'dart:convert';
import 'package:final_media_player/modules/video_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouriteVideoPageDesign extends StatefulWidget {
  const FavouriteVideoPageDesign(
      {super.key, required this.songName});
  final String songName;
  @override
  State<StatefulWidget> createState() {
    return _FavouriteVideoPageDesignState();
  }
}

class _FavouriteVideoPageDesignState extends State<FavouriteVideoPageDesign> {

  late SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          final response = await http.get(Uri.parse(
              "http://10.0.2.2:5500/videoSongs/getSongUrl/" + widget.songName));

          final mytoken = prefs.getString('token');
          final decodedToken = JwtDecoder.decode(mytoken!);
          final username = decodedToken['username'];

          await http.put(
              Uri.parse("http://10.0.2.2:5500/usersApi/RecentlyPlayedVideos/" +
                  widget.songName),
              headers: <String, String>{'Content-Type': 'application/json'},
              body: jsonEncode({"username": username}));

          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => VideoPlayerPage(
                    url: response.body,
                  )));
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(44, 2, 137, 142),
                Color.fromARGB(30, 2, 137, 142),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Text(widget.songName),
              const Spacer(),
            ],
          ),
        ));
  }
}
