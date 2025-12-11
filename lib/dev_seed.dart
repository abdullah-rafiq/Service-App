import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDemoData() async {
  final db = FirebaseFirestore.instance;

  WriteBatch batch = db.batch();

  // USERS
  final userCustomer1 = db.collection('users').doc('user_customer_1');
  batch.set(userCustomer1, {
    'name': 'Ali Customer',
    'phone': '+92...',
    'email': 'ali.customer@example.com',
    'role': 'customer',
    'status': 'Active',
    'profileImageUrl': null,
    'verified': false,
    'walletBalance': 1500,
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 1, 10)),
    'lastSeen': Timestamp.fromDate(DateTime(2024, 11, 25, 14)),
  });

  // Approved provider (visible in workers list, not pending)
  final userProvider1 = db.collection('users').doc('user_provider_1');
  batch.set(userProvider1, {
    'name': 'Sara Provider',
    'phone': '+92...',
    'email': 'sara.provider@example.com',
    'role': 'provider',
    'status': 'Active',
    'profileImageUrl': null,
    'verified': true,
    'walletBalance': 0,
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 2, 10)),
    'lastSeen': Timestamp.fromDate(DateTime(2024, 11, 25, 13, 30)),
    'verificationStatus': 'approved',
    'verificationReason': null,
  });

  // Pending provider (for AdminPendingWorkersPage)
  final userProviderPending =
      db.collection('users').doc('user_provider_pending_1');
  batch.set(userProviderPending, {
    'name': 'Pending Provider',
    'phone': '+92...123',
    'email': 'pending.provider@example.com',
    'role': 'provider',
    'status': 'Active',
    'profileImageUrl': null,
    'verified': false,
    'walletBalance': 0,
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 3, 9)),
    'lastSeen': Timestamp.fromDate(DateTime(2024, 11, 25, 12)),
    'verificationStatus': 'pending',
    'verificationReason': null,
  });

  // Admin user (for admin pages)
  final userAdmin1 = db.collection('users').doc('user_admin_1');
  batch.set(userAdmin1, {
    'name': 'Admin User',
    'phone': '+92...999',
    'email': 'admin@example.com',
    'role': 'admin',
    'status': 'Active',
    'profileImageUrl': null,
    'verified': true,
    'walletBalance': 0,
    'createdAt': Timestamp.fromDate(DateTime(2024, 10, 20, 10)),
    'lastSeen': Timestamp.fromDate(DateTime(2024, 11, 25, 15)),
  });

  final serviceDeepCleaning =
      db.collection('services').doc('deep_cleaning_3bhk');
  batch.set(serviceDeepCleaning, {
    'name': 'Deep Cleaning (3 BHK)',
    'categoryId': 'home_cleaning',
    'description': 'Full house deep cleaning',
    'basePrice': 3500,
    'durationEstimate': 180,
    'images': <String>[],
    'isActive': true,
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 10, 9)),
  });

  final booking1 = db.collection('bookings').doc('booking_1');
  batch.set(booking1, {
    'serviceId': 'deep_cleaning_3bhk',
    'customerId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'status': 'Requested',
    'scheduledTime': Timestamp.fromDate(DateTime(2024, 11, 30, 10)),
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 25, 10, 30)),
    'location': const GeoPoint(24.8607, 67.0011),
    'address': 'Some address in Karachi',
    'price': 3500,
    'paymentStatus': 'Pending',
    'paymentMethod': 'card',
    'paymentProviderId': null,
    'paymentAmount': null,
    'notes': 'Please bring own supplies',
    'cancelledBy': null,
    'isNoShow': null,
    'hasDispute': null,
  });

  final booking2 = db.collection('bookings').doc('booking_2');
  batch.set(booking2, {
    'serviceId': 'deep_cleaning_3bhk',
    'customerId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'status': 'Completed',
    'scheduledTime': Timestamp.fromDate(DateTime(2024, 11, 20, 14)),
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 19, 16, 30)),
    'location': const GeoPoint(24.8607, 67.0011),
    'address': 'Old booking, already done',
    'price': 3500,
    'paymentStatus': 'Paid',
    'paymentMethod': 'card',
    'paymentProviderId': 'demo_gateway_456',
    'paymentAmount': 3500,
    'notes': 'Completed successfully',
    'cancelledBy': null,
    'isNoShow': false,
    'hasDispute': false,
  });

  final booking3 = db.collection('bookings').doc('booking_3');
  batch.set(booking3, {
    'serviceId': 'deep_cleaning_3bhk',
    'customerId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'status': 'Cancelled',
    'scheduledTime': Timestamp.fromDate(DateTime(2024, 11, 28, 9)),
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 27, 10)),
    'location': const GeoPoint(24.8607, 67.0011),
    'address': 'Cancelled by customer',
    'price': 3500,
    'paymentStatus': 'Failed',
    'paymentMethod': 'card',
    'paymentProviderId': 'demo_gateway_789',
    'paymentAmount': 0,
    'notes': 'Customer cancelled before start',
    'cancelledBy': 'customer',
    'isNoShow': null,
    'hasDispute': false,
  });

  final payment1 = db.collection('payments').doc('payment_1');
  batch.set(payment1, {
    'bookingId': 'booking_1',
    'userId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'amount': 3500,
    'method': 'card',
    'gatewayRef': 'demo_gateway_123',
    'status': 'Pending',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 25, 10, 35)),
  });

  final payment2 = db.collection('payments').doc('payment_2');
  batch.set(payment2, {
    'bookingId': 'booking_2',
    'userId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'amount': 3500,
    'method': 'card',
    'gatewayRef': 'demo_gateway_456',
    'status': 'Success',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 20, 16)),
  });

  final payment3 = db.collection('payments').doc('payment_3');
  batch.set(payment3, {
    'bookingId': 'booking_3',
    'userId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'amount': 3500,
    'method': 'card',
    'gatewayRef': 'demo_gateway_789',
    'status': 'Failed',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 27, 10, 30)),
  });

  final review1 = db.collection('reviews').doc('review_1');
  batch.set(review1, {
    'bookingId': 'booking_1',
    'customerId': 'user_customer_1',
    'providerId': 'user_provider_1',
    'rating': 5,
    'comment': 'Great job!',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 30, 15)),
    'qPunctuality': 5,
    'qQuality': 5,
    'qCommunication': 4,
    'qProfessionalism': 5,
    'wouldRecommend': true,
    'hadDispute': false,
    'completionTimeMinutes': 150,
    'expectedDurationMinutes': 180,
  });

  final notif1 = db.collection('notifications').doc('notif_1');
  batch.set(notif1, {
    'userId': 'user_customer_1',
    'title': 'Booking confirmed',
    'body': 'Your booking booking_1 has been accepted.',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 25, 11)),
  });

  final adminNotif1 =
      db.collection('admin_notifications').doc('admin_notif_1');
  batch.set(adminNotif1, {
    'type': 'new_user',
    'userId': 'user_customer_1',
    'role': 'customer',
    'createdAt': Timestamp.fromDate(DateTime(2024, 11, 1, 10)),
  });

  // CHAT + MESSAGES (for chat/messages/worker badge)
  final chat1 = db.collection('chats').doc('chat_customer_provider1');
  batch.set(chat1, {
    'participants': ['user_customer_1', 'user_provider_1'],
    'lastMessage': 'Hello, I would like to confirm my booking.',
    'lastMessageSenderId': 'user_customer_1',
    'updatedAt': Timestamp.fromDate(DateTime(2024, 11, 25, 16)),
  });

  final chat1Msg1 =
      chat1.collection('messages').doc('msg_1');
  batch.set(chat1Msg1, {
    'senderId': 'user_customer_1',
    'text': 'Hello, I would like to confirm my booking.',
    'timestamp': Timestamp.fromDate(DateTime(2024, 11, 25, 15, 50)),
  });

  final chat1Msg2 =
      chat1.collection('messages').doc('msg_2');
  batch.set(chat1Msg2, {
    'senderId': 'user_provider_1',
    'text': 'Sure, I will be there on time.',
    'timestamp': Timestamp.fromDate(DateTime(2024, 11, 25, 15, 55)),
  });

  await batch.commit();
}
