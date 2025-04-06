import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:protectora_animalesnew/screens/add_volunteer_screen.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  String searchQuery = "";
  String searchCriteria = "nombre";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentUserName = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  void _getCurrentUserName() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUserName = userDoc['nombre'] ?? 'Sin nombre';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voluntariado", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¿Quieres ser voluntario?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Text("Únete a nuestra comunidad y ayuda a los animales."),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final User? user = _auth.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddVolunteerScreen(user: user)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Debes iniciar sesión para inscribirte.")),
                  );
                }
              },
              child: const Text("Quiero ser voluntario", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar voluntario...",
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: searchCriteria,
              onChanged: (String? newValue) {
                setState(() {
                  searchCriteria = newValue!;
                });
              },
              items: const [
                DropdownMenuItem(value: "nombre", child: Text("Nombre")),
                DropdownMenuItem(value: "motivacion", child: Text("Motivación")),
                DropdownMenuItem(value: "disponibilidad", child: Text("Disponibilidad")),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Voluntarios Inscritos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('voluntarios').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final volunteers = snapshot.data?.docs ?? [];
                  final filteredVolunteers = volunteers.where((volunteer) {
                    final data = volunteer.data() as Map<String, dynamic>;
                    final value = (data[searchCriteria] ?? '').toString().toLowerCase();
                    return value.contains(searchQuery);
                  }).toList();

                  if (filteredVolunteers.isEmpty) {
                    return const Center(child: Text('No se encontraron resultados.'));
                  }

                  return ListView.builder(
                    itemCount: filteredVolunteers.length,
                    itemBuilder: (context, index) {
                      var volunteer = filteredVolunteers[index];
                      final data = volunteer.data() as Map<String, dynamic>;

                      // Obtener los campos de la base de datos
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final motivacion = data['motivacion'] ?? 'No disponible';
                      final diasDisponibles = data['diasDisponibles'] ?? 'No disponible';
                      final rangoHoras = data['rangoHoras'] ?? 'No disponible';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: ListTile(
                          title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Motivación: $motivacion\n"
                              "Disponibilidad: $diasDisponibles\n"
                              "Horas: $rangoHoras"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => _editVolunteer(context, volunteer)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(volunteer.id)),  // Confirmación antes de eliminar
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text("Esta acción no se puede deshacer. ¿Quieres eliminar este voluntario?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteVolunteer(id); // Eliminar el voluntario
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text("Eliminar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _deleteVolunteer(String id) {
    FirebaseFirestore.instance.collection('voluntarios').doc(id).delete();
  }

  void _editVolunteer(BuildContext context, QueryDocumentSnapshot volunteer) {
    final data = volunteer.data() as Map<String, dynamic>;

    TextEditingController nombreController = TextEditingController(text: data.containsKey('nombre') ? data['nombre'] ?? '' : '');
    TextEditingController motivacionController = TextEditingController(text: data.containsKey('motivacion') ? data['motivacion'] ?? '' : '');
    TextEditingController disponibilidadController = TextEditingController(text: data.containsKey('diasDisponibles') ? data['diasDisponibles'] ?? '' : '');
    TextEditingController rangoHorasController = TextEditingController(text: data.containsKey('rangoHoras') ? data['rangoHoras'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Voluntario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
              const SizedBox(height: 10),
              TextField(controller: motivacionController, decoration: const InputDecoration(labelText: "Motivación")),
              const SizedBox(height: 10),
              TextField(controller: disponibilidadController, decoration: const InputDecoration(labelText: "Días Disponibles")),
              const SizedBox(height: 10),
              TextField(controller: rangoHorasController, decoration: const InputDecoration(labelText: "Rango de Horas")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('voluntarios').doc(volunteer.id).update({
                  'nombre': nombreController.text,
                  'motivacion': motivacionController.text,
                  'diasDisponibles': disponibilidadController.text,
                  'rangoHoras': rangoHorasController.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
