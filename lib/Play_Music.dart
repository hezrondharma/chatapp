import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PlayMusic extends StatefulWidget {
  final String username;

  const PlayMusic({Key? key, required this.username}) : super(key: key);

  @override
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  List<bool> isPlayingList = List.generate(7, (index) => false);
  List<double> musicRatings = List.generate(7, (index) => 3.0);

  List<String> musicNames = [
    'Song A',
    'Song B',
    'Song C',
    'Song D',
    'Song E',
    'Song F',
    'Song G',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Music'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome, ${widget.username}'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 7; i++)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isPlayingList[i] = !isPlayingList[i];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingList[i] ? Colors.red : Colors.green,
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 0),
                          ),
                          child: Text(isPlayingList[i] ? 'Stop' : 'Play'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          musicNames[i],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        RatingBar.builder(
                          initialRating: musicRatings[i],
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              musicRatings[i] = rating;
                            });
                          },
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
