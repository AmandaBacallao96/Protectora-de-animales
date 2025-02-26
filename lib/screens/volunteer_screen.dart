import 'package:flutter/material.dart';

class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voluntariado")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¿Quieres ser voluntario?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Únete a nuestra comunidad y ayuda a los animales."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Quiero ser voluntario"),
            ),
          ],
        ),
      ),
    );
  }
}
