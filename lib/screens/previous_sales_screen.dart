import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';
import '../services/analytics_service.dart';
import '../widgets/sales_analytics_card.dart';
import '../widgets/sale_info_dialog.dart';

class PreviousSalesScreen extends StatefulWidget {
  const PreviousSalesScreen({super.key});

  @override
  State<PreviousSalesScreen> createState() => _PreviousSalesScreenState();
}

class _PreviousSalesScreenState extends State<PreviousSalesScreen> {
  List<Sale> _sales = [];
  bool _isLoading = true;
  String? _selectedPaymentMethod;
  String _timeFilter = 'Todos';

  final List<String> _timeFilterOptions = [
    'Todos',
    'Hoy',
    'Esta semana',
    'Este mes',
  ];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final sales = await SaleService.getAllSales();
    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  List<Sale> _getFilteredSales() {
    var filteredSales = _sales;

    final now = DateTime.now();
    switch (_timeFilter) {
      case 'Hoy':
        filteredSales = filteredSales.where((sale) {
          return sale.timestamp.year == now.year &&
              sale.timestamp.month == now.month &&
              sale.timestamp.day == now.day;
        }).toList();
      case 'Esta semana':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filteredSales = filteredSales.where((sale) {
          return sale.timestamp.isAfter(weekStart);
        }).toList();
      case 'Este mes':
        filteredSales = filteredSales.where((sale) {
          return sale.timestamp.year == now.year &&
              sale.timestamp.month == now.month;
        }).toList();
    }

    if (_selectedPaymentMethod != null) {
      filteredSales = filteredSales
          .where((sale) => sale.paymentMethod == _selectedPaymentMethod)
          .toList();
    }

    return filteredSales;
  }

  List<String> _getAvailablePaymentMethods() {
    return _sales.map((sale) => sale.paymentMethod).toSet().toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Período',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _timeFilterOptions.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _timeFilter == filter,
                            onSelected: (selected) {
                              setModalState(() {
                                setState(() {
                                  _timeFilter = selected ? filter : 'Todos';
                                });
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Método de pago',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Todos'),
                          selected: _selectedPaymentMethod == null,
                          onSelected: (selected) {
                            setModalState(() {
                              setState(() {
                                _selectedPaymentMethod = null;
                              });
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ..._getAvailablePaymentMethods().map((method) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(method),
                              selected: _selectedPaymentMethod == method,
                              onSelected: (selected) {
                                setModalState(() {
                                  setState(() {
                                    _selectedPaymentMethod =
                                        selected ? method : null;
                                  });
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Nuevo método para calcular el total de ventas filtradas
  double _getFilteredTotal() {
    return _getFilteredSales().fold(0, (sum, sale) => sum + sale.price);
  }

  @override
  Widget build(BuildContext context) {
    final filteredSales = _getFilteredSales();
    final totalAmount = _getFilteredTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Anteriores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: Column(
        children: [
          // Añadir el widget de análisis al principio
          if (!_isLoading && _sales.isNotEmpty)
            SalesAnalyticsCard(
              analytics: AnalyticsService.calculateAnalytics(filteredSales),
            ),
          // Mostrar chips de filtros activos y total
          if (_timeFilter != 'Todos' || _selectedPaymentMethod != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_timeFilter != 'Todos')
                        Chip(
                          label: Text(_timeFilter),
                          onDeleted: () {
                            setState(() {
                              _timeFilter = 'Todos';
                            });
                          },
                        ),
                      if (_selectedPaymentMethod != null)
                        Chip(
                          label: Text(_selectedPaymentMethod!),
                          onDeleted: () {
                            setState(() {
                              _selectedPaymentMethod = null;
                            });
                          },
                        ),
                    ],
                  ),
                  // Mostrar el total de ventas filtradas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total${_timeFilter != 'Todos' ? ' - ${_timeFilter.toLowerCase()}' : ''}'
                          '${_selectedPaymentMethod != null ? ' (${_selectedPaymentMethod})' : ''}:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredSales.length} venta${filteredSales.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Lista de ventas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSales.isEmpty
                    ? const Center(
                        child:
                            Text('No hay ventas que coincidan con los filtros'),
                      )
                    : ListView.builder(
                        itemCount: _groupSalesByDay().length,
                        itemBuilder: (context, index) {
                          final daySales =
                              _groupSalesByDay().values.elementAt(index);
                          final date = _groupSalesByDay().keys.elementAt(index);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: daySales.length,
                                itemBuilder: (context, index) {
                                  final sale = daySales[index];
                                  return _buildSaleCard(sale);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Total del día: \$${_getDayTotal(daySales).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Sale>> _groupSalesByDay() {
    final Map<String, List<Sale>> grouped = {};

    for (var sale in _getFilteredSales()) {
      final date = _formatDate(sale.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(sale);
    }

    return grouped;
  }

  double _getDayTotal(List<Sale> daySales) {
    return daySales.fold(0, (sum, sale) => sum + sale.price);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Hora
        leading: Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            '${sale.timestamp.hour}:${sale.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
        // Ubicación
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.purple.shade300,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                sale.location,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Precio e ícono de info
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${sale.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.purple,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SaleInfoDialog(sale: sale),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
