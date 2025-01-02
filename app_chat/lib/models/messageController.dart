import 'package:app_chat/models/DatabaseHelper.dart';
import 'package:app_chat/models/messages.dart';

class Messagecontroller {
  Future<List<Messages>> allMessages() async {
    var db = await Databasehelper.databaseAccess();

    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM messages");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return Messages(
          id: satir["id"],
          senderId: satir["senderId"],
          createdAt: satir["createdAt"],
          roomId: satir["roomId"],
          content: satir["content"]);
    });
  }
}
