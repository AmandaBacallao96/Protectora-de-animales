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
        title: const Text("Voluntariado"),
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
              child: const Text("Quiero ser voluntario", style: TextStyle(color: Colors.black),),
            ),
            const SizedBox(height: 20),


            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Escribe aquí...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
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
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar los voluntarios'));
                  }

                  final volunteers = snapshot.data?.docs ?? [];

                  if (volunteers.isEmpty) {
                    return const Center(child: Text('No hay voluntarios inscritos'));
                  }


                  final filteredVolunteers = volunteers.where((volunteer) {
                    final data = volunteer.data() as Map<String, dynamic>;

                    final nombre = data.containsKey('nombre')
                        ? (data['nombre'] ?? '').toLowerCase()
                        : 'sin nombre';
                    final motivacion = data.containsKey('motivacion')
                        ? (data['motivacion'] ?? '').toLowerCase()
                        : '';
                    final disponibilidad = data.containsKey('disponibilidad')
                        ? (data['disponibilidad'] ?? '').toLowerCase()
                        : '';

                    switch (searchCriteria) {
                      case "nombre":
                        return nombre.contains(searchQuery);
                      case "motivacion":
                        return motivacion.contains(searchQuery);
                      case "disponibilidad":
                        return disponibilidad.contains(searchQuery);
                      default:
                        return false;
                    }
                  }).toList();

                  if (filteredVolunteers.isEmpty) {
                    return const Center(child: Text('No se encontraron resultados.'));
                  }

                  return ListView.builder(
                    itemCount: filteredVolunteers.length,
                    itemBuilder: (context, index) {
                      var volunteer = filteredVolunteers[index];
                      final data = volunteer.data() as Map<String, dynamic>;

                      String nombre = data.containsKey('nombre') ? data['nombre'] ?? '' : '';


                      if (nombre.isEmpty) {
                        nombre = currentUserName;
                      }

                      final motivacion = data.containsKey('motivacion') ? data['motivacion'] ?? 'No disponible' : 'No disponible';
                      final disponibilidad = data.containsKey('disponibilidad') ? data['disponibilidad'] ?? 'No disponible' : 'No disponible';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(nombre),
                          subtitle: Text("Motivación: $motivacion\nDisponibilidad: $disponibilidad"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editVolunteer(context, volunteer),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVolunteer(volunteer.id),
                              ),
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


  void _deleteVolunteer(String id) {
    FirebaseFirestore.instance.collection('voluntarios').doc(id).delete();
  }


  void _editVolunteer(BuildContext context, QueryDocumentSnapshot volunteer) {
    final data = volunteer.data() as Map<String, dynamic>;

    TextEditingController nombreController = TextEditingController(text: data.containsKey('nombre') ? data['nombre'] ?? '' : '');
    TextEditingController motivacionController = TextEditingController(text: data.containsKey('motivacion') ? data['motivacion'] ?? '' : '');
    TextEditingController disponibilidadController = TextEditingController(text: data.containsKey('disponibilidad') ? data['disponibilidad'] ?? '' : '');

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
              TextField(controller: disponibilidadController, decoration: const InputDecoration(labelText: "Disponibilidad")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('voluntarios').doc(volunteer.id).update({
                  'nombre': nombreController.text,
                  'motivacion': motivacionController.text,
                  'disponibilidad': disponibilidadController.text,
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
