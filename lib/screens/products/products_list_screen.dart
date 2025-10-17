// lib/screens/products/products_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _apiService.getProducts();
    });
  }

  void _navigateToForm({Map<String, dynamic>? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    ).then((_) {
      _refreshProducts();
    });
  }

  void _deleteProduct(int productId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este producto?'),
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
        bool success = await _apiService.deleteProduct(productId);
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Producto eliminado con éxito'),
                backgroundColor: Colors.green),
          );
          _refreshProducts();
        } else {
          throw Exception('Fallo la eliminación desde la API');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar producto: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshProducts),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron productos.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productId = product['product_id'];
              final imageUrl = product['product_image'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported))
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(product['product_name'] ?? 'Sin nombre'),
                  subtitle: Text('Precio: \$${product['product_price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (productId != null) {
                            _deleteProduct(productId);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToForm(product: product),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Agregar Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
