class PurchaseModel {
  final int purchaseId;
  final String message;
  final int? pointsEarned;
  final String? status;
  final double? totalAmount;

  PurchaseModel({
    required this.purchaseId,
    required this.message,
    this.pointsEarned,
    this.status,
    this.totalAmount,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseId: json['purchase_id'] ?? 0,
      message: json['message'] ?? '',
      pointsEarned: json['points_earned'],
      status: json['status'],
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : null,
    );
  }
}
