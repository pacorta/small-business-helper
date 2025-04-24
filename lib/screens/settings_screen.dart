import 'package:flutter/material.dart';
import '../../services/config_service.dart';
import 'config_editor_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  List<String> _items = [];
  List<String> _paymentMethods = [];
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    try {
      final items = await ConfigService.instance.getAvailableItems();
      final methods = await ConfigService.instance.getPaymentMethods();
      final locations = await ConfigService.instance.getLocations();

      setState(() {
        _items = items;
        _paymentMethods = methods;
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar configuraciones: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          _buildConfigSection(
            'Artículos Disponibles',
            _items,
            Icons.inventory,
            _editItems,
          ),
          _buildConfigSection(
            'Métodos de Pago',
            _paymentMethods,
            Icons.payment,
            _editPaymentMethods,
          ),
          _buildConfigSection(
            'Ubicaciones',
            _locations,
            Icons.location_on,
            _editLocations,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(
    String title,
    List<String> items,
    IconData icon,
    VoidCallback onEdit,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.purple),
            title: Text(title),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => Chip(
                        label: Text(item),
                        backgroundColor: Colors.purple.shade50,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editItems() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigEditorScreen(
          title: 'Editar Artículos',
          items: List.from(_items),
        ),
      ),
    );

    if (result != null) {
      // Actualizar en Firestore y refrescar la UI
      await ConfigService.instance.updateItems(result);
      ConfigService.instance.clearCache();
      _loadConfigurations();
    }
  }

  Future<void> _editPaymentMethods() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigEditorScreen(
          title: 'Editar Métodos de Pago',
          items: List.from(_paymentMethods),
        ),
      ),
    );

    if (result != null) {
      await ConfigService.instance.updatePaymentMethods(result);
      ConfigService.instance.clearCache();
      _loadConfigurations();
    }
  }

  Future<void> _editLocations() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigEditorScreen(
          title: 'Editar Ubicaciones',
          items: List.from(_locations),
        ),
      ),
    );

    if (result != null) {
      await ConfigService.instance.updateLocations(result);
      ConfigService.instance.clearCache();
      _loadConfigurations();
    }
  }
}
