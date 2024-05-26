import 'dart:html';

import 'package:sqflite/sqflite.dart';
//用来获取手机中软件储存地址
import 'package:path_provider/path_provider.dart';
//用来拼接连接数据库的地址
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _database;
//开关数据库
  Future<void> open() async {
    if (_database != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      //用于获取应用程序的文档目录的路径。这个目录通常用于存储用户生成的文件或其他需要持久化的文件数据，比如配置文件、日志文件等。
      final docsPath = await getApplicationDocumentsDirectory();
      //拼接对应的目录的数据库路径
      final dbPath = join(docsPath.path, dbName);
      //获取对应的数据库对象
      final database = await openDatabase(dbPath);
      _database = database;

      //创建userinfo表
      await database.execute(createUserTable);

      //创建note表
      await database.execute(createNoteTable);
    } on MissingPlatformDirectoryException catch (_) {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpen();
    }
    await database.close();
    _database = null;
  }

  //获取数据库对象或抛出数据库未打开异常
  Database _getDatabaseOrThrow() {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpen();
    }
    return database;
  }

//删除用户
  Future<int> deleteUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    int deletedCount = await database.delete(userTable,
        where: 'login_id = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
    return deletedCount;
  }

//创建用户
  Future<DatabaseUser> createUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    final results = await database.query(userTable,
        limit: 1, where: 'login_id = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    int userId = await database.insert(userTable, {userLoginId: email});

    return DatabaseUser(id: userId, loginId: email);
  }

  //查找用户
  Future<DatabaseUser> getUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    final results = await database.query(userTable,
        limit: 1, where: 'login_id = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    //返回结果是对应数据类型的map
    return DatabaseUser.fromRow(results.first);
  }

  //创建笔记
Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final database = _getDatabaseOrThrow();

    final user = await getUser(email: owner.loginId);
    if(user != owner){
      throw CouldNotFindUser();
    }
    const text = '';
    final  noteId = await database.insert(noteTable, {noteUserId:owner.id,noteText:text,noteIsSyncedWithCloud:1});
    return DatabaseNote(id:noteId,userId: owner.id, text:text,isSyncedWithCloud: true);
}

//删除笔记
Future<void> deleteNote({required int id}) async {
  final database = _getDatabaseOrThrow();
  final deletedCount = await database.delete(noteTable,where: 'id = ?',whereArgs: [id]);
  if(deletedCount == 0){
    throw CouldNotDeleteNote();
  }
}

//删除所有笔记
Future<int> deleteAllNotes() async{
    final database = _getDatabaseOrThrow();
    return await database.delete(noteTable);
}
//查询笔记
Future<DatabaseNote> getNote({required int id}) async{
  final database = _getDatabaseOrThrow();
  final notes = await database.query(noteTable,limit: 1,where: 'id = ?',whereArgs: [id]);

  if(notes.isEmpty){
    throw CouldNotFindNote();
  }
  return DatabaseNote.fromRow(notes.first);
}
//查询所有笔记
Future<Iterable<DatabaseNote>> getAllNotes() async{
  final database = _getDatabaseOrThrow();
  final notes = await database.query(noteTable);

  return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
}
//更新笔记
Future<DatabaseNote> updateNote({required DatabaseNote note,required String text}) async {
  final database = _getDatabaseOrThrow();
  final updateCount = await database.update(noteTable, {noteText:text,noteIsSyncedWithCloud:0});
  if(updateCount == 0){
    throw CouldNotUpdateNote();
  }
  return getNote(id: note.id);
}
}

class DatabaseUser {
  final int id;
  final String loginId;

  DatabaseUser({required this.id, required this.loginId});

  //:后的内容表示赋初始值。as用于将一个对象强制转换为另一种类型。
  //map[key]取mao中key对应的value，key可以是id与login_id
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[userId] as int,
        loginId = map[userLoginId] as String;

  @override
  String toString() => 'Person,id = $id,loginId = $loginId';

  //判断两个对象是否相同，等同于java的equals
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  //提供哈希值
  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[noteId] as int,
        userId = map[noteUserId] as int,
        text = map[noteText] as String,
        isSyncedWithCloud =
            (map[noteIsSyncedWithCloud] as int) == 0 ? false : true;

  @override
  String toString() =>
      'Note,id = $id,userId = $userId,isSyncedWithCloud = $isSyncedWithCloud,text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const String userId = 'id';
const String userLoginId = 'login_id';
const String noteId = 'id';
const String noteUserId = 'user_id';
const String noteText = 'text';
const String noteIsSyncedWithCloud = 'is_synced_with_cloud';
const String dbName = 'notes.db';
const userTable = 'user_info';
const noteTable = 'note';
const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user_info" (
	"id"	INTEGER NOT NULL,
	"login_id"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';

const createNoteTable = '''
CREATE TABLE "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	INTEGER,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user_info"("id")
);''';
