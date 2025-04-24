import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'config';

  // Singleton para cachear las configuraciones
  // Todavia tenemos un parpadeo ligero. Se arregló aquí.
  static final ConfigService _instance = ConfigService._();
  static ConfigService get instance => _instance;

  ConfigService._();

  // Cache de configuraciones
  List<String>? _cachedItems;
  List<String>? _cachedPaymentMethods;
  List<String>? _cachedLocations;

  final _cache = <String, List<String>>{};
  final _cacheDuration = const Duration(minutes: 5);
  final _cacheTimestamps = <String, DateTime>{};

  Future<List<String>> _getCachedData(
      String key, Future<List<String>> Function() fetchData) async {
    final now = DateTime.now();
    if (_cache.containsKey(key) &&
        _cacheTimestamps[key]!.isAfter(now.subtract(_cacheDuration))) {
      return _cache[key]!;
    }

    final data = await fetchData();
    _cache[key] = data;
    _cacheTimestamps[key] = now;
    return data;
  }

  // Obtener artículos disponibles
  Future<List<String>> getAvailableItems() async {
    if (_cachedItems != null) return _cachedItems!;

    try {
      final doc = await _firestore.collection(_collection).doc('items').get();
      if (doc.exists && doc.data() != null) {
        _cachedItems = List<String>.from(doc.data()!['available_items'] ?? []);
        return _cachedItems!;
      }
      // Valores por defecto si no hay configuración
      _cachedItems = ['Collar', 'Pulsera', 'Aretes', 'Anillo', 'San Benito'];
      return _cachedItems!;
    } catch (e) {
      throw Exception('Error al obtener artículos: $e');
    }
  }

  // Obtener métodos de pago
  Future<List<String>> getPaymentMethods() async {
    if (_cachedPaymentMethods != null) return _cachedPaymentMethods!;

    try {
      final doc =
          await _firestore.collection(_collection).doc('payment_methods').get();
      if (doc.exists && doc.data() != null) {
        _cachedPaymentMethods = List<String>.from(doc.data()!['methods'] ?? []);
        return _cachedPaymentMethods!;
      }
      _cachedPaymentMethods = ['Efectivo', 'Tarjeta', 'Transferencia'];
      return _cachedPaymentMethods!;
    } catch (e) {
      throw Exception('Error al obtener métodos de pago: $e');
    }
  }

  // Obtener ubicaciones
  Future<List<String>> getLocations() async {
    if (_cachedLocations != null) {
      // print('Returning cached locations: $_cachedLocations');
      return _cachedLocations!;
    }

    try {
      final doc =
          await _firestore.collection(_collection).doc('locations').get();
      // print('Firestore locations document: ${doc.data()}');

      if (doc.exists && doc.data() != null) {
        _cachedLocations =
            List<String>.from(doc.data()!['available_locations'] ?? []);
        // print('Loaded locations from Firestore: $_cachedLocations');
        return _cachedLocations!;
      }

      // print('No locations found in Firestore, using defaults');
      _cachedLocations = ['Farmers Market', 'Tienda', 'Otro'];
      return _cachedLocations!;
    } catch (e) {
      // print('Error getting locations: $e');
      throw Exception('Error al obtener ubicaciones: $e');
    }
  }

  // Limpiar cache (útil cuando se actualizan las configuraciones)
  void clearCache() {
    _cachedItems = null;
    _cachedPaymentMethods = null;
    _cachedLocations = null;
  }

  Future<void> updateItems(List<String> items) async {
    try {
      await _firestore.collection(_collection).doc('items').set({
        'available_items': items,
      });
      _cachedItems = null;
    } catch (e) {
      throw Exception('Error al actualizar artículos: $e');
    }
  }

  Future<void> updatePaymentMethods(List<String> methods) async {
    try {
      await _firestore.collection(_collection).doc('payment_methods').set({
        'methods': methods,
      });
      _cachedPaymentMethods = null;
    } catch (e) {
      throw Exception('Error al actualizar métodos de pago: $e');
    }
  }

  Future<void> updateLocations(List<String> locations) async {
    try {
      // print('Updating locations in Firestore: $locations');
      await _firestore.collection(_collection).doc('locations').set({
        'available_locations': locations,
      });
      // print('Locations updated successfully');
      _cachedLocations = null;
    } catch (e) {
      // print('Error updating locations: $e');
      throw Exception('Error al actualizar ubicaciones: $e');
    }
  }
}
