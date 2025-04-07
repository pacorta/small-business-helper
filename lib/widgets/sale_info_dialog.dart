import 'package:flutter/material.dart';
import '../models/sale.dart';

class SaleInfoDialog extends StatelessWidget {
  final Sale sale;

  const SaleInfoDialog({
    super.key,
    required this.sale,
  });

  String _formatItems(List<String> items) {
    // Crear un Map para contar los items
    final Map<String, int> itemCount = {};
    for (var item in items) {
      itemCount[item] = (itemCount[item] ?? 0) + 1;
    }

    // Convertir el Map a una lista formateada
    return itemCount.entries
        .map((entry) =>
            entry.value > 1 ? '${entry.key} (x${entry.value})' : entry.key)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalles de la Venta'),
      content: SingleChildScrollView(
        // Agregamos scroll
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('Fecha',
                '${sale.timestamp.day}/${sale.timestamp.month}/${sale.timestamp.year}'),
            _buildInfoSection('Hora',
                '${sale.timestamp.hour}:${sale.timestamp.minute.toString().padLeft(2, '0')}'),
            _buildInfoSection('Artículos', _formatItems(sale.items)),
            _buildInfoSection('Método de Pago', sale.paymentMethod),
            _buildInfoSection('Ubicación', sale.location),
            if (sale.client != null) _buildInfoSection('Cliente', sale.client!),
            if (sale.comment != null)
              _buildInfoSection('Comentario', sale.comment!),
            _buildInfoSection('Total', '\$${sale.price.toStringAsFixed(2)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
