
import 'dart:io';

import 'package:learning_riverpod/models/photo_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper{
  static Database? db;

  Future<Database> getDB()async{
    if(db!=null){
      return db!;
    }
    else{
      db = await initDB();
      return db!;
    }
  }

  Future<Database> initDB()async{
    Directory dbPath = await getApplicationDocumentsDirectory();
    String path = join(dbPath.path,'WallDB.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: createTable
    );
  }

  Future<void> createTable(Database db, int version) async {
    await db.execute(
        '''
    CREATE TABLE photo(
      id INTEGER PRIMARY KEY,
      height INTEGER,
      width INTEGER,
      url TEXT,
      photographer TEXT,
      photographerUrl TEXT,
      avgColor TEXT,
      srcOriginal TEXT,
      srcPortrait TEXT,
      srcMedium TEXT,
      srcLarge2x TEXT
    )
    '''
    );
  }
  
  Future<void> insertPhoto(PhotoModel photo)async{
    final db = await getDB();
    await db.insert('photo', photo.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<PhotoModel>> getAllPhotos()async{
    final db = await getDB();
    List<Map<String,dynamic>> value = await db.query('photo',orderBy: 'id DESC');
    return value.map((i)=>PhotoModel.fromMap(i)).toList();
  }

  Future<void> removeFromFavorite(int id)async{
   final db = await getDB();
   await db.delete('photo',where: 'id=?',whereArgs: [id]);
  }

  Future<bool> hasPhoto(int id)async{
    final db = await getDB();
    List<Map<String,dynamic>> value = await db.query('photo',where: 'id=?',whereArgs: [id]);
    return value.isNotEmpty;
  }

}