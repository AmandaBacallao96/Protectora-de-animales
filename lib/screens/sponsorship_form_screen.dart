import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SponsorshipFormScreen extends StatefulWidget {
  final String animalId;

  const SponsorshipFormScreen({super.key, required this.animalId});

  @override
  _SponsorshipFormScreenState createState() => _SponsorshipFormScreenState();
}

class _SponsorshipFormScreenState extends State<SponsorshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  // Obtener el usuario logueado
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitSponsorshipRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Obtener el usuario logueado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay usuario logueado")),
        );
        return;
      }

      // Obtener el nombre del usuario (si está disponible)
      final userDoc = await FirebaseFirestore.instance.collection("usuarios").doc(user.uid).get();
      String userName = userDoc.exists ? userDoc["nombre"] ?? "Nombre desconocido" : "Nombre desconocido";

      // Crear la solicitud de apadrinamiento
      await FirebaseFirestore.instance.collection("sponsorships").add({
        "animalId": widget.animalId,
        "reason": _reasonController.text,
        "timestamp": Timestamp.now(),
        "userId": user.uid,
        "userName": userName,  // Agregar el nombre del usuario logueado
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud de apadrinamiento enviada con éxito")),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar la solicitud: $e")),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulario de Apadrinamiento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Motivo del Apadrinamiento",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: "Explica por qué quieres apadrinar a este animal",
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, ingresa un motivo";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitSponsorshipRequest,
                  icon: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  label: const Text("Enviar Solicitud"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.orange[600],
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
