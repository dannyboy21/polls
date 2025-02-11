/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _verificationDigitController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _dniController.text.trim().isEmpty ||
        _verificationDigitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Guardar información en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dni': _dniController.text.trim(),
        'verificationDigit': _verificationDigitController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'usuario',
      });

      // Guardar datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', uid);
      await prefs.setString('name', _nameController.text.trim());
      await prefs.setString('lastName', _lastNameController.text.trim());
      await prefs.setString('dni', _dniController.text.trim());

      // Navegar a Login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: getBottomAppBar(context, "Registro"),
        //title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombres'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: _dniController,
                decoration: InputDecoration(labelText: 'Número de DNI'),
              ),
              TextField(
                controller: _verificationDigitController,
                decoration: InputDecoration(
                    labelText: 'Último dígito del DNI (verificación)'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _verificationDigitController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Método para registrar un nuevo usuario
  Future<void> _register() async {
    // Validar campos vacíos
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _dniController.text.trim().isEmpty ||
        _verificationDigitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Registrar usuario en Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Guardar información del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dni': _dniController.text.trim(),
        'verificationDigit': _verificationDigitController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'usuario', // Rol predeterminado
        'createdAt': FieldValue.serverTimestamp(), // Fecha de creación
      });

      // Guardar datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', uid);
      await prefs.setString('name', _nameController.text.trim());
      await prefs.setString('lastName', _lastNameController.text.trim());
      await prefs.setString('dni', _dniController.text.trim());

      // Navegar a la página de inicio de sesión
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Mostrar error en un cuadro de diálogo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Ha ocurrido un error al registrarse. Verifica los datos ingresados o inténtalo más tarde. \n\nError: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombres'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: _dniController,
                decoration: InputDecoration(labelText: 'Número de DNI'),
              ),
              TextField(
                controller: _verificationDigitController,
                decoration: InputDecoration(
                    labelText: 'Último dígito del DNI (verificación)'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores al cerrar la página
    _nameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    _verificationDigitController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
