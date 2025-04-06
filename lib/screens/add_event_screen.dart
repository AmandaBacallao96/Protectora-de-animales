import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final String? eventId;
  const AddEventScreen({super.key, this.eventId});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEventData();
    }
  }

  void _loadEventData() async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
    if (eventDoc.exists) {
      setState(() {
        _titleController.text = eventDoc['title'];
        _dateController.text = eventDoc['date'];
        _timeController.text = eventDoc['time'];
        _descriptionController.text = eventDoc['description'];
        _addressController.text = eventDoc['address'];
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> eventData = {
        'title': _titleController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
      };

      if (widget.eventId == null) {
        await FirebaseFirestore.instance.collection('events').add(eventData);
      } else {
        await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update(eventData);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDate = _dateController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').parse(_dateController.text) : now;
      final selectedTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, picked.hour, picked.minute);

      if (selectedDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) && selectedTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No puedes seleccionar una hora pasada para hoy.")),
        );
        return;
      }

      setState(() {
        _timeController.text = DateFormat('HH:mm').format(selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? "Agregar Evento" : "Editar Evento"),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, "Nombre del Evento", true),
              SizedBox(height: 10),
              _buildDateTimeField(_dateController, "Fecha del Evento", Icons.calendar_today, _selectDate, true),
              SizedBox(height: 10),
              _buildDateTimeField(_timeController, "Hora del Evento", Icons.access_time, _selectTime, true),
              SizedBox(height: 10),
              _buildTextField(_addressController, "Dirección del Evento", true),
              SizedBox(height: 10),
              _buildTextField(_descriptionController, "Descripción", true, maxLines: 3),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveEvent,
                  child: Text("Guardar Evento", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isRequired, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.green.shade50,
      ),
      maxLines: maxLines,
      validator: isRequired ? (value) => value!.isEmpty ? "Este campo es obligatorio" : null : null,
    );
  }

  Widget _buildDateTimeField(TextEditingController controller, String label, IconData icon, VoidCallback onTap, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.green.shade50,
        suffixIcon: Icon(icon, color: Colors.green.shade600),
      ),
      readOnly: true,
      onTap: onTap,
      validator: isRequired ? (value) => value!.isEmpty ? "Este campo es obligatorio" : null : null,
    );
  }
}
