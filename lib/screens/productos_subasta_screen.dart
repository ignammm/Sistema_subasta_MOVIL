import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'producto_detalle_screen.dart';

class ProductosScreen extends StatefulWidget {
  final int idSubasta;

  const ProductosScreen({Key? key, required this.idSubasta}) : super(key: key);

  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> productosFuture;
  late Future<dynamic> subastaFuture;
  final TextEditingController searchController = TextEditingController();
  List<dynamic> productos = [];
  List<dynamic> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    productosFuture = apiService.fetchProductosSubastaId(widget.idSubasta);
    subastaFuture = apiService.fetchSubastaId(widget.idSubasta);

    // Cargar productos al inicializar
    productosFuture.then((data) {
      setState(() {
        productos = data
            .where((producto) => producto['estadoSolicitud'] == 'Aprobada')
            .toList();
        productosFiltrados = List.from(productos); // Copiar la lista
      });
    });
  }

  void _filtrarProductos(String query) {
    setState(() {
      productosFiltrados = productos
          .where((producto) =>
              producto['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<String> _calcularGanador(dynamic producto) async {
    try {
      final subasta = await subastaFuture;
      DateTime fechaFin = DateTime.parse(subasta['fechaFin']);

      if (DateTime.now().isAfter(fechaFin)) {
        final ofertas = await apiService.fetchOfertasProductoId(producto['id']);
        if (ofertas.isNotEmpty) {
          final mejorOferta =
              ofertas.reduce((a, b) => a['monto'] > b['monto'] ? a : b);
          final usuario =
              await apiService.fetchUsuarioId(mejorOferta['idUsuario']);
          return "Ganador: ${usuario['nombre']} ${usuario['apellido']}, "
              "con una oferta de \$${mejorOferta['monto']}";
        } else {
          return "No hubo ofertas para este producto.";
        }
      } else {
        return "${producto['nombre']}: ${producto['descripcion']}";
      }
    } catch (e) {
      return "No recibió ninguna oferta.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos de la Subasta'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filtrarProductos,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: productosFiltrados.isEmpty
          ? const Center(child: Text('No hay productos que coincidan'))
          : ListView.builder(
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                var producto = productosFiltrados[index];

                List<String> imageUrls = [];
                if (producto['urls'] != null) {
                  try {
                    imageUrls =
                        List<String>.from(json.decode(producto['urls']));
                  } catch (e) {
                    print("Error decoding URLs: $e");
                  }
                }

                String imageUrl = imageUrls.isNotEmpty
                    ? "https://imagenesproducto.blob.core.windows.net/imagenes/${imageUrls[0]}"
                    : "https://via.placeholder.com/150";

                bool isHovered = false;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Card(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isHovered = true),
                        onExit: (_) => setState(() => isHovered = false),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductoDetalleScreen(
                                                producto: producto),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                          Icons.image_not_supported,
                                          size: 200);
                                    },
                                  ),
                                ),
                                if (isHovered)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                              ],
                            ),
                            ListTile(
                              title: Text(producto['nombre']),
                              subtitle: FutureBuilder<String>(
                                future: _calcularGanador(producto),
                                builder: (context, ganadorSnapshot) {
                                  if (ganadorSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("Calculando...");
                                  } else if (ganadorSnapshot.hasError) {
                                    return Text(
                                        "Error: ${ganadorSnapshot.error}");
                                  } else {
                                    return Text(ganadorSnapshot.data ?? '');
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductoDetalleScreen(
                                        producto: producto),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
