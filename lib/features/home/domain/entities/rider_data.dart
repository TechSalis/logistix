import 'package:equatable/equatable.dart';
import 'package:logistix/features/home/domain/entities/company_data.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';

class RiderData extends UserData with EquatableMixin {
  final CompanyData? company;
  final double? rating;


  @override
  // ignore: overridden_fields
  final String name;

  const RiderData({
    required super.id,
    required this.name,
    required super.phone,
    required super.imageUrl,
    this.company,
    this.rating,
  }) : super(name: name);

  @override
  List<Object?> get props => [id, name, company];
}

