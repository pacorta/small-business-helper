import 'package:collection/collection.dart';
import '../models/sale.dart';

class SaleAnalytics {
  final double totalAmount;
  final double averagePerDay;
  final String mostSoldItem;
  final String mostUsedPaymentMethod;
  final int totalSales;
  final Map<String, double> salesByLocation;

  SaleAnalytics({
    required this.totalAmount,
    required this.averagePerDay,
    required this.mostSoldItem,
    required this.mostUsedPaymentMethod,
    required this.totalSales,
    required this.salesByLocation,
  });
}

class AnalyticsService {
  static SaleAnalytics calculateAnalytics(List<Sale> sales) {
    if (sales.isEmpty) {
      return SaleAnalytics(
        totalAmount: 0,
        averagePerDay: 0,
        mostSoldItem: 'N/A',
        mostUsedPaymentMethod: 'N/A',
        totalSales: 0,
        salesByLocation: {},
      );
    }

    // Total de ventas
    final totalAmount = sales.fold<double>(
      0,
      (sum, sale) => sum + sale.price,
    );

    // Promedio por día
    final firstSaleDate = sales.last.timestamp;
    final lastSaleDate = sales.first.timestamp;
    final daysDifference = lastSaleDate.difference(firstSaleDate).inDays + 1;
    final averagePerDay = totalAmount / daysDifference;

    // Artículo más vendido
    final allItems = sales.expand((sale) => sale.items).toList();
    final itemFrequency = groupBy(allItems, (item) => item);
    final mostSoldItem = itemFrequency.entries
        .reduce((a, b) => a.value.length > b.value.length ? a : b)
        .key;

    // Método de pago más usado
    final paymentMethods = sales.map((sale) => sale.paymentMethod).toList();
    final methodFrequency = groupBy(paymentMethods, (method) => method);
    final mostUsedPaymentMethod = methodFrequency.entries
        .reduce((a, b) => a.value.length > b.value.length ? a : b)
        .key;

    // Ventas por ubicación
    final salesByLocation = <String, double>{};
    for (final sale in sales) {
      salesByLocation[sale.location] =
          (salesByLocation[sale.location] ?? 0) + sale.price;
    }

    return SaleAnalytics(
      totalAmount: totalAmount,
      averagePerDay: averagePerDay,
      mostSoldItem: mostSoldItem,
      mostUsedPaymentMethod: mostUsedPaymentMethod,
      totalSales: sales.length,
      salesByLocation: salesByLocation,
    );
  }
}
