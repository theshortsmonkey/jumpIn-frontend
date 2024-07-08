class User {
  final String? id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final bool identityVerificationStatus;
  final bool driverVerificationStatus;
  final dynamic car;
  final String? password;
  final dynamic reports;

  const User(
      {this.id,
      this.username = "",
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      this.bio,
      this.identityVerificationStatus = false,
      this.driverVerificationStatus = false,
      this.car,
      this.password,
      this.reports = const []});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as String,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        bio: json['bio'] as String,
        identityVerificationStatus:
            json['identity_verification_status'] as bool,
        driverVerificationStatus: json['identity_verification_status'] as bool,
        car: json['car'] as dynamic,
        reports: json["reports"] as dynamic);
  }
  static List<User> fromJsonList(List<Map<String, dynamic>> jsonList) {
    return jsonList.map<User>((json) => User.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "firstName": firstName,
        "lastName": lastName,
        'email': email,
        "phoneNumber": phoneNumber,
        "bio": bio,
        "password": password,
        "identity_verification_status": identityVerificationStatus,
        "driver_verification_status": driverVerificationStatus,
        "car": car,
      };
}
