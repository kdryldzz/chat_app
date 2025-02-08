class Rooms {
final String room_id;
final String user1_id;
final String user2_id;
final DateTime created_at;

Rooms({
  required this.room_id, 
  required this.user1_id, 
  required this.user2_id,
  required this.created_at
});

factory Rooms.fromMap(Map<String,dynamic>map){
  return Rooms(
   room_id: map['room_id'],
   user1_id: map['user1_id'],
   user2_id: map['user2_id'], 
   created_at: DateTime.parse(map['created_at']));
}



Map<String,dynamic> toMap(){
return{
'room_id': room_id,
'user1_id':  user1_id,
'user2_id': user2_id,
'created_at': created_at.toIso8601String(),
}; 
}

}