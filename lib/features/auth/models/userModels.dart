// ignore_for_file: file_names

class Usermodels {
  final String id;
  final String userName;
  final String email;
  final String photo;

  Usermodels({
    required this.email,
    required this.id,
    required this.photo,
    required this.userName,
  });

  factory Usermodels.fromJson(Map<String, dynamic> json) {
    return Usermodels(
      email: json['email'] as String,
      id: json['uid'] as String,
      photo: json['photo'] as String,
      userName: json['userName'] as String,
    );
  }
}
