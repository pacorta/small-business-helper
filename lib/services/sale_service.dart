import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import '../services/auth_service.dart';

class SaleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'sales';

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
      location: json['location'] ?? 'Ubicación Desconocida',
      sellerEmail: json['sellerEmail'] ?? 'vendedor@default.com',
      sellerName: json['sellerName'] ?? 'Vendedor Default',
    );
  }

  // Guardar una venta
  static Future<void> saveSale(Sale sale) async {
    try {
      final currentUser = AuthService.currentUser;
      final saleData = sale.toFirestore();

      // Agregar información del vendedor
      saleData['sellerEmail'] = currentUser?.email ?? 'vendedor@default.com';
      saleData['sellerName'] = currentUser?.name ?? 'Vendedor Default';

      await _firestore.collection(_collection).add(saleData);
    } catch (e) {
      throw 'Error al guardar la venta: $e';
    }
  }

  // Obtener todas las ventas
  static Future<List<Sale>> getAllSales() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error al obtener las ventas: $e';
    }
  }

  // Obtener ventas por rango de fecha
  static Future<List<Sale>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error al obtener las ventas por fecha: $e';
    }
  }

  static Future<void> updateSale(Sale sale) async {
    try {
      await _firestore.collection(_collection).doc(sale.id).update({
        'timestamp': Timestamp.fromDate(sale.timestamp),
        'items': sale.items,
        'paymentMethod': sale.paymentMethod,
        'price': sale.price,
        'location': sale.location,
        'client': sale.client,
        'comment': sale.comment,
        'sellerEmail': sale.sellerEmail,
        'sellerName': sale.sellerName,
      });
    } catch (e) {
      throw Exception('Error al actualizar la venta: $e');
    }
  }
}
