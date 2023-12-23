class SongDetails {
  String url;
  bool isFavourite;
  SongDetails({required this.url, required this.isFavourite});
}

Map<String, SongDetails> audioFiles = {
  "Song1": SongDetails(
      url:
"https://scummbar.com/mi2/MI1-CD2/Addressing%20%20the%20crew%20(Amiga).mp3",      isFavourite: false),
  "Song2": SongDetails(
      url:"https://scummbar.com/mi2/MI2-CD1/05%20-%20Largo%20LaGrande.mp3",
      isFavourite: false),
  "song3": SongDetails(
      url:
"https://scummbar.com/mi2/MI2-CD2/05%20-%20The%20Booty%20Boutique.mp3",isFavourite: false),
  "Song4": SongDetails(
      url:
"https://scummbar.com/mi2/MI2-CD5/MI2_06-ScabbIsland.mp3",      isFavourite: false),
  "Song5": SongDetails(
      url:
"https://scummbar.com/mi2/MI2-CD3/Meeting%20Largo%20(Amiga).mp3",      isFavourite: false),
  "Song6": SongDetails(
      url:
"https://scummbar.com/mi2/MI3-CD1/13%20-%20Jazzy%20Voodoo%20in%20the%20Swamp.mp3",      isFavourite: false),
  "Song7": SongDetails(
      url:
"https://scummbar.com/mi2/MI3-CD2/15%20-%20Recovering%20the%20Map.mp3",      isFavourite: false),
};

Map<String,SongDetails> videoFiles ={
  "vsong1":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
  "vsong2":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
  "vsong3":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
  "vsong4":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"),
  "vsong5":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"),
  "vsong6":SongDetails(isFavourite: false,url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")
};



