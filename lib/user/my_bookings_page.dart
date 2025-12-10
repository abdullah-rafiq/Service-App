import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/models/booking.dart';
import 'package:flutter_application_1/models/service.dart';
import 'package:flutter_application_1/services/booking_service.dart';
import 'package:flutter_application_1/services/service_catalog_service.dart';
import 'package:flutter_application_1/user/payment_page.dart';
import 'package:flutter_application_1/user/booking_detail_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your bookings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService.instance.watchCustomerBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load bookings.'),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'When you book a service, it will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/home');
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Browse services'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          Color statusColor(String status) {
            switch (status) {
              case BookingStatus.completed:
                return Colors.green;
              case BookingStatus.cancelled:
                return Colors.redAccent;
              case BookingStatus.inProgress:
              case BookingStatus.onTheWay:
                return Colors.orange;
              default:
                return Colors.blueGrey;
            }
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingDetailPage(booking: b),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cleaning_services_rounded,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FutureBuilder<ServiceModel?>(
                          future: ServiceCatalogService.instance
                              .getService(b.serviceId),
                          builder: (context, serviceSnap) {
                            final service = serviceSnap.data;
                            final serviceName = service?.name ?? 'Service';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.scheduledTime == null
                                      ? 'Time: not set'
                                      : 'Time: ${_formatDateTime(b.scheduledTime)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(b.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              b.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor(b.status),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'PKR ${b.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (b.paymentStatus == PaymentStatus.pending)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(booking: b),
                                  ),
                                );
                              },
                              child: const Text('Pay now'),
                            )
                          else
                            const Text(
                              'Paid',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: bookings.length,
          );
        },
      ),
      backgroundColor: const Color(0xFFF6FBFF),
    );
  }
}

String _formatDateTime(DateTime? dt) {
  if (dt == null) return 'Not set';
  final local = dt.toLocal();
  final date = '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
  final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date • $time';
}
