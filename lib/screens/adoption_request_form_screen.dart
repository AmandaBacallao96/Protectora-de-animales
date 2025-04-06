import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'animals_screen.dart';

class AdoptionRequestForm extends StatefulWidget {
  final String animalId;
  const AdoptionRequestForm({super.key, required this.animalId});

  @override
  _AdoptionRequestFormState createState() => _AdoptionRequestFormState();
}

class _AdoptionRequestFormState extends State<AdoptionRequestForm> {
  // Definir los controladores de los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _petsCountController = TextEditingController();
  final TextEditingController _petsBreedsController = TextEditingController();

  // Definir las variables para los campos adicionales
  String? _housingType = 'Casa'; // "Casa" o "Apartamento"
  bool _hasChildren = false;
  bool _hasOtherPets = false;

  // Definir la clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Función para enviar la solicitud de adopción
  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    String userName = _nameController.text.trim();
    String message = _messageController.text.trim();
    String address = _addressController.text.trim();
    String petsCount = _petsCountController.text.trim();
    String petsBreeds = _petsBreedsController.text.trim();
    String userEmail = FirebaseAuth.instance.currentUser!.email!; // Obtener el email del usuario autenticado

    // Agregar la solicitud de adopción a Firestore
    try {
      await FirebaseFirestore.instance.collection('adoption_requests').add({
        'animalId': widget.animalId,
        'userName': userName,
        'userEmail': userEmail,
        'message': message,
        'address': address,
        'housingType': _housingType,
        'hasChildren': _hasChildren,
        'hasOtherPets': _hasOtherPets,
        'petsCount': petsCount,
        'petsBreeds': petsBreeds,
        'status': 'Pendiente',
        'timestamp': FieldValue.serverTimestamp(), // Agregar un timestamp para ordenar las solicitudes
      });

      // Mostrar un cuadro de diálogo de éxito
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("¡Solicitud Enviada!", style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("Tu solicitud de adopción ha sido enviada exitosamente."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                  // Volver a la pantalla de lista de animales después de enviar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AnimalsScreen()), // Reemplazar AnimalsScreen() con la pantalla correspondiente
                  );
                },
                child: const Text("Aceptar", style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Mostrar un error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la solicitud: $e')),
      );
    }
  }

  // Construcción del formulario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitud de Adopción", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Completa tu solicitud",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 20),

                // Campo para el nombre del solicitante
                _buildTextField(
                  controller: _nameController,
                  label: "Tu nombre",
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                ),
                const SizedBox(height: 20),

                // Campo para el mensaje
                _buildTextField(
                  controller: _messageController,
                  label: "Mensaje",
                  icon: Icons.message,
                  maxLines: 4,
                  validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                ),
                const SizedBox(height: 20),

                // Campo para la dirección
                _buildTextField(
                  controller: _addressController,
                  label: "Dirección",
                  icon: Icons.location_on,
                  validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                ),
                const SizedBox(height: 20),

                // Campo para el tipo de vivienda (Casa o Apartamento)
                DropdownButtonFormField<String>(
                  value: _housingType,
                  items: const [
                    DropdownMenuItem(value: 'Casa', child: Text('Casa')),
                    DropdownMenuItem(value: 'Apartamento', child: Text('Apartamento')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _housingType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Tipo de Vivienda",
                    prefixIcon: const Icon(Icons.house, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  validator: (value) => value == null ? "Este campo es obligatorio" : null,
                ),
                const SizedBox(height: 20),

                // ¿Tienes niños? (Switch)
                Row(
                  children: [
                    const Text("¿Tienes niños?", style: TextStyle(color: Colors.green, fontSize: 16)),
                    Switch(
                      value: _hasChildren,
                      onChanged: (value) {
                        setState(() {
                          _hasChildren = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ¿Tienes otras mascotas? (Switch)
                Row(
                  children: [
                    const Text("¿Tienes otras mascotas?", style: TextStyle(color: Colors.green, fontSize: 16)),
                    Switch(
                      value: _hasOtherPets,
                      onChanged: (value) {
                        setState(() {
                          _hasOtherPets = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Si hay otras mascotas, agregar cantidad y razas
                if (_hasOtherPets) ...[
                  _buildTextField(
                    controller: _petsCountController,
                    label: "Cantidad de mascotas",
                    icon: Icons.pets,
                    validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _petsBreedsController,
                    label: "Razas de las mascotas",
                    icon: Icons.pets,
                    validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
                  ),
                ],
                const SizedBox(height: 20),

                // Botón de Enviar
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _submitRequest,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text("Enviar Solicitud", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para construir los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green),
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.green[50],
      ),
    );
  }
}
