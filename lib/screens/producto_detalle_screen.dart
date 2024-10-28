import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_services.dart'; 

class ProductoDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ProductoDetalleScreen({Key? key, required this.producto})
      : super(key: key);

  @override
  _ProductoDetalleScreenState createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> ofertas = []; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfertas();
  }

  Future<void> _fetchOfertas() async {
    try {
      final fetchedOfertas =
          await apiService.fetchOfertasProductoId(widget.producto['id']);
      setState(() {
        ofertas = fetchedOfertas;
        isLoading = false;
      });
    } catch (e) {
      print("Error al obtener ofertas: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [];
    if (widget.producto['urls'] != null) {
      try {
        imageUrls = List<String>.from(json.decode(widget.producto['urls']));
      } catch (e) {
        print("Error decoding URLs: $e");
      }
    }

    String imageUrl = imageUrls.isNotEmpty
        ? "https://imagenesproducto.blob.core.windows.net/imagenes/${imageUrls[0]}"
        : "https://via.placeholder.com/150";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto['nombre']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Descripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.producto['descripcion'] ?? 'Sin descripción'),
            SizedBox(height: 10),
            Text(
              'Precio base: \$${widget.producto['precioBase'] ?? 'No disponible'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Image.network(imageUrl, height: 200),
            SizedBox(height: 20),
            SizedBox(height: 10),
            Text(
              'Ofertas recibidas: ${ofertas.length}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
