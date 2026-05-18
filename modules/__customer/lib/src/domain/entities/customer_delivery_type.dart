enum CustomerDeliveryType {
  foodDelivery,
  pharmacy,
  documents,
  groceries,
  generalErrands;

  String get title {
    switch (this) {
      case CustomerDeliveryType.foodDelivery:
        return 'Food Delivery';
      case CustomerDeliveryType.pharmacy:
        return 'Pharmacy';
      case CustomerDeliveryType.documents:
        return 'Documents';
      case CustomerDeliveryType.groceries:
        return 'Groceries';
      case CustomerDeliveryType.generalErrands:
        return 'General Errands';
    }
  }

  List<String> get googlePlaceTypes {
    switch (this) {
      case CustomerDeliveryType.foodDelivery:
        return ['restaurant', 'cafe', 'bakery', 'meal_takeaway'];
      case CustomerDeliveryType.pharmacy:
        return ['pharmacy', 'drugstore', 'hospital', 'doctor'];
      case CustomerDeliveryType.groceries:
        return ['supermarket', 'convenience_store', 'grocery_or_supermarket'];
      case CustomerDeliveryType.documents:
      case CustomerDeliveryType.generalErrands:
        return ['establishment']; // Broadest category
    }
  }

  String get locationLabel {
    switch (this) {
      case CustomerDeliveryType.foodDelivery:
        return 'Restaurant / Eatery Name';
      case CustomerDeliveryType.pharmacy:
        return 'Pharmacy / Hospital Name';
      case CustomerDeliveryType.groceries:
        return 'Supermarket / Store Name';
      case CustomerDeliveryType.documents:
      case CustomerDeliveryType.generalErrands:
        return 'Pickup Location';
    }
  }

  String get payloadLabel {
    switch (this) {
      case CustomerDeliveryType.foodDelivery:
        return 'Food Items / Combo details';
      case CustomerDeliveryType.pharmacy:
        return 'List of Drugs / Prescriptions';
      case CustomerDeliveryType.groceries:
        return 'Grocery Shopping List (Qty, Brand)';
      case CustomerDeliveryType.documents:
        return 'Document Type (e.g. Legal, Contract)';
      case CustomerDeliveryType.generalErrands:
        return 'What do you need us to pick up?';
    }
  }
}
