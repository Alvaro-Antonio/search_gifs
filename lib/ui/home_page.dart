import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:search_gifs/ui/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? search;
  int offset = 0;

  int quantItens = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (search == null || search == '') {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=Xg6zZNn3EWGQXrV9xkRzXcOIGwmjg4Jo&limit=20&rating=g&bundle=messaging_non_clips'));
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=Xg6zZNn3EWGQXrV9xkRzXcOIGwmjg4Jo&q=$search&limit=19&offset=$offset&rating=g&lang=en&bundle=messaging_non_clips'));
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise aqui ...',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) => setState(() {
                search = text;
                offset = 0;
              }),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return createGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (search == null ||
              search == '' ||
              index < _getCount(snapshot.data['data']) - 1) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url'],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GifPage(gifData: snapshot.data['data'][index]),
                  )),
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              },
            );
          } else {
            return GestureDetector(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  offset += 19;
                });
              },
            );
          }
        });
  }

  int _getCount(List data) {
    if (search == null || search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
