import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  const GifPage({super.key, required this.gifData});

  final Map gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gifData['title']),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                gifData['images']['fixed_height']['url'],
              );
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Image.network(
        gifData['images']['fixed_height']['url'],
      )),
    );
  }
}
