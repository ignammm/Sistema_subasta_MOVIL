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
  List<dynamic> subastas = [];
  List<dynamic> filteredSubastas = [];
  String searchName = '';
  String? selectedEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    fetchSubastas();
  }

  void fetchSubastas() async {
    try {
      var data = await apiService.fetchSubastas();
      setState(() {
        subastas = data;
        filteredSubastas = subastas;
      });
    } catch (error) {
      // Manejar errores de la API
    }
  }

  void filterSubastas() {
    setState(() {
      filteredSubastas = subastas.where((subasta) {
        final matchesName =
            subasta['nombre'].toLowerCase().contains(searchName.toLowerCase());
        final matchesEstado = selectedEstado == 'Todos' ||
            (selectedEstado == 'Abierta' && subasta['estado'] == true) ||
            (selectedEstado == 'Cerrada' &&
                subasta['estado'] == false &&
                DateTime.now()
                    .isBefore(DateTime.parse(subasta['fechaInicio']))) ||
            (selectedEstado == 'Finalizada' &&
                subasta['estado'] == false &&
                DateTime.now().isAfter(DateTime.parse(subasta['fechaFin'])));
        return matchesName && matchesEstado;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchName = value;
                  filterSubastas();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedEstado,
              hint: const Text('Filtrar por estado'),
              isExpanded: true,
              items: ['Todos', 'Abierta', 'Cerrada', 'Finalizada']
                  .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedEstado = value;
                  filterSubastas();
                });
              },
            ),
          ),
          Expanded(
            child: filteredSubastas.isEmpty
                ? const Center(child: Text('No hay subastas disponibles'))
                : ListView.builder(
                    itemCount: filteredSubastas.length,
                    itemBuilder: (context, index) {
                      var subasta = filteredSubastas[index];
                      var fechaFin = DateTime.parse(
                          subasta['fechaFin'].replaceFirst('T', ' '));
                      return Card(
                        child: ListTile(
                          title: Text(subasta['nombre']),
                          subtitle: Text(subasta['descripcion']),
                          trailing: (subasta['estado'] == false &&
                                  DateTime.now().isAfter(fechaFin))
                              ? const Text('Ver ganadores')
                              : Text(
                                  subasta['estado'] == true
                                      ? 'Abierta'
                                      : 'Cerrada',
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
                  ),
          ),
        ],
      ),
    );
  }
}
