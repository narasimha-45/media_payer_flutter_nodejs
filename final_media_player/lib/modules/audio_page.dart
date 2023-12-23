import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../designs/page_design.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AudioPageState();
  }
}

class _AudioPageState extends State<AudioPage> {
  late List<String> favoriteAudio;
  late List<String> songList = [];
  late SharedPreferences prefs;
  String? currentAudioSong;
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  IconData icon = Icons.play_circle_fill_outlined;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  Future<void> getSongs() async {
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];

    final response = await http
        .get(Uri.parse("http://10.0.2.2:5500/audioSongs/getAllSongs"));
    final decodedResponse = jsonDecode(response.body);

    final response2 = await http.get(Uri.parse(
        "http://10.0.2.2:5500/usersApi/getFavouriteAudios/" + username));
    final decodedResponse2 = jsonDecode(response2.body);
    setState(() {
      songList = List.from(decodedResponse);
      favoriteAudio = List.from(decodedResponse2);
    });
  }

  void addFavourites(String songName) async {
    final url = Uri.parse(
        'http://10.0.2.2:5500/usersApi/markFavouriteAudios/' + songName);
    final mytoken = prefs.getString('token');
    final decodedToken = JwtDecoder.decode(mytoken!);
    final username = decodedToken['username'];
    final response = await http.put(url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({"username": username}));
    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse['message'] == true) {
      setState(() {
        if (favoriteAudio.contains(songName)) {
          favoriteAudio.remove(songName);
        } else {
          favoriteAudio.add(songName);
        }
      });
    } else {
      print("Some issue");
    }
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
    int idx = songList.indexOf(songName) + 1;
    if (idx == songList.length) {
      idx = 0;
    }
    String nextSongName = songList[idx];
    playSong(nextSongName);
  }

  void playPrevSong(String songName) {
    int idx = songList.indexOf(songName) - 1;
    if (idx == -1) {
      idx = songList.length;
    }
    String nextSongName = songList[idx];
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
    if (currentAudioSong != null) {
      bottomAppBar = BottomAppBar(
          height: MediaQuery.of(context).size.height / 5,
          color: const Color.fromARGB(156, 29, 162, 192),
          child: Column(children: [
            Row(
              children: [
                Text(
                  currentAudioSong!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 20),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.skip_previous_outlined),
                  onPressed: () {
                    playPrevSong(currentAudioSong!);
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
                      playNextSong(currentAudioSong!);
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
    if (currentAudioSong == songName) {
      await audioPlayer.seek(Duration.zero);
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
      if (currentAudioSong != null) {
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
        currentAudioSong = songName;
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
    final Widget list = ListView.builder(
        itemBuilder: (context, index) => PageDesign(
              data: songList[index],
              playSong: playSong,
              isFavourite: favoriteAudio.contains(songList[index]),
              addFavourites: addFavourites,
            ),
        itemCount: songList.length);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: (Scaffold(
          appBar: AppBar(
            title: Title(
                color: const Color.fromARGB(255, 32, 104, 162),
                child: const Text(
                  "Audio",
                  style: TextStyle(color: Colors.white),
                )),
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
                        hintText: "search song..."
                      ));
                },
                suggestionsCallback: (pattern) {
                  return songList
                      .where((country) =>
                          country.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (suggestion) {
                  _controller.text = suggestion;
                  FocusScope.of(context).unfocus();
                  _controller.clear();
                  playSong(_controller.text);
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
          bottomNavigationBar: bottomAppBar)),
    );
  }
}
