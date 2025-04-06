import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddAnimalScreen extends StatefulWidget {
  final String? animalId;

  AddAnimalScreen({Key? key, this.animalId}) : super(key: key);

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  String? _healthStatus;
  String? _size;
  String? _adoptionStatus;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _uploadImageToFirebaseStorage(File image) async {
    try {
      // Obtener la referencia de Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;

      // Nombre del archivo generado por el timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('animals/$fileName');

      // Subir el archivo
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir la imagen: $e");
      return '';
    }
  }

  Future<void> _saveAnimal(BuildContext context) async {
    int? age = int.tryParse(_ageController.text);

    // Verificación de campos vacíos
    if (_nameController.text.isEmpty ||
        _breedController.text.isEmpty ||
        age == null ||
        _descriptionController.text.isEmpty ||
        _healthStatus == null ||
        _size == null ||
        _adoptionStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos.")),
      );
      return;
    }

    try {
      // Si no se seleccionó imagen, se guarda la imagen predeterminada
      String imageUrl = _image != null
          ? await _uploadImageToFirebaseStorage(_image!)
          : "Foto no disponible"; // Imagen por defecto

      if (widget.animalId == null) {
        // Nuevo animal
        String newAnimalId = _firestore.collection("animals").doc().id;

        await _firestore.collection("animals").doc(newAnimalId).set({
          "animalId": newAnimalId,
          "name": _nameController.text,
          "breed": _breedController.text,
          "age": age,
          "description": _descriptionController.text,
          "healthStatus": _healthStatus,
          "size": _size,
          "adoptionStatus": _adoptionStatus,
          "imagePath": imageUrl, // Se guarda la URL o el texto de imagen por defecto
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Animal agregado exitosamente.")),
        );
      } else {
        // Actualización de animal existente
        await _firestore.collection("animals").doc(widget.animalId).update({
          "name": _nameController.text,
          "breed": _breedController.text,
          "age": age,
          "description": _descriptionController.text,
          "healthStatus": _healthStatus,
          "size": _size,
          "adoptionStatus": _adoptionStatus,
          "imagePath": imageUrl, // Se guarda la URL o el texto de imagen por defecto
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Animal actualizado exitosamente.")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Animal"), backgroundColor: Colors.green.shade600),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, width: 120, height: 120, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField("Nombre del Animal", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Raza", _breedController),
            const SizedBox(height: 16),
            _buildTextField("Edad", _ageController, isNumber: true),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: "Estado de Salud",
              value: _healthStatus,
              items: ["Mal", "Regular", "Bien"],
              onChanged: (value) => _healthStatus = value,
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: "Tamaño",
              value: _size,
              items: ["Pequeño", "Mediano", "Grande"],
              onChanged: (value) => _size = value,
            ),
            const SizedBox(height: 16),
            _buildTextField("Breve Descripción", _descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: "Estado",
              value: _adoptionStatus,
              items: ["Disponible para adopción", "Disponible para apadrinar"],
              onChanged: (value) => _adoptionStatus = value,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveAnimal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                child: const Text("Guardar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int? maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}
