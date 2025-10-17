// lib/screens/providers/providers_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'provider_form_screen.dart';

class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({super.key});

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _refreshProviders();
  }

  void _refreshProviders() {
    setState(() {
      _providersFuture = _apiService.getProviders();
    });
  }

  void _navigateToForm({Map<String, dynamic>? provider}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderFormScreen(provider: provider),
      ),
    ).then((_) {
      _refreshProviders();
    });
  }

  void _deleteProvider(int providerId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este proveedor?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        bool success = await _apiService.deleteProvider(providerId);
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Proveedor eliminado con éxito'),
                backgroundColor: Colors.green),
          );
          _refreshProviders();
        } else {
          throw Exception('Fallo la eliminación desde la API');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar proveedor: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProviders,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron proveedores.'));
          }

          final providers = snapshot.data!;
          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(provider['provider_name'][0]),
                  ),
                  title: Text(provider['provider_name']),
                  subtitle: Text(provider['provider_mail']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _navigateToForm(provider: provider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // LA CORRECCIÓN ESTÁ AQUÍ: Usamos 'providerid'
                          final providerId = provider['providerid'];
                          if (providerId != null) {
                            _deleteProvider(providerId);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _navigateToForm(provider: provider);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToForm();
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar Proveedor',
      ),
    );
  }
}
