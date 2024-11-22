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
  dynamic subasta = {};
  String ganadorTexto = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchOfertas(),
      _fetchSubasta(),
    ]);
    _calcularGanador();
  }

  Future<void> _fetchOfertas() async {
    try {
      final fetchedOfertas =
          await apiService.fetchOfertasProductoId(widget.producto['id']);
      setState(() {
        ofertas = fetchedOfertas;
      });
    } catch (e) {
      print("Error al obtener ofertas: $e");
    }
  }

  Future<void> _fetchSubasta() async {
    try {
      final fetchedSubasta =
          await apiService.fetchSubastaId(widget.producto['subastaId']);
      setState(() {
        subasta = fetchedSubasta;
      });
    } catch (e) {
      print("Error al obtener la subasta: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> _fetchUsuario(int idUsuario) async {
    try {
      final fetchedUsuario = await apiService.fetchUsuarioId(idUsuario);
      return fetchedUsuario;
    } catch (e) {
      print("Error al obtener el usuario: $e");
      return null;
    }
  }

  Future<void> _calcularGanador() async {
    if (subasta.isNotEmpty &&
        DateTime.parse(subasta['fechaFin']).isBefore(DateTime.now())) {
      if (ofertas.isNotEmpty) {
        final mejorOferta =
            ofertas.reduce((a, b) => a['monto'] > b['monto'] ? a : b);
        try {
          final usuario = await _fetchUsuario(mejorOferta['idUsuario']);
          setState(() {
            ganadorTexto =
                "Ganador: ${usuario['nombre']} ${usuario['apellido']}, con una oferta de \$${mejorOferta['monto']}";
          });
        } catch (e) {
          print("Error al obtener el ganador: $e");
        }
      } else {
        setState(() {
          ganadorTexto = "No hubo ofertas para este producto.";
        });
      }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                  Text(
                    'Ofertas recibidas: ${ofertas.length}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (ganadorTexto.isNotEmpty)
                    Text(
                      ganadorTexto,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
    );
  }
}
