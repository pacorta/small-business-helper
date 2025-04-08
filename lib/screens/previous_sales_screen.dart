import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';
import '../services/analytics_service.dart';
import '../widgets/sales_analytics_card.dart';
import '../widgets/sale_info_dialog.dart';
import '../widgets/date_range_selector.dart';

class PreviousSalesScreen extends StatefulWidget {
  const PreviousSalesScreen({super.key});

  @override
  State<PreviousSalesScreen> createState() => _PreviousSalesScreenState();
}

class _PreviousSalesScreenState extends State<PreviousSalesScreen> {
  List<Sale> allSales = [];
  String selectedPeriod = 'Todos';
  Set<String> selectedPaymentMethods = {'Todos'};
  Set<String> selectedLocations = {'Todos'};
  DateTimeRange? customDateRange;
  bool isLoading = true;
  Map<String, bool> expandedDays =
      {}; // Para controlar qué días están expandidos

  List<String> get _timeFilterOptions {
    final currentYear = DateTime.now().year;
    return [
      'Todos',
      'Hoy',
      'Esta semana',
      'Este mes',
      '${currentYear - 1}', // Año anterior
      '${currentYear.toString()} hasta hoy', // Año actual
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => isLoading = true);
    final sales = await SaleService.getAllSales();
    setState(() {
      allSales = sales;
      isLoading = false;
    });
  }

  List<Sale> _getFilteredSales() {
    List<Sale> filteredSales = List.from(allSales);
    final now = DateTime.now();

    if (selectedPeriod != 'Todos') {
      switch (selectedPeriod) {
        case 'Hoy':
          filteredSales = filteredSales.where((sale) {
            return sale.timestamp.year == now.year &&
                sale.timestamp.month == now.month &&
                sale.timestamp.day == now.day;
          }).toList();
          break;
        case 'Esta semana':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          filteredSales = filteredSales
              .where((sale) => sale.timestamp.isAfter(weekStart))
              .toList();
          break;
        case 'Este mes':
          filteredSales = filteredSales.where((sale) {
            return sale.timestamp.year == now.year &&
                sale.timestamp.month == now.month;
          }).toList();
          break;
        default:
          // Manejo dinámico de años
          final selectedYear = int.tryParse(selectedPeriod);
          if (selectedYear != null) {
            final startDate = DateTime(selectedYear, 1, 1);
            final endDate = selectedYear == now.year
                ? now // Si es el año actual, hasta hoy
                : DateTime(selectedYear, 12, 31, 23, 59,
                    59); // Si es año anterior, hasta fin de año

            filteredSales = filteredSales.where((sale) {
              return sale.timestamp.isAfter(startDate) &&
                  sale.timestamp.isBefore(endDate);
            }).toList();
          }
          break;
      }
    }

    if (!selectedPaymentMethods.contains('Todos')) {
      filteredSales = filteredSales
          .where((sale) => selectedPaymentMethods.contains(sale.paymentMethod))
          .toList();
    }

    if (!selectedLocations.contains('Todos')) {
      filteredSales = filteredSales
          .where((sale) => selectedLocations.contains(sale.location))
          .toList();
    }

    return filteredSales;
  }

  List<String> _getAvailablePaymentMethods() {
    return allSales.map((sale) => sale.paymentMethod).toSet().toList();
  }

  Future<void> _showDateRangePicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: DateRangeSelector(
            initialDateRange: customDateRange,
            onDateRangeSelected: (range) {
              setState(() {
                customDateRange = range;
                selectedPeriod = 'Rango';
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeFilterOptions.map((period) {
                    return FilterChip(
                      selected: selectedPeriod == period,
                      label: Text(period),
                      onSelected: (selected) {
                        setState(() {
                          selectedPeriod = selected ? period : 'Todos';
                        });
                        this.setState(() {});
                      },
                    );
                  }).toList(),
                ),
                _buildFilterSection(
                  'Método de pago',
                  _getAvailablePaymentMethods().map((method) {
                    return FilterChip(
                      selected: selectedPaymentMethods.contains(method),
                      label: Text(method),
                      onSelected: (selected) {
                        setState(() {
                          _toggleFilter(selectedPaymentMethods, method);
                        });
                        this.setState(() {});
                      },
                    );
                  }).toList(),
                ),
                _buildFilterSection(
                  'Ubicación',
                  _getUniqueLocations().map((location) {
                    return FilterChip(
                      selected: selectedLocations.contains(location),
                      label: Text(location),
                      onSelected: (selected) {
                        setState(() {
                          _toggleFilter(selectedLocations, location);
                        });
                        this.setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Set<String> _getUniqueLocations() {
    final locations = {'Todos'};
    locations.addAll(allSales.map((sale) => sale.location));
    return locations;
  }

  void _toggleFilter(Set<String> filterSet, String value) {
    if (value == 'Todos') {
      filterSet.clear();
      filterSet.add('Todos');
    } else {
      filterSet.remove('Todos');
      if (filterSet.contains(value)) {
        filterSet.remove(value);
        if (filterSet.isEmpty) {
          filterSet.add('Todos');
        }
      } else {
        filterSet.add(value);
      }
    }
  }

  // Nuevo método para calcular el total de ventas filtradas
  double _getFilteredTotal() {
    return _getFilteredSales().fold(0, (sum, sale) => sum + sale.price);
  }

  String _getActiveFiltersDescription() {
    List<String> filters = [];

    if (selectedPeriod == 'Fechas personalizadas' && customDateRange != null) {
      final DateFormat formatter = DateFormat('d/M/y');
      filters.add(
          '${formatter.format(customDateRange!.start)} - ${formatter.format(customDateRange!.end)}');
    } else if (selectedPeriod != 'Todos') {
      filters.add(selectedPeriod);
    }

    if (!selectedPaymentMethods.contains('Todos')) {
      filters.add(selectedPaymentMethods.join(', '));
    }

    if (!selectedLocations.contains('Todos')) {
      filters.add(selectedLocations.join(', '));
    }

    if (filters.isEmpty) {
      return '';
    }

    return 'Mostrando: ${filters.join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Primero las ventas agrupadas por día
                _buildSalesList(),
                // Después el resumen
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SalesAnalyticsCard(
                    analytics: AnalyticsService.calculateAnalytics(
                      _getFilteredSales(),
                    ),
                    activeFilters: _getActiveFiltersDescription(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _buildSalesList() {
    // Agrupar ventas por día
    final salesByDay = groupBy(
      _getFilteredSales(),
      (Sale sale) => DateFormat('yyyy-MM-dd').format(sale.timestamp),
    );

    return Column(
      children: salesByDay.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        final sales = entry.value;
        final totalForDay = sales.fold<double>(
          0,
          (sum, sale) => sum + sale.price,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Encabezado del día (siempre visible)
              InkWell(
                onTap: () {
                  setState(() {
                    expandedDays[entry.key] =
                        !(expandedDays[entry.key] ?? false);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('d/M/yyyy').format(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${totalForDay.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expandedDays[entry.key] ?? false
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
              // Ventas del día (expandibles)
              if (expandedDays[entry.key] ?? false)
                Column(
                  children: sales.map((sale) => _buildSaleItem(sale)).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaleItem(Sale sale) {
    return InkWell(
      onTap: () => _showSaleDetails(sale),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              DateFormat('HH:mm').format(sale.timestamp),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.purple.shade300,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                sale.location,
                style: TextStyle(color: Colors.purple.shade700),
              ),
            ),
            Text(
              '\$${sale.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => SaleInfoDialog(sale: sale),
    );
  }

  Future<void> _updateSalesForDateRange(DateTimeRange range) async {
    final salesInRange = await SaleService.getSalesByDateRange(range);
    setState(() {
      allSales = salesInRange;
      selectedPeriod = 'Rango';
      customDateRange = range;
    });
  }
}
