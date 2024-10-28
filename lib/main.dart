import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_services.dart';
import 'screens/productos_subasta_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El Mejor Postor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Subastas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: apiService.fetchSubastas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('No hay subastas disponibles'));
          } else {
            var subastas = snapshot.data as List;
            return ListView.builder(
              itemCount: subastas.length,
              itemBuilder: (context, index) {
                var subasta = subastas[index];
                var fechaFin = DateTime.parse(subasta['fechaFin'].replaceFirst('T', ' '));
                return Card(
                  child: ListTile(
                    title: Text(subasta['nombre']),
                    subtitle: Text(subasta['descripcion']),
                    trailing: (subasta['estado'] == false &&
                            DateTime.now().isAfter(fechaFin))
                        ? Text('Ver ganadores')
                        : Text(
                            subasta['estado'] == true ? 'Abierta' : 'Cerrada',
                            style: TextStyle(
                              color: subasta['estado'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductosScreen(idSubasta: subasta['id']),
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
