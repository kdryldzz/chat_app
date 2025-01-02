class Messages {
  final String id;
  final String senderId;
  final DateTime createdAt;
  final String roomId;
  final String content;

  Messages({
    required this.id,
    required this.senderId,
    required this.createdAt,
    required this.roomId,
    required this.content,
  });

  factory Messages.fromMap(Map<String, dynamic> map) {
    return Messages(
      id: map['id'],
      senderId: map['sender_id'],
      createdAt: DateTime.parse(map['created_at']),
      roomId: map['room_id'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
      'room_id': roomId,
      'content': content,
    };
  }
}
