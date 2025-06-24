import 'package:equatable/equatable.dart';

class Rider extends Equatable {
  final String id;
  final String name;
  final String? company;
  final double rating;

  const Rider({
    required this.id,
    required this.name,
    required this.company,
    required this.rating,
  });
  
  @override
  List<Object?> get props => [id, name, company, rating];
}
