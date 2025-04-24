import 'package:cloud_firestore/cloud_firestore.dart';
import 'config_service.dart';

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'locations';
  static const String _currentLocationDoc = 'current_location';

  // Obtener todas las ubicaciones activas
  static Future<List<String>> getAllLocations() async {
    return ConfigService.instance.getLocations();
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
      final doc = await _firestore
          .collection(_collection)
          .doc(_currentLocationDoc)
          .get();
      return doc.data()?['location'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Establecer ubicación actual
  static Future<void> setCurrentLocation(String location) async {
    try {
      // Primero verificamos que la ubicación sea válida usando ConfigService
      final validLocations = await ConfigService.instance.getLocations();
      if (!validLocations.contains(location)) {
        throw Exception('Ubicación no válida');
      }

      await _firestore.collection(_collection).doc(_currentLocationDoc).set({
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al establecer la ubicación: $e');
    }
  }
}
