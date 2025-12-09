import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String senderId;

  @HiveField(2)
  String text;

  @HiveField(3)
  DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}
