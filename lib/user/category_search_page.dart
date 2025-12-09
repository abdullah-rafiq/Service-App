import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/category.dart';
import 'package:flutter_application_1/services/service_catalog_service.dart';
import 'category_services_page.dart';

class CategorySearchPage extends StatefulWidget {
  const CategorySearchPage({super.key});

  @override
  State<CategorySearchPage> createState() => _CategorySearchPageState();
}

class _CategorySearchPageState extends State<CategorySearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search services'),
      ),
      backgroundColor: const Color(0xFFF6FBFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by category name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: ServiceCatalogService.instance.watchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Could not load categories'));
                }

                var categories = snapshot.data ?? [];
                if (_query.isNotEmpty) {
                  categories = categories
                      .where((c) => c.name.toLowerCase().contains(_query))
                      .toList();
                }

                if (categories.isEmpty) {
                  return const Center(child: Text('No matching categories'));
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
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
                          color: cat.isActive
                              ? Colors.green
                              : Colors.redAccent,
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
            ),
          ),
        ],
      ),
    );
  }
}
