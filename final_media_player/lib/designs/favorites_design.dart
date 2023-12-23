import 'package:flutter/material.dart';

class FavouritesDesign extends StatefulWidget {
  const FavouritesDesign({super.key,required this.data,required this.playSong});
    final String data;
  final void Function(String songName) playSong;
  @override
  State<StatefulWidget> createState() {
    return _FavouriteDesignState();
  }
}

class _FavouriteDesignState extends State<FavouritesDesign> {
  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
