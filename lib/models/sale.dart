import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final DateTime timestamp;
  final List<String> items;
  final String paymentMethod;
  final double price;
  final String id;
  final String? comment; // Nuevo campo
  final String? client;
  final String location; // Nueva propiedad

  Sale({
    required this.timestamp,
    required this.items,
    required this.paymentMethod,
    required this.price,
    required this.id,
    required this.location, // Requerida
    this.comment, // Opcional
    this.client,
  });

  // Constructor desde Firestore
  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      items: List<String>.from(data['items']),
      paymentMethod: data['paymentMethod'],
      price: (data['price'] as num).toDouble(),
      location: data['location'],
      comment: data['comment'],
      client: data['client'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items,
      'paymentMethod': paymentMethod,
      'price': price,
      'location': location,
      'comment': comment,
      'client': client,
      // Campos adicionales para búsquedas
      'searchFields': {
        'year': timestamp.year,
        'month': timestamp.month,
        'day': timestamp.day,
        'yearMonth':
            '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}',
      },
    };
  }

  // Para futura implementación:
  // factory Sale.fromJson(Map<String, dynamic> json) { ... }
  // Map<String, dynamic> toJson() { ... }
}
