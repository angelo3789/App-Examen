// lib/screens/providers/provider_form_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProviderFormScreen extends StatefulWidget {
  final Map<String, dynamic>? provider;

  const ProviderFormScreen({super.key, this.provider});

  @override
  State<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends State<ProviderFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mailController;
  String _currentState = 'Activo';

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.provider != null;

    _nameController = TextEditingController(
        text: _isEditMode ? widget.provider!['provider_name'] : '');
    _lastNameController = TextEditingController(
        text: _isEditMode ? widget.provider!['provider_last_name'] : '');
    _mailController = TextEditingController(
        text: _isEditMode ? widget.provider!['provider_mail'] : '');

    if (_isEditMode) {
      _currentState = widget.provider!['provider_state'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> providerData = {
        'provider_name': _nameController.text,
        'provider_last_name': _lastNameController.text,
        'provider_mail': _mailController.text,
        'provider_state': _currentState,
      };

      try {
        bool success;
        if (_isEditMode) {
          // LA CORRECCIÓN ESTÁ AQUÍ: Usamos 'providerid'
          providerData['provider_id'] = widget.provider!['providerid'];

          success = await _apiService.editProvider(providerData);
        } else {
          success = await _apiService.addProvider(providerData);
        }

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Proveedor ${_isEditMode ? 'actualizado' : 'agregado'} con éxito'),
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
            content: Text('Error al guardar proveedor: $e'),
            backgroundColor: Colors.red,
          ),
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
    // ... el resto del archivo es idéntico ...
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Proveedor' : 'Agregar Proveedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un apellido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, ingrese un correo válido';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _currentState,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['Activo', 'Inactivo']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
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
                      onPressed: _submitForm,
                      child: const Text('Guardar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
