class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.timezone,
  });

  final int id;
  final String name;
  final String email;
  final String currency;
  final String timezone;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:       json['id'] as int,
        name:     json['name'] as String,
        email:    json['email'] as String,
        currency: json['currency'] as String? ?? 'MYR',
        timezone: json['timezone'] as String? ?? 'Asia/Kuala_Lumpur',
      );

  Map<String, dynamic> toJson() => {
        'id':       id,
        'name':     name,
        'email':    email,
        'currency': currency,
        'timezone': timezone,
      };

  UserModel copyWith({String? name, String? currency, String? timezone}) =>
      UserModel(
        id:       id,
        name:     name ?? this.name,
        email:    email,
        currency: currency ?? this.currency,
        timezone: timezone ?? this.timezone,
      );
}
