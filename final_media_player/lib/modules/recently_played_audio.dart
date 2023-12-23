import 'dart:convert';
import 'dart:typed_data';
import 'package:final_media_player/designs/favorites_design.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class RecentlyPlayedAudioPage extends StatefulWidget {
  const RecentlyPlayedAudioPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _RecentlyPlayedAudioPageState();
  }
}

class _RecentlyPlayedAudioPageState extends State<RecentlyPlayedAudioPage> {
  late List<String> favoriteAudio = [];
  late SharedPreferences prefs;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  IconData icon = Icons.play_circle_fill_outlined;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  String? currentFavouriteAudioSong;

  Future<void> getSongs() async {
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response = await http.get(Uri.parse(
        "http://10.0.2.2:5500/usersApi/getRecentlyPlayedAudios/" + username));
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
        favoriteAudio.add(i["song"]);
      }
    });
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initSharedPref().then((value) => {
          print("prefs"),
          print(prefs.getString('token')),
          getSongs(),
          audioPlayer.onPlayerStateChanged.listen((state) {
            if (state == PlayerState.completed) {
              setState(() {
                isPlaying = false;
                icon = Icons.play_circle_fill_outlined;
              });
            }
          }),
          audioPlayer.onDurationChanged.listen((d) {
            setState(() {
              _duration = d;
            });
          }),
          audioPlayer.onPositionChanged.listen((p) {
            setState(() {
              _position = p;
            });
          })
        });
  }

  void playNextSong(String songName) {
    int idx = favoriteAudio.indexOf(songName) + 1;
    if (idx == favoriteAudio.length) {
      idx = 0;
    }
    String nextSongName = favoriteAudio[idx];
    playSong(nextSongName);
  }

  void playPrevSong(String songName) {
    int idx = favoriteAudio.indexOf(songName) - 1;
    if (idx == -1) {
      idx = favoriteAudio.length;
    }
    String nextSongName = favoriteAudio[idx];
    playSong(nextSongName);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  BottomAppBar? bottomAppBar;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (currentFavouriteAudioSong != null) {
      bottomAppBar = BottomAppBar(
          height: MediaQuery.of(context).size.height / 5,
          color: const Color.fromARGB(156, 29, 162, 192),
          child: Column(children: [
            Row(
              children: [
                Text(
                  currentFavouriteAudioSong!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 20),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.skip_previous_outlined),
                  onPressed: () {
                    playPrevSong(currentFavouriteAudioSong!);
                  },
                  iconSize: 35,
                ),
                IconButton(
                    icon: Icon(icon),
                    onPressed: () {
                      if (isPlaying) {
                        audioPlayer.pause();
                        setState(() {
                          icon = Icons.play_circle_fill_outlined;
                          isPlaying = !isPlaying;
                        });
                      } else {
                        audioPlayer.resume();
                        setState(() {
                          icon = Icons.pause_circle_filled_outlined;
                          isPlaying = !isPlaying;
                        });
                      }
                    },
                    iconSize: 35),
                IconButton(
                    icon: const Icon(Icons.skip_next_outlined),
                    onPressed: () {
                      playNextSong(currentFavouriteAudioSong!);
                    },
                    iconSize: 35),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _position.toString().split(".")[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        _duration.toString().split(".")[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  slider(),
                ],
              ),
            ),
          ]));
    }
  }

  void playSong(String songName) async {
    if (currentFavouriteAudioSong == songName) {
      audioPlayer.seek(Duration.zero);
      final mytoken = prefs.getString('token');
      final decodedToken = JwtDecoder.decode(mytoken!);
      final username = decodedToken['username'];
      await http.put(
          Uri.parse(
              "http://10.0.2.2:5500/usersApi/RecentlyPlayedAudios/" + songName),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({"username": username}));
      setState(() {
        _position = Duration.zero;
      });
    } else {
      if (currentFavouriteAudioSong != null) {
        await audioPlayer.stop();
      }
      final response = await http.get(
          Uri.parse("http://10.0.2.2:5500/audioSongs/getSongUrl/" + songName));
      List<int> audioData = response.bodyBytes;
      await audioPlayer.play(BytesSource(Uint8List.fromList(audioData)));
      final mytoken = prefs.getString('token');
      final decodedToken = JwtDecoder.decode(mytoken!);
      final username = decodedToken['username'];
      await http.put(
          Uri.parse(
              "http://10.0.2.2:5500/usersApi/RecentlyPlayedAudios/" + songName),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({"username": username}));
      setState(() {
        isPlaying = true;
        icon = Icons.pause_circle_filled_outlined;
        currentFavouriteAudioSong = songName;
      });
    }
  }

  Widget slider() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Slider(
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.grey,
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            changeToSecond(value.toInt());
            value = value;
          });
        },
      ),
    );
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    final Widget list;
    if (favoriteAudio.length == 0) {
      list = Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(child: Text("Nothing played yet")));
    } else {
      list = ListView.builder(
          itemBuilder: (context, index) => FavouritesDesign(
                data: favoriteAudio[index],
                playSong: playSong,
              ),
          itemCount: favoriteAudio.length);
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: (Scaffold(
          body: Column(
            children: [
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
          bottomNavigationBar: bottomAppBar)),
    );
  }
}
