import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_home_page.dart';
import 'package:my_pwa_app/presentation/ui/admin/user_poll_page.dart';
import 'package:my_pwa_app/presentation/ui/widgets/action_button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  LoginPage({
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? userId;
  String? name;
  String? lastName;
  String? dni;
  bool isAdmin = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadIsAdmin();
    await _loadUserData();

    setState(() {
      _isLoading = false; // Indicador de carga terminado
    });
  }

  Future<void> _loadIsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool adminStatus = prefs.getBool('isAdmin') ?? false;
    print("El valor de isAdmin es: $adminStatus");
    setState(() {
      isAdmin = adminStatus;
    });
  }

  // Cargar los datos de usuario desde SharedPreferences

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('userId');
      name = prefs.getString('name') ?? 'Usuario';
      lastName = prefs.getString('lastName') ?? '';
      dni = prefs.getString('dni') ?? '';
    });

    print(
        "Loaded from SharedPreferences: Name: $name, LastName: $lastName, Dni: $dni");
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
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
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        // Obtener el rol del usuario desde Firestore
        String role = userDoc['role']; // "admin" o "usuario"
        String dni = userDoc['dni'];

        // Guardar en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdmin', role == 'admin');

        setState(() {
          isAdmin = (role == 'admin');
        });

        if (isAdmin) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminHomePage(
                      toggleTheme: widget.toggleTheme,
                      isDarkMode: widget.isDarkMode,
                      isAdmin: true,
                      dni: dni,
                      userId: userCredential.user!.uid,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserPollPage(
                toggleTheme: widget.toggleTheme,
                isDarkMode: widget.isDarkMode,
                isAdmin: false,
                dni: dni,
                userId: userCredential.user!.uid,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se encontró el usuario')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Permite que la pantalla se ajuste al teclado
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Image.asset(
                      "assets/images/votalos.png",
                      height: 240,
                    ),
                  ),
                ),
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        width: 0.5,
                      )),
                  color: widget.isDarkMode
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          FontAwesomeIcons.user,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          // validator: (String? value) {
                          //   if (value!.isEmpty || value == null) {
                          //     return "El campo es obligatorio";
                          //   }
                          // },
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    const Color(0xffbebebe).withOpacity(0.90),
                              ),
                              hintText: 'Correo',
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        width: 0.5,
                      )),
                  color: widget.isDarkMode
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          FontAwesomeIcons.lock,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          obscureText: _obscureText,
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          // validator: (String? value) {
                          //   if (value!.isEmpty || value == null) {
                          //     return "La contraseña es obligatoria";
                          //   }
                          // },
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    const Color(0xffbebebe).withOpacity(0.90),
                              ),
                              hintText: 'Contraseña',
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),

                /*
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                */
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ActionButton(
                          buttonName: 'Ingresar',
                          onPressed: _login,
                        ),
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('¿No tienes una cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
