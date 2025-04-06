import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importamos FirebaseAuth
import 'add_event_screen.dart';
import 'attendees_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _filterText = '';

  void _filterEvents(String value) {
    setState(() {
      _filterText = value.toLowerCase();
    });
  }

  void _deleteEvent(String eventId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar evento?"),
        content: const Text("¿Estás seguro de eliminar este evento? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Evento eliminado")),
      );
    }
  }

  void _subscribeToEvent(String eventId, String title) async {
    User? user = FirebaseAuth.instance.currentUser; // Obtener el usuario autenticado

    if (user == null) {
      // Si no hay usuario autenticado, muestra un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, inicie sesión para inscribirse en el evento")),
      );
      return;
    }

    String userId = user.uid; // Obtener el UID del usuario autenticado

    // Verificar si el usuario ya está inscrito en el evento
    DocumentSnapshot attendeeDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .doc(userId)
        .get();

    if (attendeeDoc.exists) {
      // Si el usuario ya está inscrito, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ya estás inscrito en el evento: $title"),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return; // Salir del método si ya está inscrito
    }

    // Obtener los detalles del usuario desde Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();

    // Verificar si el documento de usuario existe
    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró información del usuario")),
      );
      return;
    }

    // Obtener el nombre y email del usuario desde Firestore
    String userName = userDoc['nombre'] ?? "Usuario sin nombre"; // Si no hay nombre, poner "Usuario sin nombre"
    String userEmail = userDoc['email'] ?? "Usuario sin email";  // Si no hay email, poner "Usuario sin email"

    // Inscribir al usuario en el evento, guardando también su nombre y correo
    await FirebaseFirestore.instance.collection('events').doc(eventId).collection('attendees').doc(userId).set({
      'userId': userId,
      'userName': userName, // Guardar el nombre del usuario
      'userEmail': userEmail, // Guardar el email del usuario
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Te has inscrito en el evento: $title"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: const Text("Eventos", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEventScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterEvents,
              decoration: InputDecoration(
                hintText: "Buscar evento...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar eventos"));
          }

          final events = snapshot.data!.docs.where((event) {
            final title = event['title'].toString().toLowerCase();
            return title.contains(_filterText);
          }).toList();

          if (events.isEmpty) {
            return const Center(child: Text("No hay eventos que coincidan"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(event['date'], style: const TextStyle(color: Colors.black87)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(event['time'], style: const TextStyle(color: Colors.black87)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(child: Text(event['address'], style: const TextStyle(color: Colors.black87))),
                      ]),
                      const SizedBox(height: 6),
                      Text(event['description'], style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEventScreen(eventId: event.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteEvent(event.id);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _subscribeToEvent(event.id, event['title']);
                            },
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text("Inscribirse", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendeesScreen(eventId: event.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list, color: Colors.white),
                            label: const Text("Ver inscritos", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          ),
                        ],
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
