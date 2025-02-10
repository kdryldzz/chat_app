class Messages {
  final String message_id; 
  final String senderUser_id;
  final String receiverUser_id;
  final String room_id;
  final String content;
  final DateTime created_at;
  final bool seen; // Add seen field

  Messages({
    required this.message_id,
    required this.senderUser_id,
    required this.receiverUser_id,
    required this.room_id,
    required this.content,
    required this.created_at,
    required this.seen, // Add seen field
  });

  factory Messages.fromMap(Map<String, dynamic> map) {
    return Messages(
      message_id: map['message_id'],
      senderUser_id: map['senderUser_id'],
      receiverUser_id: map['receiverUser_id'],
      room_id: map['room_id'],
      content: map['content'],
      created_at: DateTime.parse(map['created_at']),
      seen: map['seen'], // Add seen field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': message_id,
      'senderUser_id': senderUser_id,
      'receiverUser_id': receiverUser_id,
      'room_id': room_id,
      'content': content,
      'created_at': created_at.toIso8601String(),
      'seen': seen, // Add seen field
    };
  }
}
