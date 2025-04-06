import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'adoption_request_form_screen.dart';
import 'sponsorship_form_screen.dart';

class AnimalDetailScreen extends StatelessWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  void _goToAdoptionForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdoptionRequestForm(animalId: animalId),
      ),
    );
  }

  void _goToSponsorshipForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SponsorshipFormScreen(animalId: animalId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Animal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("animals").doc(animalId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Animal no encontrado"));
          }

          var doc = snapshot.data!;
          String animalName = doc['name'] ?? 'Nombre no disponible';
          String adoptionStatus = doc["adoptionStatus"] ?? 'Estado desconocido';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                // Tarjeta de Información
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailItem(Icons.pets, "Nombre", animalName),
                        _buildDetailItem(Icons.assignment, "Raza", doc["breed"]),
                        _buildDetailItem(Icons.straighten, "Tamaño", doc["size"]),
                        _buildDetailItem(Icons.cake, "Edad", "${doc["age"]} años"),
                        _buildDetailItem(Icons.description, "Descripción", doc["description"] ?? 'No hay descripción disponible'),
                        _buildDetailItem(Icons.health_and_safety, "Estado de salud", doc["healthStatus"]),
                        _buildDetailItem(Icons.home, "Estado de adopción", adoptionStatus),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de Adopción (Solo si no está disponible para apadrinar)
                if (adoptionStatus != "Disponible para apadrinar")
                  _buildButton(
                    onPressed: () => _goToAdoptionForm(context),
                    text: "Solicitar Adopción",
                    color: Colors.green[700]!,
                    icon: Icons.favorite,
                  ),

                const SizedBox(height: 10),

                // Botón de Apadrinamiento (Siempre visible)
                _buildButton(
                  onPressed: () => _goToSponsorshipForm(context),
                  text: "Apadrinar",
                  color: Colors.greenAccent,
                  icon: Icons.volunteer_activism,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget para mostrar los detalles en la tarjeta
  Widget _buildDetailItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  // Widget para botones estilizados
  Widget _buildButton({required VoidCallback onPressed, required String text, required Color color, required IconData icon}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
