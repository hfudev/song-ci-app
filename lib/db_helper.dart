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

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SongCi {
  final int id;
  final String rhythmic;
  final String author;
  final String content;

  const SongCi({
    required this.id,
    required this.rhythmic,
    required this.author,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rhythmic': rhythmic,
      'author': author,
      'content': content,
    };
  }

  String title() {
    return rhythmic + ' ' + author;
  }
}

class DatabaseHelper {
  static Future<sql.Database> db() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "asset_database.db");

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(join('assets', 'song_ci.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes);
    }

    return sql.openDatabase(
      path,
      version: 1,
    );
  }

  static Future<List<SongCi>> allItems() async {
    final db = await DatabaseHelper.db();

    final List<Map<String, dynamic>> maps = await db.query('ci', orderBy: 'id');

    return List.generate(maps.length, (index) {
      return SongCi(
        id: maps[index]['id'],
        rhythmic: maps[index]['rhythmic'],
        author: maps[index]['author'],
        content: maps[index]['content'],
      );
    });
  }
}
