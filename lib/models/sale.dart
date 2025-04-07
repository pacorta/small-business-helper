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

  // Para futura implementación:
  // factory Sale.fromJson(Map<String, dynamic> json) { ... }
  // Map<String, dynamic> toJson() { ... }
}
