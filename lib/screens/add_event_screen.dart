import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Evento")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título del Evento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Dirección del Evento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Descripción del Evento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Selector de fecha
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Fecha del Evento",
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            // Selector de hora
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: "Hora del Evento",
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _timeController.text = pickedTime.format(context);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isEmpty ||
                      _addressController.text.isEmpty ||
                      _dateController.text.isEmpty ||
                      _timeController.text.isEmpty ||
                      _descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, completa todos los campos")),
                    );
                  } else {
                    // Guardar evento en Firestore
                    await FirebaseFirestore.instance.collection('events').add({
                      'title': _titleController.text,
                      'date': _dateController.text,
                      'time': _timeController.text,
                      'address': _addressController.text,
                      'description': _descriptionController.text,
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar Evento"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
