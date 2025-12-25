import 'book_model.dart';

class PurchaseModel {
  final int? purchaseId;
  final String message;
  final int? pointsEarned;
  final String? status;
  final double? totalAmount;
  final DateTime? purchasedAt;
  final BookModel? book;

  PurchaseModel({
    this.purchaseId,
    required this.message,
    this.pointsEarned,
    this.status,
    this.totalAmount,
    this.purchasedAt, // <-- أضف هنا
    this.book,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseId: json['purchase_id'],
      message: json['message'] ?? '',
      pointsEarned: json['points_earned'],
      status: json['status'],
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : null,
      purchasedAt: json['purchased_at'] != null
          ? DateTime.parse(json['purchased_at'])
          : null, // <-- حول السلسلة إلى DateTime
      book: json['book'] != null ? BookModel.fromJson(json['book']) : null,
    );
  }
}
