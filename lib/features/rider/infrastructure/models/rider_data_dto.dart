import 'package:logistix/features/home/domain/entities/rider_data.dart';

class RiderDataModel extends RiderData {
  RiderDataModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.imageUrl,
    super.company,
    super.rating,
  });

  factory RiderDataModel.fromJson(Map<String, dynamic> json) {
    return RiderDataModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      imageUrl: json['image_url'],
      company: json['company'],
      rating: json['rating'],
    );
  }
}
