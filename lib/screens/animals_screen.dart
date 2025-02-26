import 'package:flutter/material.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Animales en Adopción")),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _animalCard("Max", "Perro Labrador", "assets/dog1.jpg"),
          _animalCard("Luna", "Gato Siames", "assets/cat1.jpg"),
          _animalCard("Rocky", "Perro Pastor", "assets/dog2.jpg"),
        ],
      ),
    );
  }

  Widget _animalCard(String name, String breed, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(breed),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
        onTap: () {
          // Acción al tocar
        },
      ),
    );
  }
}
