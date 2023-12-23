import 'package:flutter/material.dart';

class PageDesign extends StatefulWidget {
  const PageDesign(
      {super.key,
      required this.data,
      required this.playSong,
      required this.isFavourite,
      required this.addFavourites});
  final String data;
  final void Function(String songName) playSong;
  final bool isFavourite;
  final void Function(String songName) addFavourites;
  @override
  _PageDesignState createState() => _PageDesignState();
}

class _PageDesignState extends State<PageDesign> {
  

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
      onTap: () {
        widget.playSong(widget.data);
      },
      borderRadius: BorderRadius.circular(8),
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
            Text(widget.data),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  widget.addFavourites(widget.data);
                });
              },
              icon: icons,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
