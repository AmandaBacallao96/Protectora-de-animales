import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Cambia esto por la pantalla de inicio de tu aplicación.
import 'login_screen.dart'; // Cambia esto por la pantalla de login de tu aplicación.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método de validación de correo electrónico
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // Función para registrar un nuevo usuario
  void _register() async {
    // Validar que los campos no estén vacíos
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: Colors.red),
      );
      return;
    }

    // Validar el formato del correo electrónico
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un correo válido'), backgroundColor: Colors.red),
      );
      return;
    }

    // Validar que la contraseña tenga al menos 8 caracteres
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres'), backgroundColor: Colors.red),
      );
      return;
    }

    // Validar que la contraseña contenga al menos una mayúscula y un número
    final password = _passwordController.text.trim();
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(password) ||
        !RegExp(r'(?=.*?[0-9])').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe incluir al menos una letra mayúscula y un número'), backgroundColor: Colors.red),
      );
      return;
    }

    // Crear el usuario con Firebase Authentication
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar los datos del usuario en Firestore
      await _firestore.collection('usuarios').doc(userCredential.user?.uid).set({
        'nombre': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user?.uid,
      });

      // Redirigir a la pantalla de inicio (HomeScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      print("Usuario registrado: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      String message = '';

      // Manejo de excepciones por error en Firebase
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo electrónico ya está en uso.';
      } else {
        message = e.message ?? 'Ocurrió un error. Intenta nuevamente.';
      }

      // Mostrar mensaje de error en pantalla
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  // Navegar a la pantalla de login si el usuario ya tiene cuenta
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

              // Campo de nombre
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre completo"),
              ),
              const SizedBox(height: 10),

              // Campo de correo electrónico
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
              ),
              const SizedBox(height: 10),

              // Campo de contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 20),

              // Botón para registrarse
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

              // Enlace para ir a la pantalla de login
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
