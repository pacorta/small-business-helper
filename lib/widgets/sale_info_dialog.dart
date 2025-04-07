import 'package:flutter/material.dart';
import '../models/sale.dart';

class SaleInfoDialog extends StatelessWidget {
  final Sale sale;

  const SaleInfoDialog({
    super.key,
    required this.sale,
  });

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
            _buildInfoSection('Artículos', sale.items.join(', ')),
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
