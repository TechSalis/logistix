import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodRecommendationItem {
  final String name;
  final String image;
  const FoodRecommendationItem({required this.name, required this.image});
}

final foodRecommendationsProvider = Provider((ref) {
  return const [
    FoodRecommendationItem(name: "Jollof Rice", image: "🍛"),
    FoodRecommendationItem(name: "Fried Rice", image: "🥘"),
    FoodRecommendationItem(name: "Burger", image: "🍔"),
    FoodRecommendationItem(name: "Chicken Wings", image: "🍗"),
    FoodRecommendationItem(name: "Pounded Yam & Egusi", image: "🍲"),
    FoodRecommendationItem(name: "Jollof Rice", image: "🍛"),
    FoodRecommendationItem(name: "Fried Rice", image: "🥘"),
    FoodRecommendationItem(name: "Burger", image: "🍔"),
    FoodRecommendationItem(name: "Chicken Wings", image: "🍗"),
    FoodRecommendationItem(name: "Pounded Yam & Egusi", image: "🍲"),
  ];
});

class FoodOrderNotifier extends AutoDisposeNotifier<String> {
  FoodOrderNotifier();

  @override
  String build() => '';

  void addItem(FoodRecommendationItem item) {
    final regex = RegExp(r'(\d+)x\s' + RegExp.escape(item.name));
    if (regex.hasMatch(state)) {
      state = state.replaceFirstMapped(regex, (match) {
        final count = int.tryParse(match.group(1) ?? '1') ?? 1;
        return '${count + 1}x ${item.name}';
      });
    } else {
      state = '${state.isEmpty ? '' : '$state, '}1x ${item.name}';
    }
  }

  void updateOrder(String value) => state = value;
}

final foodOrderProvider =
    NotifierProvider.autoDispose<FoodOrderNotifier, String>(
      FoodOrderNotifier.new,
    );
