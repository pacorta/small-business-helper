import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class SelectItemsScreen extends StatefulWidget {
  final String currentLocation;

  const SelectItemsScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<SelectItemsScreen> createState() => _SelectItemsScreenState();
}

class _SelectItemsScreenState extends State<SelectItemsScreen> {
  final Set<String> selectedItems = {};
  final TextEditingController _otherItemController = TextEditingController();

  final List<String> predefinedItems = [
    'Collar',
    'Pulsera',
    'Anillo',
    'Aretes',
    'San Benito',
    'Otro',
  ];

  @override
  void dispose() {
    _otherItemController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar otro artículo'),
        content: TextField(
          controller: _otherItemController,
          decoration: const InputDecoration(
            hintText: 'Nombre del artículo...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_otherItemController.text.isNotEmpty) {
                setState(() {
                  selectedItems.add(_otherItemController.text);
                });
                _otherItemController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué se vendió?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: predefinedItems.length,
                itemBuilder: (context, index) {
                  final item = predefinedItems[index];
                  final isSelected = selectedItems.contains(item);
                  final isOtherButton = item == 'Otro';

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected && !isOtherButton
                          ? Colors.purple
                          : Colors.grey,
                    ),
                    onPressed: () {
                      if (isOtherButton) {
                        _showAddItemDialog();
                      } else {
                        setState(() {
                          if (isSelected) {
                            selectedItems.remove(item);
                          } else {
                            selectedItems.add(item);
                          }
                        });
                      }
                    },
                    child: Text(item),
                  );
                },
              ),
            ),
            // Mostrar items personalizados
            if (selectedItems
                .any((item) => !predefinedItems.contains(item))) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Artículos personalizados:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                children: selectedItems
                    .where((item) => !predefinedItems.contains(item))
                    .map((item) => Chip(
                          label: Text(item),
                          onDeleted: () {
                            setState(() {
                              selectedItems.remove(item);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: selectedItems.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethodScreen(
                            selectedItems: selectedItems.toList(),
                            location: widget.currentLocation,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
