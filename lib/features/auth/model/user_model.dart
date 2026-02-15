class UserModel {
  final String email;
  final String userName;
  final String uid;

  UserModel({
    required this.email,
    required this.userName,
    required this.uid,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'], userName: json['userName'], uid: json['uid']);
  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userName': userName,
      'uid': uid,
    };
  }
}
