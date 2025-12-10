import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/models/review.dart';
import 'package:flutter_application_1/models/category.dart';
import 'package:flutter_application_1/models/service.dart';
import 'package:flutter_application_1/services/service_catalog_service.dart';
import 'package:flutter_application_1/services/worker_ranking_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_application_1/user/category_services_page.dart';
import 'package:flutter_application_1/user/service_detail_page.dart';
import 'package:flutter_application_1/user/my_bookings_page.dart';
import 'package:flutter_application_1/common/profile_page.dart';
import 'package:flutter_application_1/user/messages_page.dart';
import 'package:flutter_application_1/user/notifications_page.dart';
import 'package:flutter_application_1/user/category_search_page.dart';
import 'package:flutter_application_1/common/app_bottom_nav.dart';

class ProviderModel {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final double pricePerHour;
  final String service;

  ProviderModel({
    required this.id,
    required this.name,
    this.avatar = 'assets/profile.png',
    this.rating = 4.5,
    this.pricePerHour = 250.0,
    required this.service,
  });
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  final Color primaryLightBlue = const Color(0xFF4FC3F7);
  final Color primaryBlue = const Color(0xFF29B6F6);
  final Color primaryDarkBlue = const Color(0xFF0288D1);
  late final Color surfaceWhite = Colors.white.withOpacity(0.95);
  int _currentIndex = 0;

  // Speech-to-text
  //final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    final current = FirebaseAuth.instance.currentUser;
    // Debug print to verify which UID is logged in
    // Check this value in the console and ensure your notifications.userId matches it.
    // Remove this print in production.
    // ignore: avoid_print
    print('CURRENT UID = ${current?.uid}');
  }

  Widget _buildTopWorkersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryDarkBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top workers',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'provider')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Could not load top workers.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                );
              }

              final providerDocs = snapshot.data?.docs ?? [];

              if (providerDocs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No workers available yet.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                );
              }

              return FutureBuilder<List<_TopWorkerItem>>(
                future: _loadTopWorkers(providerDocs),
                builder: (context, rankingSnap) {
                  if (rankingSnap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (rankingSnap.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Could not load top workers.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    );
                  }

                  final items = rankingSnap.data ?? [];

                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No workers with reviews yet.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    );
                  }

                  final topItems = items.length > 5 ? items.sublist(0, 5) : items;

                  return Column(
                    children: topItems.map((item) {
                      final name = (item.user.name?.trim().isNotEmpty ?? false)
                          ? item.user.name!.trim()
                          : 'Worker';

                      String? distanceLabel;
                      if (item.distanceKm != null) {
                        final d = item.distanceKm!;
                        if (d < 1.0) {
                          distanceLabel = '${(d * 1000).round()} m away';
                        } else {
                          distanceLabel = '${d.toStringAsFixed(1)} km away';
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: item.user.profileImageUrl != null &&
                                      item.user.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(item.user.profileImageUrl!)
                                  : const AssetImage('assets/profile.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (distanceLabel != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          distanceLabel,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.avgRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${item.reviewCount} reviews)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  final List<ProviderModel> featuredProviders = [
    ProviderModel(
      id: 'p1',
      name: 'Raza Khan',
      avatar: 'assets/profile.png',
      rating: 4.8,
      pricePerHour: 300,
      service: 'Plumbing',
    ),
    ProviderModel(
      id: 'p2',
      name: 'Sadia Ali',
      avatar: 'assets/profile.png',
      rating: 4.6,
      pricePerHour: 250,
      service: 'Cleaning',
    ),
    ProviderModel(
      id: 'p3',
      name: 'Bilal Ahmed',
      avatar: 'assets/profile.png',
      rating: 4.7,
      pricePerHour: 280,
      service: 'Electrician',
    ),
  ];

  Widget _buildGradientAppBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final current = FirebaseAuth.instance.currentUser;
    return Container(
      height: kToolbarHeight + topPadding,
      padding: EdgeInsets.only(top: topPadding, left: 12, right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryLightBlue, primaryDarkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryDarkBlue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome,',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (current == null)
                    const Text(
                      'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                  else
                    StreamBuilder<AppUser?>(
                      stream:
                          UserService.instance.watchUser(current.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            '...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          );
                        }

                        final user = snapshot.data;
                        String? name = user?.name;
                        String displayName = 'User';

                        if (name != null && name.trim().isNotEmpty) {
                          name = name.trim();
                          displayName = name[0].toUpperCase() +
                              (name.length > 1 ? name.substring(1) : '');
                        }

                        return Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return StreamBuilder<List<CategoryModel>>(
      stream: ServiceCatalogService.instance.watchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Could not load categories.'));
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return const Center(child: Text('No categories available.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ListTile(
              leading: (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(cat.iconUrl!),
                    )
                  : CircleAvatar(
                      backgroundColor: primaryLightBlue.withOpacity(0.2),
                      child: Text(
                        cat.name.isNotEmpty
                            ? cat.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              title: Text(cat.name),
              subtitle: Text(
                cat.isActive ? 'Available' : 'Currently unavailable',
                style: TextStyle(
                  color: cat.isActive ? Colors.green : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryServicesPage(category: cat),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: categories.length,
        );
      },
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CategorySearchPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white70],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryDarkBlue.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryLightBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.search, color: primaryDarkBlue),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search services, providers or locations',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            // GestureDetector(
            //   onTap: () => _startVoiceSearch(context),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: primaryLightBlue.withOpacity(0.12),
            //       shape: BoxShape.circle,
            //     ),
            //     padding: const EdgeInsets.all(8),
            //     child: Icon(
            //       _isListening ? Icons.mic : Icons.mic_none,
            //       color: primaryDarkBlue,
            //       size: 18,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Future<void> _startVoiceSearch(BuildContext context) async {
  //   try {
  //     final available = await _speech.initialize(
  //       onStatus: (status) {
  //         // ignore: avoid_print
  //         print('SPEECH_STATUS: $status');
  //       },
  //       onError: (error) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Speech error: ${error.errorMsg}')),
  //         );
  //       },
  //     );

  //     if (!available) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Speech recognition not available')),
  //       );
  //       return;
  //     }

  //     setState(() => _isListening = true);

  //     _speech.listen(
  //       onResult: (result) {
  //         if (!result.finalResult) return;
  //         final text = result.recognizedWords.trim();
  //         setState(() {
  //           _isListening = false;
  //         });

  //         if (text.isEmpty) return;

  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (_) => CategorySearchPage(initialQuery: text),
  //           ),
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     setState(() => _isListening = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not start voice search: $e')),
  //     );
  //   }
  // }

  Widget _buildCategories() {
    return SizedBox(
      height: 140,
      child: StreamBuilder<List<CategoryModel>>(
        stream: ServiceCatalogService.instance.watchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load categories.'));
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text('No categories available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final cat = categories[index];
              print('Category ${cat.name} iconUrl = ${cat.iconUrl}');
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryServicesPage(category: cat),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryLightBlue.withOpacity(0.9 - index * 0.08),
                            primaryBlue.withOpacity(0.85 - index * 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryDarkBlue.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
                            ? Image.network(
                                cat.iconUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      cat.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  cat.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: categories.length,
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProviders() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final p = featuredProviders[index];
          return Container(
            width: 270,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primaryDarkBlue.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage(p.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.service,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${p.rating}',
                                style:
                                    const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryLightBlue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Top Rated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryDarkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKR ${p.pricePerHour.toInt()}/hr',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: primaryDarkBlue,
                        fontSize: 15,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final service = ServiceModel(
                          id: p.service.toLowerCase(),
                          name: p.service,
                          basePrice: p.pricePerHour,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(service: service),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryBlue,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: featuredProviders.length,
      ),
    );
  }

  Widget _buildUpcomingBookingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryDarkBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/provider1.png'),
            ),
            title: Text('Plumbing - Kitchen sink'),
            subtitle: Text('Tomorrow • 10:00 AM'),
            trailing: Chip(
              label: Text(
                'Requested',
                style: TextStyle(color: Colors.orange),
              ),
              backgroundColor: Color(0x22FFA726),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/provider2.png'),
            ),
            title: Text('Home Cleaning'),
            subtitle: Text('2025-11-25 • 2:00 PM'),
            trailing: Chip(
              label: Text(
                'Confirmed',
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Color(0x2232CD32),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // Home
      ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGradientAppBar(context),
                _buildSearchCard(context),
                const SizedBox(height: 6),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                _buildCategories(),
                const SizedBox(height: 12),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: Text(
                    'Featured Providers',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                _buildFeaturedProviders(),
                const SizedBox(height: 16),
                _buildTopWorkersSection(),
                const SizedBox(height: 16),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: Text(
                    'Upcoming Bookings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                _buildUpcomingBookingsCard(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0),
                  child: Center(
                    child: Text(
                      'Need help? Contact support',
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
      // Categories tab - show categories as a vertical list
      Scaffold(
        backgroundColor: const Color(0xFFF6FBFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF29B6F6),
          foregroundColor: Colors.white,
          elevation: 4,
          title: const Text('Categories'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primaryDarkBlue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                  child: Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _buildCategoriesList()),
              ],
            ),
          ),
        ),
      ),
      // Bookings tab
      const MyBookingsPage(),
      // Messages tab
      const MessagesPage(),
      // Profile tab
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _TopWorkerItem {
  final AppUser user;
  final double score;
  final double avgRating;
  final int reviewCount;
  final double? distanceKm;

  _TopWorkerItem({
    required this.user,
    required this.score,
    required this.avgRating,
    required this.reviewCount,
    this.distanceKm,
  });
}

Future<List<_TopWorkerItem>> _loadTopWorkers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) async {
  final now = DateTime.now();

  double? userLat;
  double? userLng;

  final current = FirebaseAuth.instance.currentUser;
  if (current != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(current.uid)
        .get();
    final userData = userDoc.data();
    if (userData != null) {
      userLat = (userData['locationLat'] as num?)?.toDouble();
      userLng = (userData['locationLng'] as num?)?.toDouble();
    }
  }

  final futures = docs.map((doc) async {
    final data = doc.data();
    final user = AppUser.fromMap(doc.id, data);

    final providerLat = (data['locationLat'] as num?)?.toDouble();
    final providerLng = (data['locationLng'] as num?)?.toDouble();

    double? distanceKm;
    if (userLat != null && userLng != null && providerLat != null && providerLng != null) {
      distanceKm = WorkerRankingService.haversineKm(
        userLat,
        userLng,
        providerLat,
        providerLng,
      );
    }

    final reviewsSnap = await FirebaseFirestore.instance
        .collection('reviews')
        .where('providerId', isEqualTo: user.id)
        .get();

    final reviews = reviewsSnap.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();

    final score = WorkerRankingService.computeScoreWithDistance(
      reviews,
      now,
      distanceKm: distanceKm,
      maxRadiusKm: 5.0,
    );

    double avgRating = 0.0;
    if (reviews.isNotEmpty) {
      avgRating = reviews
              .map((r) => r.rating.toDouble())
              .reduce((a, b) => a + b) /
          reviews.length;
    }

    return _TopWorkerItem(
      user: user,
      score: score,
      avgRating: avgRating,
      reviewCount: reviews.length,
      distanceKm: distanceKm,
    );
  }).toList();

  final list = await Future.wait(futures);

  list.removeWhere((item) {
    if (item.score <= 0 && item.reviewCount == 0) {
      return true;
    }
    if (item.distanceKm != null && item.distanceKm! > 5.0) {
      return true;
    }
    return false;
  });
  list.sort((a, b) => b.score.compareTo(a.score));
  return list;
}

class _MessagesIconWithBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Icon(Icons.message_outlined);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final hasUnread = docs.any((doc) {
          final data = doc.data();
          final lastSender = data['lastMessageSenderId'] as String?;
          return lastSender != null && lastSender != user.uid;
        });

        if (!hasUnread) {
          return const Icon(Icons.message_outlined);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: const [
            Icon(Icons.message_outlined),
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(
                radius: 4,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}

