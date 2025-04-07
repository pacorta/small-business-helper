import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class SalesAnalyticsCard extends StatelessWidget {
  final SaleAnalytics analytics;

  const SalesAnalyticsCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Ventas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildStatRow(
              'Total de Ventas:',
              '\$${analytics.totalAmount.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            _buildStatRow(
              'Promedio Diario:',
              '\$${analytics.averagePerDay.toStringAsFixed(2)}',
              Icons.trending_up,
            ),
            _buildStatRow(
              'Artículo más Vendido:',
              analytics.mostSoldItem,
              Icons.star,
            ),
            _buildStatRow(
              'Método de Pago Preferido:',
              analytics.mostUsedPaymentMethod,
              Icons.payment,
            ),
            _buildStatRow(
              'Número de Ventas:',
              analytics.totalSales.toString(),
              Icons.shopping_cart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
