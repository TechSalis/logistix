import 'package:equatable/equatable.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';

class CustomerData extends UserData with EquatableMixin {

  const CustomerData({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.phone,
  }) : super(role: UserRole.customer);
  
  @override
  List<Object?> get props => [id, name];
}
