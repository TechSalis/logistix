enum CustomerOrderType {
  foodDelivery,
  pharmacy,
  documents,
  groceries,
  generalErrands;

  String get title {
    switch (this) {
      case CustomerOrderType.foodDelivery:
        return 'Food Delivery';
      case CustomerOrderType.pharmacy:
        return 'Pharmacy';
      case CustomerOrderType.documents:
        return 'Documents';
      case CustomerOrderType.groceries:
        return 'Groceries';
      case CustomerOrderType.generalErrands:
        return 'General Errands';
    }
  }

  List<String> get googlePlaceTypes {
    switch (this) {
      case CustomerOrderType.foodDelivery:
        return ['restaurant', 'cafe', 'bakery', 'meal_takeaway'];
      case CustomerOrderType.pharmacy:
        return ['pharmacy', 'drugstore', 'hospital', 'doctor'];
      case CustomerOrderType.groceries:
        return ['supermarket', 'convenience_store', 'grocery_or_supermarket'];
      case CustomerOrderType.documents:
      case CustomerOrderType.generalErrands:
        return ['establishment']; // Broadest category
    }
  }

  String get locationLabel {
    switch (this) {
      case CustomerOrderType.foodDelivery:
        return 'Restaurant / Eatery Name';
      case CustomerOrderType.pharmacy:
        return 'Pharmacy / Hospital Name';
      case CustomerOrderType.groceries:
        return 'Supermarket / Store Name';
      case CustomerOrderType.documents:
      case CustomerOrderType.generalErrands:
        return 'Pickup Location';
    }
  }

  String get payloadLabel {
    switch (this) {
      case CustomerOrderType.foodDelivery:
        return 'Food Items / Combo details';
      case CustomerOrderType.pharmacy:
        return 'List of Drugs / Prescriptions';
      case CustomerOrderType.groceries:
        return 'Grocery Shopping List (Qty, Brand)';
      case CustomerOrderType.documents:
        return 'Document Type (e.g. Legal, Contract)';
      case CustomerOrderType.generalErrands:
        return 'What do you need us to pick up?';
    }
  }
}
