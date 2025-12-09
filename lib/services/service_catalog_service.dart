import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/service.dart';

class ServiceCatalogService {
  ServiceCatalogService._();

  static final ServiceCatalogService instance = ServiceCatalogService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categoriesCol =>
      _db.collection('categories');

  CollectionReference<Map<String, dynamic>> get _servicesCol =>
      _db.collection('services');

  Stream<List<CategoryModel>> watchCategories() {
    return _categoriesCol.where('isActive', isEqualTo: true).snapshots().map(
          (snap) =>
              snap.docs.map((d) => CategoryModel.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<ServiceModel>> watchServicesForCategory(String categoryId) {
    return _servicesCol
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ServiceModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<ServiceModel?> getService(String id) async {
    final doc = await _servicesCol.doc(id).get();
    if (!doc.exists) return null;
    return ServiceModel.fromMap(doc.id, doc.data()!);
  }
}
