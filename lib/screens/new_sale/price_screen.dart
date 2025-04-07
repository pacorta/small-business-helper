import 'package:flutter/material.dart';
import 'confirm_sale_screen.dart';

class PriceScreen extends StatefulWidget {
  final List<String> selectedItems;
  final String paymentMethod;
  final String location;

  const PriceScreen({
    super.key,
    required this.selectedItems,
    required this.paymentMethod,
    required this.location,
  });

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String amount = '';
  bool includeTax = false;
  static const double TAX_RATE = 0.0825; // 8.25%

  void addDigit(String digit) {
    setState(() {
      if (digit == '.' && amount.contains('.')) return;
      if (digit == '.' && amount.isEmpty) {
        amount = '0.';
        return;
      }
      amount += digit;
    });
  }

  void removeDigit() {
    setState(() {
      if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
      }
    });
  }

  double get subtotal => amount.isEmpty ? 0 : double.parse(amount);
  double get tax => subtotal * TAX_RATE;
  double get total => subtotal + (includeTax ? tax : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cuánto costó?'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Panel de precio con altura fija
              Container(
                width: double.infinity,
                height: 150, // Incrementamos aún más la altura
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // Quitamos MainAxisSize.min para que use todo el espacio disponible
                  children: [
                    Text(
                      'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const Spacer(), // Usamos Spacer para distribuir espacio
                    AnimatedOpacity(
                      opacity: includeTax ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        'Impuesto (8.25%): \$${tax.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 8),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: includeTax ? Colors.green : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch de impuesto
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Switch(
                      value: includeTax,
                      onChanged: (value) => setState(() => includeTax = value),
                    ),
                    const Text(
                      'Agregar impuesto (8.25%)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Teclado numérico
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0']
                        .map((key) => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => addDigit(key),
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 24),
                              ),
                            )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: removeDigit,
                      child: const Icon(Icons.backspace),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Botón siguiente
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: amount.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmSaleScreen(
                                selectedItems: widget.selectedItems,
                                paymentMethod: widget.paymentMethod,
                                price: total,
                                location: widget.location,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
