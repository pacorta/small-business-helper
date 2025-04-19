import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'locations';
  static const String _currentLocationKey = 'currentLocation';

  // Obtener todas las ubicaciones activas
  static Future<List<String>> getAllLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('active', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    } catch (e) {
      throw 'Error al obtener ubicaciones: $e';
    }
  }

  // Agregar nueva ubicación
  static Future<void> addLocation(String name) async {
    try {
      await _firestore.collection(_collection).add({
        'name': name,
        'active': true,
      });
    } catch (e) {
      throw 'Error al agregar ubicación: $e';
    }
  }

  // Desactivar una ubicación
  static Future<void> deactivateLocation(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'active': false});
      }
    } catch (e) {
      throw 'Error al desactivar ubicación: $e';
    }
  }

  // Obtener ubicación actual (temporal, usando SharedPreferences por ahora)
  static Future<String?> getCurrentLocation() async {
    try {
      final locations = await getAllLocations();
      return locations.isNotEmpty ? locations.first : null;
    } catch (e) {
      throw 'Error al obtener ubicación actual: $e';
    }
  }

  // Establecer ubicación actual
  static Future<void> setCurrentLocation(String location) async {
    // Por ahora, solo verificamos que la ubicación exista
    final locations = await getAllLocations();
    if (!locations.contains(location)) {
      throw 'Ubicación no válida';
    }
  }
}
