import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorshipsScreen extends StatefulWidget {
  const SponsorshipsScreen({super.key});

  @override
  _SponsorshipsScreenState createState() => _SponsorshipsScreenState();
}

class _SponsorshipsScreenState extends State<SponsorshipsScreen> {

  // Función para confirmar eliminación de una solicitud de apadrinamiento
  void _confirmDelete(String sponsorshipId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text("Esta acción no se puede deshacer. ¿Quieres eliminar esta solicitud de apadrinamiento?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteSponsorship(sponsorshipId); // Eliminar la solicitud
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

  // Función para eliminar una solicitud de apadrinamiento
  void _deleteSponsorship(String sponsorshipId) {
    FirebaseFirestore.instance.collection('sponsorships').doc(sponsorshipId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud de apadrinamiento eliminada")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar la solicitud: $error")),
      );
    });
  }

  // Función para obtener el nombre del animal
  Future<String> _getAnimalName(String animalId) async {
    try {
      DocumentSnapshot animalSnapshot = await FirebaseFirestore.instance.collection('animals').doc(animalId).get();
      if (animalSnapshot.exists) {
        var animalData = animalSnapshot.data() as Map<String, dynamic>;
        return animalData['name'] ?? 'Nombre desconocido';
      } else {
        return 'Nombre desconocido';
      }
    } catch (e) {
      return 'Nombre desconocido';
    }
  }

  // Función para lanzar el correo
  Future<void> _sendEmail(String email) async {
    final String subject = Uri.encodeComponent('Solicitud de Apadrinamiento');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Listado de Padrinos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sponsorships').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final sponsorships = snapshot.data?.docs ?? [];

          if (sponsorships.isEmpty) {
            return const Center(child: Text("No hay solicitudes de apadrinamiento"));
          }

          return ListView.builder(
            itemCount: sponsorships.length,
            itemBuilder: (context, index) {
              var sponsorship = sponsorships[index];
              final data = sponsorship.data() as Map<String, dynamic>;

              String animalId = data['animalId'];

              return FutureBuilder<String>(
                future: _getAnimalName(animalId),
                builder: (context, animalSnapshot) {
                  if (animalSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  String animalName = animalSnapshot.data ?? 'Animal desconocido';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      title: Text(data['userName'] ?? 'Usuario desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Animal: $animalName\nMotivo: ${data['reason']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(sponsorship.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () => _sendEmail(data['userId'] ?? ''),  // Usar el userId como email (ajustar si es necesario)
                          ),
                        ],
                      ),
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
