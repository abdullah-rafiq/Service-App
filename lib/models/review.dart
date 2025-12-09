import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating; // 1-5
  final String? comment;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      bookingId: data['bookingId'] as String,
      customerId: data['customerId'] as String,
      providerId: data['providerId'] as String,
      rating: data['rating'] as int? ?? 0,
      comment: data['comment'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
