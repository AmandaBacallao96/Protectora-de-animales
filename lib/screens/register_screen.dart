import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar un usuario con Firebase
  void _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: Colors.red),
      );
      return;
    }

    try {

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );


      await _firestore.collection('usuarios').doc(userCredential.user?.uid).set({
        'nombre': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user?.uid,
      });


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      print("Usuario registrado: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo electrónico ya está en uso.';
      } else {
        message = e.message ?? 'Ocurrió un error. Intenta nuevamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("Crear Cuenta", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Regístrate para empezar", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),


              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre completo"),
              ),
              const SizedBox(height: 10),


              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
              ),
              const SizedBox(height: 10),


              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 20),


              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text("Registrarse", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),


              TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  "¿Ya tienes cuenta? Inicia sesión aquí",
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
