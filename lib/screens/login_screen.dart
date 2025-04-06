import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    // Comprobar si los campos están vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si la autenticación es exitosa, navegar a HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      print("Usuario autenticado: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      String message = '';

      // Manejar errores específicos de Firebase
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese correo electrónico.';
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña es incorrecta. Intenta de nuevo.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es incorrecto.';
      } else if (e.code == 'user-disabled') {
        message = 'Tu cuenta ha sido deshabilitada. Contacta al soporte.';
      } else {
        message = e.message ?? 'Ocurrió un error. Intenta nuevamente.';
      }

      // Mostrar el mensaje de error en un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
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
              const Text(
                "Protectora de Animales",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.pets, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Inicia sesión para continuar",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

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
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text("Ingresar", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              TextButton(
                onPressed: _navigateToRegister,
                child: const Text(
                  "Si no tienes cuenta, regístrate aquí",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
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

