import 'package:final_media_player/modules/recently_played_audio.dart';
import 'package:final_media_player/modules/recently_played_video.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecentlyPlayedPage extends StatefulWidget {
  const RecentlyPlayedPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _RecentlyPlayedPageState();
  }
}

class _RecentlyPlayedPageState extends State<RecentlyPlayedPage> {
  late List<String> favoriteVideo = [];
  late SharedPreferences prefs;
  
  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getSongs() async {
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response = await http.get(Uri.parse(
        "http://10.0.2.2:5500/usersApi/getRecentlyPlayedVideos/" + username));
    final songs = jsonDecode(response.body);
    
    DateTime parseTime(String timeString) {
    List<String> parts = timeString.split('/');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    List<String> timeParts = parts[2].split(' ')[1].split(':');
    int day = int.parse(parts[2].split(' ')[0]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    return DateTime(year, month, day, hour, minute, second);
  }

  songs.sort((a, b) => parseTime(b['time']).compareTo(parseTime(a['time'])));
  print(songs);
    setState(() {
      for(var i in songs){
        favoriteVideo.add(i["song"]);
      }
    });
  }
  @override
  void initState() {
    super.initState();
    initSharedPref().then((value) => {
          getSongs(),
        });
  }
  @override
  Widget build(BuildContext context) {
    final Widget VideoList;
    if (favoriteVideo.length == 0) {
      VideoList = Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(child: Text("Nothing Played yet")));
    } else {
      VideoList = ListView.builder(
          itemBuilder: (context, index) => RecentlyPlayedVideoPageDesign(
                songName: favoriteVideo[index],
              ),
              itemCount: favoriteVideo.length,
              );
          
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 11, 147, 215),
          title: Title(
              color: const Color.fromARGB(255, 32, 104, 162),
              child: const Text(
                "Recently Played",
                style: TextStyle(color: Colors.white),
              )),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(89, 2, 142, 119),
                Color.fromARGB(84, 2, 142, 119)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.audiotrack,
                        color: Colors.white,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.videocam, color: Colors.white),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Audios page
                      Scaffold(
                        body: Center(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(103, 3, 139, 144),
                                        Color.fromARGB(85, 2, 137, 142)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: RecentlyPlayedAudioPage()
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Videos page
                      Center(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(28, 24, 173, 179),
                                      Color.fromARGB(25, 2, 137, 142)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: VideoList
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
