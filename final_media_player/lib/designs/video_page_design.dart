import 'dart:convert';

import 'package:final_media_player/modules/video_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPageDesign extends StatefulWidget {
  const VideoPageDesign(
      {super.key,
      required this.songName,
      required this.isFavourite,
      required this.addFavourites});
  final String songName;
  final bool isFavourite;
  final Function(String songName) addFavourites;
  @override
  State<StatefulWidget> createState() {
    return _VideoPageDesignState();
  }
}

class _VideoPageDesignState extends State<VideoPageDesign> {
  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Icon icons;
    if (widget.isFavourite) {
      iconColor = Color.fromARGB(255, 4, 127, 189);
      icons = const Icon(Icons.favorite);
    } else {
      iconColor = Colors.black;
      icons = const Icon(Icons.favorite_border_sharp);
    }
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
              IconButton(
                onPressed: () {
                  widget.addFavourites(widget.songName);
                },
                icon: icons,
                color: iconColor,
              ),
            ],
          ),
        ));
  }
}
