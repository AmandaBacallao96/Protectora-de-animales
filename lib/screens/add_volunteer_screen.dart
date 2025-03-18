import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVolunteerScreen extends StatefulWidget {
  final User user;

  const AddVolunteerScreen({super.key, required this.user});

  @override
  _AddVolunteerScreenState createState() => _AddVolunteerScreenState();
}

class _AddVolunteerScreenState extends State<AddVolunteerScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _motivacionController = TextEditingController();
  final TextEditingController _disponibilidadController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nombreController.text = widget.user.displayName ?? '';
  }

  void _saveVolunteer() {
    FirebaseFirestore.instance.collection('voluntarios').add({
      'nombre': _nombreController.text.isNotEmpty ? _nombreController.text : (widget.user.displayName ?? 'Usuario sin nombre'),
      'email': widget.user.email,
      'motivacion': _motivacionController.text,
      'disponibilidad': _disponibilidadController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Voluntariado")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Completar los siguientes campos para inscribirse como voluntario", style: TextStyle(fontSize: 22),),
            const SizedBox(height: 20),

            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre Completo"),
            ),
            const SizedBox(height: 10),


            TextField(
              controller: _motivacionController,
              decoration: const InputDecoration(labelText: "Motivación"),
            ),
            const SizedBox(height: 10),


            TextField(
              controller: _disponibilidadController,
              decoration: const InputDecoration(labelText: "Disponibilidad"),
            ),
            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: _saveVolunteer,
              child: const Text("Guardar", style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}

