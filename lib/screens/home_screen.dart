import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'animals_screen.dart';
import 'volunteer_screen.dart';
import 'events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AnimalsScreen(),
    const VolunteerScreen(),
    const EventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Animales"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Voluntariado"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Eventos"),
        ],
      ),
    );
  }
}
