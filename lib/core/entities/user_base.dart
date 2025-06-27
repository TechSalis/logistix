abstract class UserBase {
  final String id;
  final String name;
  final String? imageSource;

  const UserBase({required this.id, required this.name, this.imageSource});
}
