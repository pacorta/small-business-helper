import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale.dart';

class SaleService {
  static const String _storageKey = 'sales';

  // Convertir Sale a JSON
  static Map<String, dynamic> _saleToJson(Sale sale) {
    return {
      'timestamp': sale.timestamp.toIso8601String(),
      'items': sale.items,
      'paymentMethod': sale.paymentMethod,
      'price': sale.price,
      'id': sale.id,
      'comment': sale.comment,
      'client': sale.client,
      'location': sale.location,
    };
  }

  // Convertir JSON a Sale
  static Sale _saleFromJson(Map<String, dynamic> json) {
    return Sale(
      timestamp: DateTime.parse(json['timestamp']),
      items: List<String>.from(json['items']),
      paymentMethod: json['paymentMethod'],
      price: json['price'].toDouble(),
      id: json['id'],
      comment: json['comment'] as String?,
      client: json['client'] as String?,
      location: json['location'] ??
          'Ubicación Desconocida', // Valor por defecto para ventas antiguas
    );
  }

  // Guardar una venta
  static Future<void> saveSale(Sale sale) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener ventas existentes
    final String? salesJson = prefs.getString(_storageKey);
    List<Map<String, dynamic>> sales = [];

    if (salesJson != null) {
      sales = List<Map<String, dynamic>>.from(
        jsonDecode(salesJson),
      );
    }

    // Agregar nueva venta
    sales.add(_saleToJson(sale));

    // Guardar lista actualizada
    await prefs.setString(_storageKey, jsonEncode(sales));
  }

  // Obtener todas las ventas
  static Future<List<Sale>> getAllSales() async {
    final prefs = await SharedPreferences.getInstance();
    final String? salesJson = prefs.getString(_storageKey);

    if (salesJson == null) {
      return [];
    }

    final List<dynamic> salesList = jsonDecode(salesJson);
    return salesList
        .map((saleJson) => _saleFromJson(Map<String, dynamic>.from(saleJson)))
        .toList()
      ..sort((a, b) =>
          b.timestamp.compareTo(a.timestamp)); // Ordenar por fecha descendente
  }
}
