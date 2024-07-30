import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlite/db/database.dart';
import '../planetas/planetas.dart';

class PlanetaService {
  Future<void> agregarPlaneta(Planetas planeta) async {
    try {
      await DB.insertPlanet(planeta);
    } catch (e) {
      print('Error al agregar planeta: $e');
    }
  }

  Future<void> actualizarPlaneta(Planetas planeta) async {
    try {
      await DB.updatePlanet(planeta);
    } catch (e) {
      print('Error al actualizar planeta: $e');
    }
  }

  Future<void> eliminarPlaneta(int id) async {
    try {
      await DB.deletePlanet(id);
    } catch (e) {
      print('Error al eliminar planeta: $e');
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Planetas> planetList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _distanceFromSunController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  int? _currentId;

  @override
  void initState() {
    super.initState();
    _loadPlanets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SQLite Planetas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _buildForm() {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.grey[300]),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _distanceFromSunController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Distancia al Sol',
                labelStyle: TextStyle(color: Colors.grey[300]),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _radiusController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Radio',
                labelStyle: TextStyle(color: Colors.grey[300]),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentId == null ? _addPlanet : _updatePlanet,
                  child: Text(_currentId == null ? 'Agregar' : 'Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentId == null ? Colors.green : Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (_currentId != null)
                  ElevatedButton(
                    onPressed: _cancelEdit,
                    child: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return planetList.isEmpty
        ? const Center(
      child: CircularProgressIndicator(
        color: Colors.blueGrey,
      ),
    )
        : ListView.builder(
      itemCount: planetList.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[800],
          child: ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text(
              "Nombre: ${planetList[index].nombre}",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Radio: ${planetList[index].radio}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePlanet(planetList[index].id!),
            ),
            onTap: () => _editPlanet(planetList[index]),
          ),
        );
      },
    );
  }

  Future<void> _loadPlanets() async {
    planetList = await DB.getPlanets();
    setState(() {});
  }

  Future<void> _addPlanet() async {
    if (_nameController.text.isEmpty ||
        _distanceFromSunController.text.isEmpty ||
        _radiusController.text.isEmpty) {
      _showErrorDialog('Error', 'Por favor, complete todos los campos');
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(_distanceFromSunController.text)) {
      _showErrorDialog('Error', 'La distancia al Sol debe ser un número decimal');
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(_radiusController.text)) {
      _showErrorDialog('Error', 'El radio debe ser un número decimal');
      return;
    }

    final planeta = Planetas(
      null,
      _nameController.text,
      double.parse(_distanceFromSunController.text),
      double.parse(_radiusController.text),
    );

    try {
      await PlanetaService().agregarPlaneta(planeta);
      _clearForm();
      _loadPlanets();
    } catch (e) {
      _showErrorDialog('Error', 'Error al agregar planeta: $e');
    }
  }

  Future<void> _updatePlanet() async {
    if (_currentId == null) return;

    if (_nameController.text.isEmpty ||
        _distanceFromSunController.text.isEmpty ||
        _radiusController.text.isEmpty) {
      _showErrorDialog('Error', 'Por favor, complete todos los campos');
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(_distanceFromSunController.text)) {
      _showErrorDialog('Error', 'La distancia al Sol debe ser un número decimal');
      return;
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(_radiusController.text)) {
      _showErrorDialog('Error', 'El radio debe ser un número decimal');
      return;
    }

    final planeta = Planetas(
      _currentId,
      _nameController.text,
      double.parse(_distanceFromSunController.text),
      double.parse(_radiusController.text),
    );

    try {
      await PlanetaService().actualizarPlaneta(planeta);
      _clearForm();
      _loadPlanets();
    } catch (e) {
      _showErrorDialog('Error', 'Error al actualizar planeta: $e');
    }
  }

  Future<void> _deletePlanet(int id) async {
    try {
      await PlanetaService().eliminarPlaneta(id);
      _loadPlanets();
    } catch (e) {
      _showErrorDialog('Error', 'Error al eliminar planeta: $e');
    }
  }

  void _editPlanet(Planetas planeta) {
    setState(() {
      _currentId = planeta.id;
      _nameController.text = planeta.nombre!;
      _distanceFromSunController.text = planeta.distanciaSol.toString();
      _radiusController.text = planeta.radio.toString();
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _currentId = null;
      _nameController.clear();
      _distanceFromSunController.clear();
      _radiusController.clear();
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
