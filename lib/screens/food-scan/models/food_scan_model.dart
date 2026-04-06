class DetectedFoodItem {
  final String name;
  final String estimatedQuantity;
  final double estimatedWeightGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double confidence;

  DetectedFoodItem({
    required this.name,
    required this.estimatedQuantity,
    required this.estimatedWeightGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.confidence,
  });

  factory DetectedFoodItem.fromJson(Map<String, dynamic> json) {
    return DetectedFoodItem(
      name: json["name"] ?? "",
      estimatedQuantity: json["estimatedQuantity"] ?? "",
      estimatedWeightGrams: (json["estimatedWeightGrams"] ?? 0).toDouble(),
      calories: (json["calories"] ?? 0).toDouble(),
      protein: (json["protein"] ?? 0).toDouble(),
      carbs: (json["carbs"] ?? 0).toDouble(),
      fats: (json["fats"] ?? 0).toDouble(),
      confidence: (json["confidence"] ?? 0).toDouble(),
    );
  }
}

class FoodScanModel {
  final String id;
  final String imageUrl;
  final List<DetectedFoodItem> detectedItems;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final String notes;
  final String status;
  final bool isConfirmed;
  final bool addedToFoodLog;
  final DateTime? createdAt;

  FoodScanModel({
    required this.id,
    required this.imageUrl,
    required this.detectedItems,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.notes,
    required this.status,
    required this.isConfirmed,
    required this.addedToFoodLog,
    this.createdAt,
  });

  factory FoodScanModel.fromJson(Map<String, dynamic> json) {
    return FoodScanModel(
      id: json["_id"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      detectedItems: (json["detectedItems"] as List<dynamic>? ?? [])
          .map((e) => DetectedFoodItem.fromJson(e))
          .toList(),
      totalCalories: (json["totalCalories"] ?? 0).toDouble(),
      totalProtein: (json["totalProtein"] ?? 0).toDouble(),
      totalCarbs: (json["totalCarbs"] ?? 0).toDouble(),
      totalFats: (json["totalFats"] ?? 0).toDouble(),
      notes: json["notes"] ?? "",
      status: json["status"] ?? "",
      isConfirmed: json["isConfirmed"] ?? false,
      addedToFoodLog: json["addedToFoodLog"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
    );
  }
}
