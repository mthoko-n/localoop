class RegisterRequest {
  final String email;
  final String password;
  final String displayName;
  final String lastName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'display_name': displayName,
        'last_name': lastName,
      };
}
