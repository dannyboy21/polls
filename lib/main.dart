import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_pwa_app/presentation/login/login_page.dart';
import 'package:my_pwa_app/presentation/login/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  /// Cargar el tema almacenado en SharedPreferences
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isLoading = false;
    });
  }

  /// Guardar tema
  void _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  /// Alternar tema
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveTheme(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        hintColor: const Color(0xFFff8c00),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(backgroundColor: Colors.white),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF04d9ff),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color.fromARGB(179, 244, 244, 244)),
        cardTheme: const CardTheme(color: Colors.white),
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Comfortaa-Regular',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pink,
        hintColor: const Color.fromARGB(255, 115, 94, 255),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(backgroundColor: Colors.black),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFff8c00),
        ),
        inputDecorationTheme:
            const InputDecorationTheme(fillColor: Color(0xFF1E1E1E)),
        cardTheme: const CardTheme(color: Color(0xFF1E1E1E)),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF121212)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Comfortaa-Regular',
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'Voting App',

      // ✅ Define las rutas aquí
      initialRoute: '/login',
      routes: {
        '/login': (context) =>
            LoginPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
        '/register': (context) => RegisterPage(),
      },

      // ✅ Muestra una pantalla de carga si los datos aún no están listos
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : LoginPage(
              toggleTheme: _toggleTheme,
              isDarkMode: _isDarkMode,
            ),
/*
      // ✅ Agregamos manejo para la pantalla de carga y LoginPage
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : LoginPage(
              toggleTheme: _toggleTheme,
              isDarkMode: _isDarkMode,
            ),
            */
    );
  }
}
