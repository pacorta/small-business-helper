import 'package:flutter/material.dart';
import 'price_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final List<String> selectedItems;
  final String location;

  const PaymentMethodScreen({
    super.key,
    required this.selectedItems,
    required this.location,
  });

  final List<String> paymentMethods = const [
    'Efectivo',
    'Tarjeta',
    'Zelle',
    'Venmo',
    'CashApp',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cómo pagaron?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PriceScreen(
                              selectedItems: selectedItems,
                              paymentMethod: method,
                              location: location,
                            ),
                          ),
                        );
                      },
                      child: Text(method),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
