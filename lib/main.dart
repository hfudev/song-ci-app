import 'package:flutter/material.dart';

import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const HomePage({Key? key, required this.title}) : super(key: key);

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
  bool _isLoading = true;

  final _favorites = <SongCi>{};

  // This function is used to fetch all data from the database
  void _refreshItems() async {
    final data = await DatabaseHelper.allItems();

    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Loading the diary when the app starts
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final _item = _items[index];
                final _title = _item.title();
                final _content = _item.content;

                final _isFavorite = _favorites.contains(_item);

                return Card(
                  child: ListTile(
                    title: Text(_title),
                    subtitle: Text(_content),
                    trailing: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                      semanticLabel: _isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                    ),
                    onTap: () {
                      setState(() {
                        if (_isFavorite) {
                          _favorites.remove(_item);
                        } else {
                          _favorites.add(_item);
                        }
                      });
                    },
                  ),
                );
              }),
    );
  }
}
