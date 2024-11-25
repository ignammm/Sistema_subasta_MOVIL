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

  @override
  void initState() {
    super.initState();
    productosFuture = apiService.fetchProductosSubastaId(widget.idSubasta);
    subastaFuture = apiService.fetchSubastaId(widget.idSubasta);
  }

  Future<String> _calcularGanador(dynamic producto) async {
    try {
      // Obtén los detalles de la subasta
      final subasta = await subastaFuture;
      DateTime fechaFin = DateTime.parse(subasta['fechaFin']);

      // Verifica si la subasta ya terminó
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
      return "No recibio ninguna oferta.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos de la Subasta'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay productos en esta subasta'));
          } else {
            var productos = snapshot.data!
                .where((producto) => producto['estadoSolicitud'] == 'Aprobada')
                .toList();

            if (productos.isEmpty) {
              return const Center(
                  child: Text('No hay productos aprobados en esta subasta'));
            }

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                var producto = productos[index];
                return Card(
                  child: ListTile(
                    title: Text(producto['nombre']),
                    subtitle: FutureBuilder<String>(
                      future: _calcularGanador(producto),
                      builder: (context, ganadorSnapshot) {
                        if (ganadorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Calculando...");
                        } else if (ganadorSnapshot.hasError) {
                          return Text("Error: ${ganadorSnapshot.error}");
                        } else {
                          return Text(ganadorSnapshot.data ?? '');
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductoDetalleScreen(producto: producto),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
