import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatus {
  static const requested = 'Requested';
  static const accepted = 'Accepted';
  static const onTheWay = 'OnTheWay';
  static const inProgress = 'InProgress';
  static const completed = 'Completed';
  static const cancelled = 'Cancelled';
}

class PaymentStatus {
  static const paid = 'Paid';
  static const unpaid = 'Unpaid';
  static const refunded = 'Refunded';
}

class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String? providerId;
  final String status;
  final DateTime? scheduledTime;
  final DateTime? createdAt;
  final GeoPoint? location;
  final String? address;
  final num price;
  final String paymentStatus;
  final String? notes;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    this.providerId,
    this.status = BookingStatus.requested,
    this.scheduledTime,
    this.createdAt,
    this.location,
    this.address,
    this.price = 0,
    this.paymentStatus = PaymentStatus.unpaid,
    this.notes,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      serviceId: data['serviceId'] as String,
      customerId: data['customerId'] as String,
      providerId: data['providerId'] as String?,
      status: data['status'] as String? ?? BookingStatus.requested,
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      location: data['location'] as GeoPoint?,
      address: data['address'] as String?,
      price: (data['price'] as num?) ?? 0,
      paymentStatus: data['paymentStatus'] as String? ?? PaymentStatus.unpaid,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'customerId': customerId,
      'providerId': providerId,
      'status': status,
      'scheduledTime':
          scheduledTime == null ? null : Timestamp.fromDate(scheduledTime!),
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'location': location,
      'address': address,
      'price': price,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }
}
