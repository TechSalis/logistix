import 'package:equatable/equatable.dart';
import 'package:logistix/core/entities/user_base.dart';

class Rider extends UserBase with EquatableMixin {
  final String? company;
  final double rating;

  const Rider({
    required super.id,
    required super.name,
    required this.company,
    required this.rating,
  });
  
  @override
  List<Object?> get props => [id, name, company, rating];
}
