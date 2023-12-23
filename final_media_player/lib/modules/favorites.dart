import 'package:final_media_player/designs/favourite_video_design.dart';
import 'package:final_media_player/modules/favourite_audio_page.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FavouritesPageState();
  }
}

class _FavouritesPageState extends State<FavouritesPage> {
  late List<String> favoriteVideo = [];
  late SharedPreferences prefs;
  
  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getSongs() async {
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response2 = await http.get(Uri.parse(
        "http://10.0.2.2:5500/usersApi/getFavouriteVideos/" + username));
    final decodedResponse = jsonDecode(response2.body);
    setState(() {
      favoriteVideo = List.from(decodedResponse);
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
    final Widget Audiolist = FavouriteAudioPage();
    final Widget VideoList;
    if (favoriteVideo.length == 0) {
      VideoList = Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(child: Text("No Favourites added")));
    } else {
      VideoList = ListView.builder(
          itemBuilder: (context, index) => FavouriteVideoPageDesign(
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
                "Favorites",
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
                                  child: Audiolist,
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
                                child: VideoList,
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
