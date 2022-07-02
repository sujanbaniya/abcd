class UserModel {
  String? userId;
  String? fullName;
  String? mobileNumber;
  String? email;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? password;
  String? userType;

  UserModel({
    this.userId,
    this.fullName,
    this.mobileNumber,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.password,
    this.userType,
  });

  factory UserModel.fromFormMap(Map<String, dynamic> data) {
    return UserModel(
      fullName: data['fullName'],
      mobileNumber: data['mobileNumber'],
      email: data['email'],
      password: data['password'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['_id'],
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      userType: json['userType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      'password': password,
      'userType': userType,
    };
  }
}
