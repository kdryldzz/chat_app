class LocalMessage {
  final String messageId;
  final String senderUserId;
  final String receiverUserId;
  final String roomId;
  final String content;
  final DateTime createdAt;
  final String image_url;

  LocalMessage({
    required this.messageId,
    required this.senderUserId,
    required this.receiverUserId,
    required this.roomId,
    required this.content,
    required this.createdAt,
    required this.image_url,
  });

  factory LocalMessage.fromMap(Map<String, dynamic> map) {
    return LocalMessage(
      messageId: map['message_id'],
      senderUserId: map['sender_user_id'],
      receiverUserId: map['receiver_user_id'],
      roomId: map['room_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      image_url: map['image_url']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'sender_user_id': senderUserId,
      'receiver_user_id': receiverUserId,
      'room_id': roomId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'image_url' : image_url
    };
  }
}
