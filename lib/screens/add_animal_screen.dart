import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddAnimalScreen extends StatelessWidget {
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

  final String? animalId;

  AddAnimalScreen({Key? key, this.animalId}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
  }

  Future<void> _saveAnimal(BuildContext context) async {

    int? age = int.tryParse(_ageController.text);

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
      if (animalId == null) {
        //Agregar nuevo animal
        await _firestore.collection("animals").add({
          "name": _nameController.text,
          "breed": _breedController.text,
          "age": age,
          "description": _descriptionController.text,
          "healthStatus": _healthStatus,
          "size": _size,
          "adoptionStatus": _adoptionStatus,
          "imagePath": _image != null ? _image!.path : "Foto no disponible",
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Animal agregado exitosamente.")),
        );
      } else {

        await _firestore.collection("animals").doc(animalId).update({
          "name": _nameController.text,
          "breed": _breedController.text,
          "age": age, // Save age as an integer
          "description": _descriptionController.text,
          "healthStatus": _healthStatus,
          "size": _size,
          "adoptionStatus": _adoptionStatus,
          "imagePath": _image != null ? _image!.path : "Foto no disponible",
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


  Future<void> _loadAnimalData() async {
    if (animalId != null) {
      try {
        var doc = await _firestore.collection("animals").doc(animalId).get();
        if (doc.exists) {
          var data = doc.data()!;
          _nameController.text = data["name"];
          _breedController.text = data["breed"];
          _ageController.text = data["age"].toString();
          _descriptionController.text = data["description"];
          _healthStatus = data["healthStatus"];
          _size = data["size"];
          _adoptionStatus = data["adoptionStatus"];

        }
      } catch (e) {
        print("Error loading animal data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (animalId != null) {
      _loadAnimalData();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Animal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: _image == null
                    ? Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                )
                    : Image.file(_image!, width: 120, height: 120, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre del Animal",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: "Raza",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Edad",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _healthStatus,
              hint: const Text("Estado de Salud"),
              items: ["Mal", "Regular", "Bien"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                _healthStatus = newValue;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _size,
              hint: const Text("Tamaño"),
              items: ["Pequeño", "Mediano", "Grande"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                _size = newValue;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Breve Descripción",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _adoptionStatus,
              hint: const Text("Estado"),
              items: ["Disponible para adopción", "Disponible para apadrinar"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                _adoptionStatus = newValue;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveAnimal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  "Guardar",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

