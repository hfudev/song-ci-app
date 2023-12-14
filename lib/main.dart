/*
 * Copyright (c) 2022 Fu Hanxi <hfudev@gmail.com>
 *
 * This file is part of song-ci-app.
 *
 * song-ci-app is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * song-ci-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宋词',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        fontFamily: 'LXGWWenKaiLite',
      ),
      home: const HomePage(title: '宋词列表'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SongCi> _items = [];
  List<SongCi> _favorites = [];
  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshItems() async {
    final data = await DatabaseHelper.allItems();
    final favorites = await DatabaseHelper.favoriteItems();

    setState(() {
      _items = data;
      _favorites = favorites;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Loading the diary when the app starts
  }

  Card _toCard(SongCi ci) {
    final title = ci.title();
    final content = ci.content;
    final isFavorite = ci.isFavorite == 1;

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(content),
        trailing: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
          semanticLabel:
              isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
        onTap: () {
          setState(() {
            if (isFavorite) {
              _favorites.remove(ci);
              ci.isFavorite = 0;
            } else {
              _favorites.add(ci);
              ci.isFavorite = 1;
            }
            DatabaseHelper.updateSongCi(ci);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _pushSaved,
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _toCard(_items[index]);
              }),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      final items = _favorites.map((item) {
        return _toCard(item);
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: ListView(children: items.toList()),
      );
    }));
  }
}
