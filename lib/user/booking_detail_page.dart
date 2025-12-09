import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/booking.dart';
import 'package:flutter_application_1/services/booking_service.dart';
import 'package:flutter_application_1/user/payment_page.dart';

class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Booking details'),
      ),
      backgroundColor: const Color(0xFFF6FBFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service ID: ${booking.serviceId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${booking.status}'),
                  const SizedBox(height: 8),
                  Text(
                    'Scheduled time: '
                    '${booking.scheduledTime == null ? 'Not set' : booking.scheduledTime.toString()}',
                  ),
                  const SizedBox(height: 8),
                  Text('Price: PKR ${booking.price.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text('Payment status: ${booking.paymentStatus}'),
                  const SizedBox(height: 8),
                  if (booking.address != null && booking.address!.isNotEmpty)
                    Text('Address: ${booking.address}'),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: booking.paymentStatus == PaymentStatus.unpaid
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentPage(booking: booking),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Pay now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await BookingService.instance.updateStatus(
                        booking.id,
                        BookingStatus.cancelled,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking cancelled (demo only).'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Cancel booking'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
