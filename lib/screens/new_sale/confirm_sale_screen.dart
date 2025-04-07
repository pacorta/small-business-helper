import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../services/sale_service.dart';

class ConfirmSaleScreen extends StatefulWidget {
  final List<String> selectedItems;
  final String paymentMethod;
  final double price;
  final String location;

  const ConfirmSaleScreen({
    super.key,
    required this.selectedItems,
    required this.paymentMethod,
    required this.price,
    required this.location,
  });

  @override
  State<ConfirmSaleScreen> createState() => _ConfirmSaleScreenState();
}

class _ConfirmSaleScreenState extends State<ConfirmSaleScreen> {
  final _commentController = TextEditingController();
  final _clientController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de la venta:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Sección de artículos scrollable
            Text(
              'Artículos:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              constraints: const BoxConstraints(
                  maxHeight: 120), // Reducimos un poco la altura
              decoration: BoxDecoration(
                // Opcional: agregar un borde sutil
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.selectedItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Text('• $item'),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Método de pago
            Text(
              'Método de pago:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(widget.paymentMethod),
            ),
            const SizedBox(height: 12),
            // Precio total
            Text(
              'Precio total:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cliente
            Text(
              'Nombre de cliente (opcional):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _clientController,
              decoration: const InputDecoration(
                hintText: 'Agregar un nombre de cliente...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Comentario
            Text(
              'Comentario (opcional):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Agregar un comentario...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2, // Reducimos a 2 líneas
            ),
            const SizedBox(height: 20),
            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final sale = Sale(
                        timestamp: DateTime.now(),
                        items: widget.selectedItems,
                        paymentMethod: widget.paymentMethod,
                        price: widget.price,
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        comment: _commentController.text.isNotEmpty
                            ? _commentController.text
                            : null,
                        client: _clientController.text.isNotEmpty
                            ? _clientController.text
                            : null,
                        location: widget.location,
                      );

                      try {
                        await SaleService.saveSale(sale);
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Venta registrada con éxito!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.popUntil(context, (route) => route.isFirst);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar la venta: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
