import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptionRequestScreen extends StatefulWidget {
  const AdoptionRequestScreen({super.key});

  @override
  _AdoptionRequestScreenState createState() => _AdoptionRequestScreenState();
}

class _AdoptionRequestScreenState extends State<AdoptionRequestScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String selectedFilter = 'Todos';
  String searchQuery = '';

  // Método para cambiar el estado de la solicitud
  void _updateStatus(String docId, String currentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newStatus = currentStatus;
        return AlertDialog(
          title: const Text("Cambiar estado de solicitud"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: newStatus,
                items: const [
                  DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'Aceptada', child: Text('Aceptada')),
                  DropdownMenuItem(value: 'Denegada', child: Text('Denegada')),
                ],
                onChanged: (value) => setState(() => newStatus = value!),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('adoption_requests').doc(docId).update({'status': newStatus});
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar la solicitud con confirmación
  void _deleteRequest(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación de eliminación"),
          content: const Text("¿Estás seguro de que deseas eliminar esta solicitud?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('adoption_requests').doc(docId).delete();
                Navigator.pop(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Método para enviar correo
  Future<void> _sendEmail(String email) async {
    final String subject = Uri.encodeComponent('Solicitud de Adopción');
    final Uri emailLaunchUri = Uri.parse('mailto:$email?subject=$subject');

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw 'No se pudo abrir la aplicación de correo.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al intentar abrir el correo: $e')),
      );
    }
  }

  bool _matchesFilterAndSearch(Map<String, dynamic> data) {
    if (selectedFilter != 'Todos' && data['status'] != selectedFilter) return false;
    if (searchQuery.isNotEmpty) {
      return (data['animalName']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (data['userName']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }
    return true;
  }

  // Obtener nombre del animal desde la colección 'animals'
  Future<String> _getAnimalName(String animalId) async {
    try {
      DocumentSnapshot animalDoc = await FirebaseFirestore.instance.collection('animals').doc(animalId).get();
      if (animalDoc.exists && animalDoc.data() != null) {
        final data = animalDoc.data() as Map<String, dynamic>;
        return data['name']?.toString() ?? 'Nombre sin registrar';
      } else {
        return 'Nombre sin registrar';
      }
    } catch (e) {
      return 'Error al obtener nombre del animal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitudes de Adopción"),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Todos', child: Text('Todos')),
              PopupMenuItem(value: 'Pendiente', child: Text('Pendiente')),
              PopupMenuItem(value: 'Aceptada', child: Text('Aceptada')),
              PopupMenuItem(value: 'Denegada', child: Text('Denegada')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adoption_requests')
            .snapshots(), // ¡Aquí ya no se filtra por user!
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error al cargar las solicitudes'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          final filteredDocs = docs.where((doc) => _matchesFilterAndSearch(doc.data() as Map<String, dynamic>)).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No hay solicitudes de adopción'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return FutureBuilder<String>(
                future: _getAnimalName(data['animalId']),
                builder: (context, animalSnapshot) {
                  if (animalSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (animalSnapshot.hasError) {
                    return const Center(child: Text('Error al cargar el nombre del animal'));
                  }

                  final animalName = animalSnapshot.data ?? 'Nombre sin registrar';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.pets, color: Colors.white),
                      ),
                      title: Text(animalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Solicitado por: ${data['userName'] ?? 'Desconocido'}"),
                          const SizedBox(height: 4),
                          Text("Estado: ${data['status']}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRequest(doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.teal),
                            onPressed: () => _updateStatus(doc.id, data['status']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () => _sendEmail(data['userEmail'] ?? ''),
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Detalles de la solicitud para $animalName"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nombre del solicitante: ${data['userName']}"),
                                  Text("Correo: ${data['userEmail']}"),
                                  Text("Dirección: ${data['address']}"),
                                  Text("Tipo de vivienda: ${data['housingType']}"),
                                  Text("¿Tiene niños? ${data['hasChildren'] ? 'Sí' : 'No'}"),
                                  Text("¿Tiene otras mascotas? ${data['hasOtherPets'] ? 'Sí' : 'No'}"),
                                  if (data['hasOtherPets']) ...[
                                    Text("Cantidad de mascotas: ${data['petsCount']}"),
                                    Text("Razas de las mascotas: ${data['petsBreeds']}"),
                                  ],
                                  const SizedBox(height: 10),
                                  Text("Mensaje: ${data['message'] ?? 'Sin mensaje'}"),
                                  Text("Estado: ${data['status']}"),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
