import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:5046/api';

  Future<dynamic> fetchSubastas() async {
    final url = Uri.parse('$baseUrl/Subastas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Error al obtener las Suabastas');
    }
  }

  Future<List<dynamic>> fetchProductosSubastaId(int idSubasta) async {
    final url = Uri.parse('$baseUrl/Productos/subasta/$idSubasta');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body)
          as List<dynamic>; 
    } else {
      throw Exception('Error al obtener los productos de la subasta');
    }
  }

  Future<dynamic> fetchProdudctoId(int idProducto) async {
    final url = Uri.parse('$baseUrl/Productos/$idProducto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el producto por el id');
    }
  }

  Future<List<dynamic>> fetchOfertasProductoId(int idProducto) async {
    final url = Uri.parse('$baseUrl/Ofertas/producto/$idProducto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener las ofertas por el idProducto');
    }
  }

  Future<dynamic> fetchUsuarioId(int idUsuario) async {
    final url = Uri.parse('$baseUrl/Ofertas/producto/$idUsuario');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el Usuario por el idUsuario');
    }
  }
  
}
