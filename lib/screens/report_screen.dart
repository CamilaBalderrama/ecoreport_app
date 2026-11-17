import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Paquete HTTP para enviar datos
import '../helpers/database_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _locationMessage = "Ubicación no obtenida";
  Position? _currentPosition;
  File? _imageFile;
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = "El servicio de ubicación está desactivado.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationMessage = "Los permisos de ubicación fueron denegados.");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationMessage = "Los permisos están denegados permanentemente.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _locationMessage = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
    });
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveReportLocally() async {
    if (_currentPosition == null || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, captura la ubicación GPS y una foto de evidencia.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await DatabaseHelper.instance.insertReport({
      'latitude': _currentPosition!.latitude.toString(),
      'longitude': _currentPosition!.longitude.toString(),
      'imagePath': _imageFile!.path,
      'description': _descController.text,
      'synced': 0, // 0 significa pendiente de sincronización
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Reporte guardado localmente con éxito (Offline)!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );

    setState(() {
      _imageFile = null;
      _descController.clear();
      _locationMessage = "Ubicación no obtenida";
      _currentPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 34,
              width: 34,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.eco, color: Colors.white);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'EcoReport GPS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            tooltip: 'Ver historial',
            onPressed: () {
              Navigator.pushNamed(context, '/list');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gps_fixed, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _locationMessage,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _currentPosition == null ? Colors.grey.shade700 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F5E9),
                          foregroundColor: const Color(0xFF2E7D32),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.location_pin),
                        label: const Text('Obtener Ubicación GPS', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _imageFile == null
                        ? Column(
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('No hay foto de evidencia seleccionada.', style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F5E9),
                          foregroundColor: const Color(0xFF2E7D32),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar Evidencia Fotográfica', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Descripción del residuo',
                hintText: 'Ej. Acumulación de plásticos en zona verde...',
                prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveReportLocally,
                child: const Text('Guardar Reporte (Offline)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA DE HISTORIAL CON BOTÓN DE SINCRONIZACIÓN
// ==========================================
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final data = await DatabaseHelper.instance.getUnsyncedReports();
    setState(() {
      _reports = data;
    });
  }

  // Función para sincronizar los reportes pendientes con el servidor
  Future<void> _syncReports() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      for (var report in _reports) {
        // Ejemplo de petición HTTP POST hacia tu API o servidor backend
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://tu-servidor-api.com/api/reports'), // Cambia por tu URL real
        );

        request.fields['latitude'] = report['latitude'].toString();
        request.fields['longitude'] = report['longitude'].toString();
        request.fields['description'] = report['description'] ?? '';

        if (report['imagePath'] != null && File(report['imagePath']).existsSync()) {
          request.files.add(await http.MultipartFile.fromPath('image', report['imagePath']));
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Si el servidor responde con éxito, actualizamos en SQLite a synced = 1
          await DatabaseHelper.instance.markAsSynced(report['id']);
        }
      }

      // Recargamos la lista para que desaparezcan los ya sincronizados
      await _loadReports();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Sincronización completada con éxito!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de red al sincronizar: Asegúrate de tener conexión.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text('Reportes Registrados', style: TextStyle(color: Colors.white)),
        actions: [
          // Botón superior para sincronizar los datos pendientes
          if (_reports.isNotEmpty)
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
              tooltip: 'Sincronizar con el servidor',
              onPressed: _isSyncing ? null : _syncReports,
            ),
        ],
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.shade300),
                  const SizedBox(height: 12),
                  Text('No hay reportes pendientes de sincronizar.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(Icons.location_pin, color: Color(0xFF2E7D32)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Lat: ${report['latitude']} \nLon: ${report['longitude']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: const Text(
                                  'Pendiente',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text(
                            report['description'] != null && report['description'].toString().isNotEmpty
                                ? report['description']
                                : 'Sin descripción proporcionada.',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}