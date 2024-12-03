import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD SQLite',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: CRUDPage(),
    );
  }
}

class CRUDPage extends StatefulWidget {
  @override
  _CRUDPageState createState() => _CRUDPageState();
}

class _CRUDPageState extends State<CRUDPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  late DatabaseHelper dbHelper;
  List<Map<String, dynamic>> _results = [];
  int? _selectedId; // ID del registro seleccionado para actualización

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _query(); // Cargar la lista de registros al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD con SQLite'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildInputFields(),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildResultList(),
            SizedBox(height: 20),
            _buildPersonalInfoButton(),
            SizedBox(height: 20),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(nombreController, 'Nombre'),
        SizedBox(height: 10),
        _buildTextField(apellidoController, 'Apellido'),
        SizedBox(height: 10),
        _buildTextField(matriculaController, 'Matrícula'),
        SizedBox(height: 10),
        _buildTextField(descripcionController, 'Descripción'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: _insert,
          child: Text('Insertar'),
        ),
        ElevatedButton(
          onPressed: _query,
          child: Text('Consultar'),
        ),
        ElevatedButton(
          onPressed: _update,
          child: Text('Actualizar'),
        ),
      ],
    );
  }

  Widget _buildResultList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final row = _results[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                  '${row[DatabaseHelper.columnNombre]} ${row[DatabaseHelper.columnApellido]}'),
              subtitle: Text(
                  'Matrícula: ${row[DatabaseHelper.columnMatricula]}\nDescripción: ${row[DatabaseHelper.columnDescripcion]}'),
              onTap: () => _selectForUpdate(row),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _delete(row[DatabaseHelper.columnId]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoButton() {
    return ElevatedButton(
      onPressed: _showPersonalInfo,
      child: Text('Mostrar Información Personal'),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton(
      onPressed: _exportToXML,
      child: Text('Exportar a XML'),
    );
  }

  void _showPersonalInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Información Personal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/mifoto.jpg',
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 10),
              Text('Nombre: Kewin Sanchez Martinez'),
              Text('Matrícula: 2022-0169'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _selectForUpdate(Map<String, dynamic> row) {
    setState(() {
      _selectedId = row[DatabaseHelper.columnId];
      nombreController.text = row[DatabaseHelper.columnNombre];
      apellidoController.text = row[DatabaseHelper.columnApellido];
      matriculaController.text = row[DatabaseHelper.columnMatricula];
      descripcionController.text = row[DatabaseHelper.columnDescripcion];
    });
  }

  void _insert() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnNombre: nombreController.text,
      DatabaseHelper.columnApellido: apellidoController.text,
      DatabaseHelper.columnMatricula: matriculaController.text,
      DatabaseHelper.columnDescripcion: descripcionController.text,
    };
    final id = await dbHelper.insert(row);
    print('Fila insertada id: $id');
    _clearFields();
    _query();
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    setState(() {
      _results = allRows;
    });
  }

  void _update() async {
    if (_selectedId != null) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnId: _selectedId,
        DatabaseHelper.columnNombre: nombreController.text,
        DatabaseHelper.columnApellido: apellidoController.text,
        DatabaseHelper.columnMatricula: matriculaController.text,
        DatabaseHelper.columnDescripcion: descripcionController.text,
      };
      final rowsAffected = await dbHelper.update(row);
      print('Filas actualizadas: $rowsAffected');
      _clearFields();
      _query();
      setState(() {
        _selectedId = null;
      });
    } else {
      print('Seleccione un registro para actualizar');
    }
  }

  void _delete(int id) async {
    final rowsDeleted = await dbHelper.delete(id);
    print('Filas eliminadas: $rowsDeleted');
    _query();
  }

  void _exportToXML() async {
    final allRows = await dbHelper.queryAllRows();
    String xmlContent = _generateXML(allRows);

    final directory = Directory('${Directory.current.path}/exports');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    final file = File('${directory.path}/datos_exportados.xml');
    await file.writeAsString(xmlContent);
    print('Archivo XML exportado en: ${file.path}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exportación Completa'),
          content: Text('Los datos se han exportado a ${file.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _generateXML(List<Map<String, dynamic>> data) {
    StringBuffer xml = StringBuffer();
    xml.write('<?xml version="1.0" encoding="UTF-8"?>\n');
    xml.write('<registros>\n');
    for (var row in data) {
      xml.write('  <registro>\n');
      xml.write('    <nombre>${row[DatabaseHelper.columnNombre]}</nombre>\n');
      xml.write(
          '    <apellido>${row[DatabaseHelper.columnApellido]}</apellido>\n');
      xml.write(
          '    <matricula>${row[DatabaseHelper.columnMatricula]}</matricula>\n');
      xml.write(
          '    <descripcion>${row[DatabaseHelper.columnDescripcion]}</descripcion>\n');
      xml.write('  </registro>\n');
    }
    xml.write('</registros>');
    return xml.toString();
  }

  void _clearFields() {
    nombreController.clear();
    apellidoController.clear();
    matriculaController.clear();
    descripcionController.clear();
  }
}
