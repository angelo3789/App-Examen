// lib/screens/categories/category_form_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CategoryFormScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  String _currentState = 'Activa';

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.category != null;

    _nameController = TextEditingController(
        text: _isEditMode ? widget.category!['category_name'] : '');

    if (_isEditMode) {
      _currentState = widget.category!['category_state'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> categoryData = {
        'category_name': _nameController.text,
      };

      try {
        bool success;
        if (_isEditMode) {
          categoryData['category_id'] = widget.category!['category_id'];
          categoryData['category_state'] = _currentState;
          success = await _apiService.editCategory(categoryData);
        } else {
          success = await _apiService.addCategory(categoryData);
        }

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Categoría ${_isEditMode ? 'actualizada' : 'agregada'} con éxito'),
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
              content: Text('Error al guardar categoría: $e'),
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
        title: Text(_isEditMode ? 'Editar Categoría' : 'Agregar Categoría'),
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
                    const InputDecoration(labelText: 'Nombre de la Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              if (_isEditMode)
                DropdownButtonFormField<String>(
                  value: _currentState,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: ['Activa', 'Inactiva']
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
