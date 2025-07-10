import 'package:equatable/equatable.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';

class CustomerData extends UserData with EquatableMixin {

  const CustomerData({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.phone,
  });
  
  @override
  List<Object?> get props => [id, name];
}
