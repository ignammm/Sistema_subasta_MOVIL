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

  @override
  void initState() {
    super.initState();
    productosFuture = apiService.fetchProductosSubastaId(widget.idSubasta);
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
                    subtitle: Text(producto['descripcion']),
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
