import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  void _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }

  void _editEvent(String eventId, String title, String date, String time, String address, String description) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController dateController = TextEditingController(text: date);
    TextEditingController timeController = TextEditingController(text: time);
    TextEditingController addressController = TextEditingController(text: address);
    TextEditingController descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Evento"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Título")),
                TextField(controller: dateController, decoration: const InputDecoration(labelText: "Fecha")),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: "Hora")),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: "Dirección")),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Descripción")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('events').doc(eventId).update({
                  'title': titleController.text,
                  'date': dateController.text,
                  'time': timeController.text,
                  'address': addressController.text,
                  'description': descriptionController.text,
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _subscribeToEvent(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Te has inscrito en el evento: $title")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Eventos"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEventScreen()),
              );
            },
          ),
        ],
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

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                          const SizedBox(width: 6),
                          Text(event['date'], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.teal),
                          const SizedBox(width: 6),
                          Text(event['time'], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.teal),
                          const SizedBox(width: 6),
                          Expanded(child: Text(event['address'], style: const TextStyle(color: Colors.grey))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(event['description'], style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _editEvent(event.id, event['title'], event['date'], event['time'], event['address'], event['description']);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Editar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _deleteEvent(event.id);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Eliminar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _subscribeToEvent(event['title']);
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Inscribirse"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
