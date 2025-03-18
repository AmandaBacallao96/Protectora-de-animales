import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_animal_screen.dart';
import 'animal_detail_screen.dart';

class AnimalsScreen extends StatefulWidget {
  @override
  _AnimalsScreenState createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchCategory = 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Animales")),
      body: Column(
        children: [
          // Search bar and filter category
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar...',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Dropdown for filter category
                DropdownButton<String>(
                  value: _searchCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchCategory = newValue!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text("Nombre")),
                    DropdownMenuItem(value: 'breed', child: Text("Raza")),
                    DropdownMenuItem(value: 'age', child: Text("Edad")),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection("animals").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay animales disponibles"));
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  String valueToSearch = '';

                  switch (_searchCategory) {
                    case 'name':
                      valueToSearch = doc["name"].toLowerCase();
                      break;
                    case 'breed':
                      valueToSearch = doc["breed"].toLowerCase();
                      break;
                    case 'age':
                      valueToSearch = doc["age"].toString().toLowerCase();
                      break;
                  }

                  return valueToSearch.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(doc["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Raza: ${doc["breed"]}\nEdad: ${doc["age"]} años"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddAnimalScreen(animalId: doc.id),
                                  ),
                                );
                              },
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Dialogo de confirmación antes de eliminar
                                bool? shouldDelete = await _showDeleteConfirmationDialog(context);
                                if (shouldDelete == true) {
                                  await _firestore.collection("animals").doc(doc.id).delete();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Animal eliminado")));
                                }
                              },
                            ),
                            // Detail button
                            IconButton(
                              icon: const Icon(Icons.info, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalDetailScreen(animalId: doc.id),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAnimalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Método para mostrar el diálogo de confirmación
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text("¿Quieres eliminar este animal? Esta acción no se puede deshacer."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // El usuario cancela
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // El usuario confirma
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
