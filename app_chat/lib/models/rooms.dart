class Rooms {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;

  Rooms({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
  });

  factory Rooms.fromMap(Map<String, dynamic> map) {
    return Rooms(
      id: map['id'],
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
