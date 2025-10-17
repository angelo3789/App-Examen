// lib/screens/categories/categories_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'category_form_screen.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _apiService.getCategories();
    });
  }

  void _navigateToForm({Map<String, dynamic>? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    ).then((_) {
      _refreshCategories();
    });
  }

  void _deleteCategory(int categoryId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar')),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        bool success = await _apiService.deleteCategory(categoryId);
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Categoría eliminada con éxito'),
                backgroundColor: Colors.green),
          );
          _refreshCategories();
        } else {
          throw Exception('Fallo la eliminación desde la API');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar categoría: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshCategories),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron categorías.'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryId = category['category_id'];
              final categoryName = category['category_name'] ?? 'Sin nombre';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(
                          categoryName.isNotEmpty ? categoryName[0] : '?')),
                  title: Text(categoryName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (categoryId != null) {
                            _deleteCategory(categoryId);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToForm(category: category),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Agregar Categoría',
        child: const Icon(Icons.add),
      ),
    );
  }
}
