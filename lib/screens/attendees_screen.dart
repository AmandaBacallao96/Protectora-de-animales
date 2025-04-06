import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeesScreen extends StatelessWidget {
  final String eventId;

  const AttendeesScreen({super.key, required this.eventId});

  void _deleteAttendee(BuildContext context, String attendeeId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar inscripción?"),
        content: const Text("¿Estás seguro de eliminar esta inscripción? Esta acción no se puede deshacer."),
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
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(attendeeId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscripción eliminada"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscritos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (eventSnapshot.hasError) {
            return const Center(child: Text("Error al cargar evento"));
          }

          final eventData = eventSnapshot.data;
          String eventName = eventData?['title'] ?? 'Evento no encontrado';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Listado de Inscritos en el evento: $eventName',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId)
                      .collection('attendees')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error al cargar inscritos"));
                    }

                    final attendees = snapshot.data!.docs;

                    if (attendees.isEmpty) {
                      return const Center(child: Text("No hay inscritos en este evento"));
                    }

                    return ListView.builder(
                      itemCount: attendees.length,
                      itemBuilder: (context, index) {
                        final attendee = attendees[index];

                        // Obtener el nombre y el ID del usuario almacenado en Firestore
                        String userName = attendee['userName'] ?? 'Usuario sin nombre';
                        String attendeeId = attendee.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAttendee(context, attendeeId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
