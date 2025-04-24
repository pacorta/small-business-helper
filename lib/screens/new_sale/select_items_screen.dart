import 'package:flutter/material.dart';
import 'payment_method_screen.dart';
import '../../widgets/current_location_header.dart';
import '../../services/config_service.dart';

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
  final Map<String, int> selectedItems = {};
  final TextEditingController _otherItemController = TextEditingController();
  List<String> _availableItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ConfigService.instance.getAvailableItems();
      setState(() {
        _availableItems = [...items, 'Otro'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar artículos: $e')),
        );
      }
    }
  }

  void _addItem(String item) {
    setState(() {
      selectedItems[item] = (selectedItems[item] ?? 0) + 1;
    });
  }

  void _removeItem(String item) {
    setState(() {
      if (selectedItems[item] == 1) {
        selectedItems.remove(item);
      } else {
        selectedItems[item] = selectedItems[item]! - 1;
      }
    });
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
                _addItem(_otherItemController.text);
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
      body: Column(
        children: [
          CurrentLocationHeader(location: widget.currentLocation),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _availableItems.length,
                      itemBuilder: (context, index) {
                        final item = _availableItems[index];
                        final quantity = selectedItems[item] ?? 0;
                        final isSelected = quantity > 0;
                        final isOtherButton = item == 'Otro';

                        if (isOtherButton) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _showAddItemDialog,
                            child: const Text(
                              'Otro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          );
                        }

                        return Stack(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isSelected ? Colors.purple : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () => _addItem(item),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'x$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.white,
                                    onPressed: () => _removeItem(item),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Mostrar items personalizados
                  if (selectedItems.keys
                      .any((item) => !_availableItems.contains(item))) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Artículos personalizados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: selectedItems.entries
                          .where(
                              (entry) => !_availableItems.contains(entry.key))
                          .map((entry) => Chip(
                                label: Text('${entry.key} x${entry.value}'),
                                onDeleted: () {
                                  setState(() {
                                    selectedItems.remove(entry.key);
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
                            // Convertir el Map de items a una lista expandida
                            final expandedItems = selectedItems.entries
                                .expand((entry) =>
                                    List.filled(entry.value, entry.key))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentMethodScreen(
                                  selectedItems: expandedItems,
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
          ),
        ],
      ),
    );
  }
}
