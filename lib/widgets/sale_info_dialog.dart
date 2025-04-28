import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';
import 'package:intl/intl.dart';
import '../services/config_service.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

// TODO: Considerar refactorizar para seguir el principio DRY
// Posibles mejoras futuras:
// 1. Crear un widget _buildFormSection para estandarizar el espaciado y estructura
// 2. Unificar el estilo de los campos de entrada
// 3. Mejorar la gestión de estado para reducir reconstrucciones innecesarias

// NOTA: El espaciado actual entre elementos se maneja con SizedBox
// Se podría mejorar con una solución más mantenible en el futuro

class SaleInfoDialog extends StatefulWidget {
  final Sale sale;

  const SaleInfoDialog({
    super.key,
    required this.sale,
  });

  @override
  State<SaleInfoDialog> createState() => _SaleInfoDialogState();
}

class _SaleInfoDialogState extends State<SaleInfoDialog> {
  bool _isEditing = false;
  late TextEditingController _clientController;
  late TextEditingController _commentController;
  late String _selectedPaymentMethod;
  late String _selectedLocation;
  late List<String> _selectedItems;
  bool _hasChanges = false;
  DateTime? _selectedDate;
  late TextEditingController _priceController;
  final ScrollController _scrollController = ScrollController();
  late double _lastScrollOffset = 0;

  final List<String> _paymentMethods = ['Efectivo', 'Tarjeta', 'Transferencia'];
  final List<String> _locations = ['Farmers Market', 'Tienda', 'Otro'];
  final List<String> _availableItems = [
    'Collar',
    'Pulsera',
    'Aretes',
    'Anillo'
  ];

  @override
  void initState() {
    super.initState();
    _resetControllers();
    _scrollController.addListener(() {
      _lastScrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetControllers() {
    _clientController = TextEditingController(text: widget.sale.client);
    _commentController = TextEditingController(text: widget.sale.comment);
    _selectedPaymentMethod = _paymentMethods.contains(widget.sale.paymentMethod)
        ? widget.sale.paymentMethod
        : _paymentMethods[0];
    _selectedLocation = widget.sale.location;
    _selectedItems = List.from(widget.sale.items);
    _selectedDate = widget.sale.timestamp;
    _priceController =
        TextEditingController(text: widget.sale.price.toStringAsFixed(2));
  }

  void _showItemSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Artículo'),
        content: Wrap(
          spacing: 8,
          children: _availableItems
              .map((item) => ActionChip(
                    label: Text(item),
                    onPressed: () {
                      setState(() {
                        _selectedItems.add(item);
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

// NOTA: Los selectores de método de pago y ubicación comparten mucha lógica
// Potencial para refactorización en un widget común, ejemplo:
  //Widget _buildDropdownSelector({
  //  required Future<List<String>> Function() getFuture,
  //  required String value,
  //  required String label,
  //  required Function(String) onChanged,
  //}) {
  //  // Lógica común aquí
  //}

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButton2<String>(
      value: value,
      hint: Text(label),
      isExpanded: true,
      buttonStyleData: ButtonStyleData(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: _isEditing ? onChanged : null,
    );
  }

  Widget _buildPaymentMethodSelector() {
    return FutureBuilder<List<String>>(
      future: ConfigService.instance.getPaymentMethods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final paymentMethods = snapshot.data ?? [];
        if (!paymentMethods.contains(_selectedPaymentMethod)) {
          paymentMethods.add(_selectedPaymentMethod);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdownField(
              value: _selectedPaymentMethod,
              items: paymentMethods,
              label: 'Seleccionar método de pago',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                    _hasChanges = true;
                  });
                }
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildLocationSelector() {
    return FutureBuilder<List<String>>(
      future: ConfigService.instance.getLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final locations = snapshot.data ?? [];
        if (!locations.contains(_selectedLocation)) {
          locations.add(_selectedLocation);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDropdownField(
              value: _selectedLocation,
              items: locations,
              label: 'Seleccionar ubicación',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLocation = value;
                    _hasChanges = true;
                  });
                }
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_isEditing)
          InkWell(
            onTap: () async {
              final dates = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: Colors.purple,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  currentDate: _selectedDate ?? widget.sale.timestamp,
                  centerAlignModePicker: true,
                  customModePickerIcon: const SizedBox(),
                  selectedDayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dayTextStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                dialogSize: const Size(325, 400),
                value: [_selectedDate ?? widget.sale.timestamp],
              );

              if (dates != null && dates.isNotEmpty) {
                // Una vez seleccionada la fecha, mostramos el selector de hora
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    DateTime _dateTime = _selectedDate ?? widget.sale.timestamp;
                    return AlertDialog(
                      title: const Text('Seleccionar hora'),
                      content: TimePickerSpinner(
                        is24HourMode: false,
                        normalTextStyle: const TextStyle(
                            fontSize: 20, color: Colors.black54),
                        highlightedTextStyle:
                            const TextStyle(fontSize: 24, color: Colors.purple),
                        spacing: 50,
                        itemHeight: 40,
                        isForce2Digits: true,
                        onTimeChange: (time) {
                          _dateTime = time;
                        },
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Aceptar'),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(
                                dates[0]!.year,
                                dates[0]!.month,
                                dates[0]!.day,
                                _dateTime.hour,
                                _dateTime.minute,
                              );
                              _hasChanges = true;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(_selectedDate ?? widget.sale.timestamp),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.calendar_today,
                      size: 20, color: Colors.grey.shade600),
                ],
              ),
            ),
          )
        else
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(widget.sale.timestamp),
            style: const TextStyle(fontSize: 16),
          ),
        const Divider(),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
        if (_isEditing)
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _hasChanges = true;
                });
              }
            },
          )
        else
          Text(
            '\$${widget.sale.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        const Divider(),
      ],
    );
  }

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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Detalles'),
              leading: const Icon(Icons.receipt_long),
              actions: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.edit : Icons.edit_outlined),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Cerrar el diálogo completamente
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campos no editables/editables según _isEditing
                      _isEditing
                          ? _buildDateField()
                          : _buildInfoSection('Fecha',
                              '${widget.sale.timestamp.day}/${widget.sale.timestamp.month}/${widget.sale.timestamp.year}'),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildItemsSection()
                          : _buildInfoSection(
                              'Artículos', _formatItems(widget.sale.items)),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildPaymentMethodSelector()
                          : _buildInfoSection(
                              'Método de Pago', widget.sale.paymentMethod),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildLocationSelector()
                          : _buildInfoSection(
                              'Ubicación', widget.sale.location),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildEditableField('Cliente', _clientController)
                          : _buildInfoSection(
                              'Cliente', widget.sale.client ?? 'Sin cliente'),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildEditableField(
                              'Comentario', _commentController, maxLines: 3)
                          : _buildInfoSection('Comentario',
                              widget.sale.comment ?? 'Sin comentario'),
                      const SizedBox(height: 16),

                      _isEditing
                          ? _buildPriceField()
                          : _buildInfoSection('Total',
                              '\$${widget.sale.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ),
            // Botón de guardar cuando está en modo edición
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _hasChanges ? _saveSale : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Restaurar la posición del scroll después de setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_lastScrollOffset);
      }
    });
  }

  List<Widget> _buildDialogActions() {
    if (_isEditing) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _isEditing = false;
              _resetControllers();
            });
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _hasChanges ? _saveSale : null,
          child: const Text('Guardar'),
        ),
      ];
    }
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cerrar'),
      ),
    ];
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

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onChanged: (value) {
              setState(() {
                _hasChanges = true;
              });
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return FutureBuilder<List<String>>(
      future: ConfigService.instance.getAvailableItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final availableItems = snapshot.data ?? [];
        final Map<String, int> itemCount = {};

        for (var item in _selectedItems) {
          itemCount[item] = (itemCount[item] ?? 0) + 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artículos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: itemCount.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key} (${entry.value})'),
                  backgroundColor: Colors.purple.shade50,
                  deleteIcon: _isEditing ? const Icon(Icons.close) : null,
                  onDeleted: _isEditing
                      ? () {
                          setState(() {
                            _selectedItems
                                .removeWhere((item) => item == entry.key);
                            _hasChanges = true;
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              _buildDropdownField(
                value: availableItems.isNotEmpty ? availableItems.first : '',
                items: availableItems,
                label: 'Agregar artículo',
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedItems.add(value);
                      _hasChanges = true;
                    });
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _saveSale() async {
    final updatedSale = Sale(
      id: widget.sale.id,
      timestamp: _selectedDate ?? widget.sale.timestamp,
      items: _selectedItems,
      paymentMethod: _selectedPaymentMethod,
      price: double.tryParse(_priceController.text) ?? widget.sale.price,
      location: _selectedLocation,
      client: _clientController.text.isEmpty ? null : _clientController.text,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
      sellerEmail: widget.sale.sellerEmail,
      sellerName: widget.sale.sellerName,
    );

    try {
      await SaleService.updateSale(updatedSale);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }
}
