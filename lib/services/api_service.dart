// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "143.198.118.203:8100";
  final String _user = "test";
  final String _pass = "test2023";

  Map<String, String> _getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}';
    return {
      'authorization': basicAuth,
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // --- MÉTODOS PARA PROVEEDORES ---

  Future<List<dynamic>> getProviders() async {
    print("\n--- Solicitando lista de proveedores... ---"); // NUEVO PRINT
    final response = await http.get(
      Uri.http(_baseUrl, 'ejemplos/provider_list_rest/'),
      headers: _getHeaders(),
    );

    // ================== PUNTO DE CONTROL (GET) ==================
    print('Respuesta de la API (Listar):');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    // ========================================================

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData =
          json.decode(utf8.decode(response.bodyBytes));
      final listKey = decodedData.keys
          .firstWhere((key) => decodedData[key] is List, orElse: () => '');
      if (listKey.isNotEmpty) {
        return decodedData[listKey] as List<dynamic>;
      } else {
        return [];
      }
    } else {
      throw Exception(
          'Fallo al cargar los proveedores. Código: ${response.statusCode}');
    }
  }

  Future<bool> addProvider(Map<String, dynamic> providerData) async {
    print("\n--- Intentando añadir un nuevo proveedor... ---"); // NUEVO PRINT
    print("Datos enviados: $providerData"); // NUEVO PRINT
    final response = await http.post(
      Uri.http(_baseUrl, 'ejemplos/provider_add_rest/'),
      headers: _getHeaders(),
      body: json.encode(providerData),
    );

    // ================== PUNTO DE CONTROL (ADD) ==================
    print('Respuesta de la API (Añadir):');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    // ========================================================

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ... (El resto de los métodos no necesitan cambios)
  Future<bool> editProvider(Map<String, dynamic> providerData) async {
    /* ... */ return true;
  }

  Future<bool> deleteProvider(int providerId) async {
    /* ... */ return true;
  }

  Future<List<dynamic>> getCategories() async {
    /* ... */ return [];
  }

  Future<bool> addCategory(Map<String, dynamic> categoryData) async {
    /* ... */ return true;
  }

  Future<bool> editCategory(Map<String, dynamic> categoryData) async {
    /* ... */ return true;
  }

  Future<bool> deleteCategory(int categoryId) async {
    /* ... */ return true;
  }

  Future<List<dynamic>> getProducts() async {
    /* ... */ return [];
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    /* ... */ return true;
  }

  Future<bool> editProduct(Map<String, dynamic> productData) async {
    /* ... */ return true;
  }

  Future<bool> deleteProduct(int productId) async {
    /* ... */ return true;
  }
}
