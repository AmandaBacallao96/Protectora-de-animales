import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdoptionRequestForm extends StatefulWidget {
  final String animalId;

  const AdoptionRequestForm({super.key, required this.animalId});

  @override
  State<AdoptionRequestForm> createState() => _AdoptionRequestFormState();
}

class _AdoptionRequestFormState extends State<AdoptionRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSubmitting = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      await FirebaseFirestore.instance.collection('adoptionRequests').add({
        'animalId': widget.animalId,
        'name': _nameController.text,
        'email': _emailController.text,
        'reason': _reasonController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Solicitud enviada con éxito!')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulario de Adopción")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Ingrese su nombre" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Ingrese su correo" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: "¿Por qué desea adoptar?",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? "Cuéntenos su motivo" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: const Icon(Icons.send),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enviar Solicitud"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
