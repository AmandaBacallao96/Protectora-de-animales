import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'animals_screen.dart';
import 'event_screen.dart';
import 'login_screen.dart';
import 'volunteer_screen.dart';
import 'adoption_requests_screen.dart';
import 'sponsors_screen.dart';  // Importar la nueva pantalla

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AnimalsScreen(),
    const VolunteerScreen(),
    const EventsScreen(),
    const AdoptionRequestScreen(),
    const SponsorshipsScreen(),  // Añadir la nueva pantalla de padrinos
  ];

  void _signOut() async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Cerrar sesión", style: TextStyle(color: Colors.green)),
        content: const Text("¿Estás seguro de que deseas cerrar sesión?", style: TextStyle(color: Colors.black54)),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Aceptar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          "Protectora de Animales",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.green[500],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 5,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets, size: screenWidth * 0.07),
            label: "Animales",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism, size: screenWidth * 0.07),
            label: "Voluntariado",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: screenWidth * 0.07),
            label: "Eventos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: screenWidth * 0.07),
            label: "Adopciones",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: screenWidth * 0.07),  // Icono para padrinos
            label: "Padrinos",
          ),
        ],
      ),
    );
  }
}
