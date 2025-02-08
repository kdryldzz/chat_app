class Users {
  final String id;
  final String username;
  final String email;
  final String password;
  final String avatar_url;
  final DateTime created_at;


  Users({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.avatar_url,
    required this.created_at
  });

  factory Users.fromMap(Map<String,dynamic>map){
    return Users(
      id: map['id'], 
      username: map['username'], 
      email: map['email'], 
      password: map['password'], 
      avatar_url: map['avatar_url'],
      created_at: DateTime.parse(map['created_at']),
      );
  }

Map<String,dynamic> tomap(){
  return{
    'id' : id,
    'username': username,
    'email':email,
    'password': password,
    'avatar_url' : avatar_url,
    'created_at' : created_at.toIso8601String()
  };
}

}