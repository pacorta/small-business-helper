import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class SalesAnalyticsCard extends StatefulWidget {
  final SaleAnalytics analytics;
  final String? activeFilters;

  const SalesAnalyticsCard({
    super.key,
    required this.analytics,
    this.activeFilters,
  });

  @override
  State<SalesAnalyticsCard> createState() => _SalesAnalyticsCardState();
}

class _SalesAnalyticsCardState extends State<SalesAnalyticsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Resumen de Ventas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                if (widget.activeFilters != null &&
                    widget.activeFilters!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: Colors.purple.shade300,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.activeFilters!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMainStats(),
                  const SizedBox(height: 16),
                  _buildDetailedStats(),
                ],
              ),
            ),
          ] else ...[
            // Mostrar solo las estadísticas principales cuando está colapsado
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildMainStats(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            '\$${widget.analytics.totalAmount.toStringAsFixed(2)}',
            'Total de Ventas',
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            widget.analytics.totalSales.toString(),
            'Ventas',
            Icons.shopping_cart,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildStatRow(
          'Promedio Diario:',
          '\$${widget.analytics.averagePerDay.toStringAsFixed(2)}',
          Icons.trending_up,
        ),
        _buildStatRow(
          'Artículo más Vendido:',
          widget.analytics.mostSoldItem,
          Icons.star,
        ),
        _buildStatRow(
          'Método de Pago Preferido:',
          widget.analytics.mostUsedPaymentMethod,
          Icons.payment,
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.purple.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
