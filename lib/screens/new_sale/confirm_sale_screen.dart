import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../services/sale_service.dart';
import '../../widgets/current_location_header.dart';
import '../../services/auth_service.dart';

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
  bool _isItemListExpanded = true;

  @override
  void dispose() {
    _commentController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> itemCount = {};
    for (var item in widget.selectedItems) {
      itemCount[item] = (itemCount[item] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Venta')),
      body: SafeArea(
        child: Column(
          children: [
            CurrentLocationHeader(location: widget.location),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Resumen de la venta:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isItemListExpanded = !_isItemListExpanded;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(
                                  'Artículos (${itemCount.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Spacer(),
                                Icon(
                                  _isItemListExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.purple,
                                ),
                              ],
                            ),
                          ),
                          if (_isItemListExpanded)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top:
                                      BorderSide(color: Colors.purple.shade100),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: itemCount.entries
                                    .map((entry) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  entry.key,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'x${entry.value}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoSection(
                          'Método de pago',
                          widget.paymentMethod,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoSection(
                          'Precio total',
                          '\$${widget.price.toStringAsFixed(2)}',
                          valueStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Nombre de cliente (opcional)',
                    'Agregar un nombre de cliente...',
                    _clientController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Comentario (opcional)',
                    'Agregar un comentario...',
                    _commentController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentUser = AuthService.currentUser;
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
                          sellerEmail:
                              currentUser?.email ?? 'vendedor@default.com',
                          sellerName: currentUser?.name ?? 'Vendedor Default',
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {int? maxLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          maxLines: maxLines ?? 1,
        ),
      ],
    );
  }
}
