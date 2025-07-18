class UserData {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  const UserData({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imagee_url': imageUrl,
    };
  }
}
