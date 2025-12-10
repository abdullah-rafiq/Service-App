import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/models/booking.dart';
import 'package:flutter_application_1/models/review.dart';

class AdminWorkerDetailPage extends StatelessWidget {
  final AppUser worker;

  const AdminWorkerDetailPage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name?.isNotEmpty == true ? worker.name! : 'Worker details'),
      ),
      backgroundColor: const Color(0xFFF6FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildEarningsSection(),
            const SizedBox(height: 16),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
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
            worker.name?.isNotEmpty == true ? worker.name! : 'Worker',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${worker.id}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          if (worker.phone != null)
            Text(
              'Phone: ${worker.phone}',
              style: const TextStyle(fontSize: 13),
            ),
          if (worker.email != null)
            Text(
              'Email: ${worker.email}',
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(height: 4),
          Text(
            'Status: ${worker.status}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection() {
    final bookingsQuery = FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: worker.id)
        .where('status', isEqualTo: BookingStatus.completed);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: bookingsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _sectionCard(
            title: 'Earnings',
            child: Text('Error loading earnings: ${snapshot.error}'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final bookings = docs
            .map((d) => BookingModel.fromMap(d.id, d.data()))
            .toList();

        final total = bookings.fold<num>(
          0,
          (sum, b) => sum + (b.price),
        );

        return _sectionCard(
          title: 'Earnings',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: PKR ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bookings.isEmpty
                    ? 'No completed jobs yet.'
                    : 'Based on ${bookings.length} completed job(s).',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    final reviewsQuery = FirebaseFirestore.instance
        .collection('reviews')
        .where('providerId', isEqualTo: worker.id)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reviewsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _sectionCard(
            title: 'Customer reviews',
            child: Text('Error loading reviews: ${snapshot.error}'),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _sectionCard(
            title: 'Customer reviews',
            child: const Text('No reviews yet.'),
          );
        }

        final reviews = docs
            .map((d) => ReviewModel.fromMap(d.id, d.data()))
            .toList();

        final avgRating = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;

        return _sectionCard(
          title: 'Customer reviews',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${reviews.length} review(s))',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < r.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        if (r.comment != null && r.comment!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              r.comment!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking: ${r.bookingId}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
