import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'brazilian_city.dart';
import 'selected_city_repository.dart';

class CloudSelectedCityRepository implements SelectedCityRepository {
  final FirebaseFirestore firestore;
  final String userId;

  const CloudSelectedCityRepository({
    required this.firestore,
    required this.userId,
  });

  DocumentReference<Map<String, dynamic>> get _document {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('monitored_city');
  }

  @override
  Future<BrazilianCity> getSelected() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _document.get().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      snapshot = await _document.get(const GetOptions(source: Source.cache));
    }

    final data = snapshot.data();

    if (data == null) {
      return SqliteSelectedCityRepository.defaultCity;
    }

    return BrazilianCity.fromDatabase(Map<String, Object?>.from(data));
  }

  @override
  Future<void> save(BrazilianCity city) async {
    final operation = _document.set(
      Map<String, dynamic>.from(city.toDatabase()),
    );

    try {
      await operation.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      return;
    }
  }
}
