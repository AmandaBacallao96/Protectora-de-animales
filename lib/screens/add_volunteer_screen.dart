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
  List<bool> _diasSeleccionados = [false, false, false, false, false, false, false];
  TimeOfDay _horaInicio = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFin = TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.user.displayName ?? '';
  }

  Future<void> _seleccionarHora(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _horaInicio : _horaFin,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _horaInicio = picked;
          if (_horaFin.hour < _horaInicio.hour || (_horaFin.hour == _horaInicio.hour && _horaFin.minute <= _horaInicio.minute)) {
            _horaFin = TimeOfDay(hour: _horaInicio.hour + 1, minute: _horaInicio.minute);
          }
        } else {
          if (picked.hour > _horaInicio.hour || (picked.hour == _horaInicio.hour && picked.minute > _horaInicio.minute)) {
            _horaFin = picked;
          }
        }
      });
    }
  }

  void _saveVolunteer() {
    if (_nombreController.text.isEmpty || _motivacionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y motivación son obligatorios.")),
      );
      return;
    }

    String diasDisponibles = _diasSeleccionados.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => _diasDeLaSemana[entry.key])
        .join(", ");

    String rangoHoras = '${_horaInicio.format(context)} - ${_horaFin.format(context)}';

    FirebaseFirestore.instance.collection('voluntarios').add({
      'nombre': _nombreController.text,
      'email': widget.user.email,
      'motivacion': _motivacionController.text,
      'diasDisponibles': diasDisponibles,
      'rangoHoras': rangoHoras,
    });

    Navigator.pop(context);
  }

  List<String> _diasDeLaSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Voluntariado"), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Completar los siguientes campos para inscribirse como voluntario",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _motivacionController,
                decoration: InputDecoration(
                  labelText: "Motivación",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 10),

              const Text('Selecciona los días disponibles:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                children: List.generate(
                  7,
                      (index) => CheckboxListTile(
                    title: Text(_diasDeLaSemana[index]),
                    value: _diasSeleccionados[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _diasSeleccionados[index] = value ?? false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _seleccionarHora(context, true),
                    child: Text("Hora Inicio: ${_horaInicio.format(context)}",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                  ),
                  ElevatedButton(
                    onPressed: () => _seleccionarHora(context, false),
                    child: Text("Hora Fin: ${_horaFin.format(context)}",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveVolunteer,
                  child: const Text("Guardar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
