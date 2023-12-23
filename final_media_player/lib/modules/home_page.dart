import 'package:final_media_player/modules/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './audio_page.dart';
import './favorites.dart';
import './recently_played.dart';
import 'video_page.dart';


class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}
class _HomePageState extends State<HomePage> {
  final List<String> displayName = [
    "audio",
    "video",
    "favourites",
    "recently played"
  ];
  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _selectCatagery(BuildContext context, String choice) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      switch (choice) {
        case "audio":
          return const AudioPage();
        case "video":
          return const VideoPage();
        case "favourites":
          return const FavouritesPage();
        case "recently played":
          return const RecentlyPlayedPage();
        default:
          return HomePage();
      }
    }));
  }

  Future<void> pageChange() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

void initState(){
  initSharedPref();
  super.initState();
}
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'LOGOUT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Do you want to logout',
                style: TextStyle(fontSize: 14),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'No');
                  },
                  child: const Text('NO'),
                ),
                TextButton(
                  onPressed: () async{
                    Navigator.pop(context, 'yes');
                    await prefs.clear();
                    pageChange();
                    
                  },
                  child: const Text('YES'),
                ),

              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Media Player",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: (){_showLogoutConfirmationDialog(context);},
              icon: Icon(Icons.logout_sharp),
              color: Colors.white,
            )
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color.fromARGB(88, 2, 137, 142),
                  Color.fromARGB(51, 2, 137, 142)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
              child: GridView(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                children: [
                  for (String name in displayName)
                    CardDesign(displayName: name, onSelect: _selectCatagery),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CardDesign extends StatelessWidget {
  const CardDesign(
      {super.key, required this.displayName, required this.onSelect});
  final String displayName;
  final void Function(BuildContext context, String name) onSelect;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onSelect(context, displayName);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(44, 2, 137, 142),
                  Color.fromARGB(30, 2, 137, 142)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
          child: Text(displayName),
        ));
  }
}
