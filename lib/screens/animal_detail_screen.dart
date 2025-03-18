import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'adoption_request_form_screen.dart';

class AnimalDetailScreen extends StatelessWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Animal")),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.pets, color: Colors.teal),
                          title: Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["name"]),
                        ),
                        ListTile(
                          leading: const Icon(Icons.assignment, color: Colors.teal),
                          title: Text("Raza", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["breed"]),
                        ),
                        ListTile(
                          leading: const Icon(Icons.straighten, color: Colors.teal),
                          title: Text("Tamaño", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["size"]),
                        ),
                        ListTile(
                          leading: const Icon(Icons.cake, color: Colors.teal),
                          title: Text("Edad", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${doc["age"]} años"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description, color: Colors.teal),
                          title: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["description"] ?? 'No hay descripción disponible'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.health_and_safety, color: Colors.teal),
                          title: Text("Estado de salud", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["healthStatus"]),
                        ),
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.teal),
                          title: Text("Estado de adopción", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc["adoptionStatus"]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdoptionRequestForm(animalId: animalId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text("Solicitar Adopción", style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.teal,
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}


