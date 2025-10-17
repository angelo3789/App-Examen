// lib/screens/products/product_form_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  String _currentState = 'Activo';

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null;

    _nameController = TextEditingController(
        text: _isEditMode ? widget.product!['product_name'] : '');
    _priceController = TextEditingController(
        text: _isEditMode ? widget.product!['product_price'].toString() : '');
    _imageController = TextEditingController(
        text: _isEditMode ? widget.product!['product_image'] : '');

    if (_isEditMode) {
      _currentState = widget.product!['product_state'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> productData = {
        'product_name': _nameController.text,
        'product_price': int.tryParse(_priceController.text) ?? 0,
        'product_image': _imageController.text,
      };

      try {
        bool success;
        if (_isEditMode) {
          productData['product_id'] = widget.product!['product_id'];
          productData['product_state'] = _currentState;
          success = await _apiService.editProduct(productData);
        } else {
          success = await _apiService.addProduct(productData);
        }

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Producto ${_isEditMode ? 'actualizado' : 'agregado'} con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          throw Exception('La operación en la API no fue exitosa.');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar producto: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Producto' : 'Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingrese un nombre'
                    : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese un precio';
                  if (int.tryParse(value) == null)
                    return 'Ingrese un número válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration:
                    const InputDecoration(labelText: 'URL de la Imagen'),
                keyboardType: TextInputType.url,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Ingrese una URL' : null,
              ),
              if (_isEditMode)
                DropdownButtonFormField<String>(
                  value: _currentState,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: ['Activo', 'Inactivo']
                      .map((label) =>
                          DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentState = value!;
                    });
                  },
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
