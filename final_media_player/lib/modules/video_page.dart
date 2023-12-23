import 'dart:convert';
import 'package:final_media_player/designs/video_page_design.dart';
import 'package:final_media_player/modules/video_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _VideoPageState();
  }
}

class _VideoPageState extends State<VideoPage> {
  late List<String> videoSongs = [];
  late List<String> favouritevideoSongs;
  late SharedPreferences prefs;
  final TextEditingController _controller = TextEditingController();
  Future<void> getSongs() async {
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response = await http
        .get(Uri.parse("http://10.0.2.2:5500/videoSongs/getAllSongs"));
    final List<dynamic> decodedResponse = jsonDecode(response.body);
    print(decodedResponse);
    final response2 = await http.get(Uri.parse(
        "http://10.0.2.2:5500/usersApi/getFavouriteVideos/" + username));
    final decodedResponse2 = jsonDecode(response2.body);
    print(decodedResponse2);
    setState(() {
      videoSongs = List.from(decodedResponse);
      favouritevideoSongs = List.from(decodedResponse2);
    });
  }

  @override
  void initState() {
    super.initState();
    initSharedPref().then((value) => getSongs());
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void addFavourites(String songName) async {
    final url = Uri.parse(
        'http://10.0.2.2:5500/usersApi/markFavouriteVideos/' + songName);

    final mytoken = prefs.getString('token');

    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response = await http.put(url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({"username": username}));
    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse['message'] == true) {
      setState(() {
        if (favouritevideoSongs.contains(songName)) {
          favouritevideoSongs.remove(songName);
        } else {
          favouritevideoSongs.add(songName);
        }
      });
    } else {
      print("Some issue");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget list = ListView.builder(
      itemBuilder: (context, index) => VideoPageDesign(
        songName: videoSongs[index],
        isFavourite: favouritevideoSongs.contains(videoSongs[index]),
        addFavourites: addFavourites,
      ),
      itemCount: videoSongs.length,
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Title(
            color: const Color.fromARGB(255, 32, 104, 162),
            child: const Text("videos",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            TypeAheadField(
              builder: (context, controller, focusNode) {
                return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "search song..."));
              },
              suggestionsCallback: (pattern) {
                return videoSongs
                    .where((country) =>
                        country.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSelected: (suggestion) async {
                _controller.text = suggestion;
                FocusScope.of(context).unfocus();
                final response = await http.get(Uri.parse(
                    "http://10.0.2.2:5500/videoSongs/getSongUrl/" +
                        _controller.text));

                final mytoken = prefs.getString('token');
                final decodedToken = JwtDecoder.decode(mytoken!);
                final username = decodedToken['username'];

                await http.put(
                    Uri.parse(
                        "http://10.0.2.2:5500/usersApi/RecentlyPlayedVideos/" +
                            _controller.text),
                    headers: <String, String>{
                      'Content-Type': 'application/json'
                    },
                    body: jsonEncode({"username": username}));

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => VideoPlayerPage(
                          url: response.body,
                        )));
                        _controller.clear();
              },
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(44, 2, 137, 142),
                    Color.fromARGB(30, 2, 137, 142)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
                child: list,
              ),
            )
          ],
        ),
      ),
    );
  }
}
