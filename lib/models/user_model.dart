class UserModel {
  final String uid;
  final String email;
  final String? displayName;

  UserModel({required this.uid, required this.email, this.displayName});

  factory UserModel.fromFirebase(String uid, String email, String? name) {
    return UserModel(uid: uid, email: email, displayName: name);
  }
}
