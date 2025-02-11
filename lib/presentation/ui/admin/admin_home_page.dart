import 'package:flutter/material.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_candidate_list_create_page.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_candidate_list_page.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_poll_create_page.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_poll_list_page.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_referendum_question_page.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';

class AdminHomePage extends StatelessWidget {
  final bool isAdmin;
  final String userId;
  final bool isDarkMode;
  final String dni;
  final Function toggleTheme;

  AdminHomePage({
    required this.isAdmin,
    required this.isDarkMode,
    required this.userId,
    required this.dni,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: getBottomAppBar(context, '¿Qué deseas hacer hoy?'),
        actions: [
          IconButton(
            icon: isDarkMode
                ? const Icon(Icons.brightness_7, color: Colors.amberAccent)
                : const Icon(Icons.brightness_3, color: Colors.lightBlue),
            onPressed: () {
              toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard('Crear Listas de Candidatos', Icons.list, context,
                      AdminCandidateListCreatePage()),
                  _buildCard('Gestionar Lista de Candidatos', Icons.people,
                      context, AdminCandidateListPage()),
                  _buildCard('Gestionar Lista de Referéndum', Icons.list,
                      context, AdminReferendumQuestionPage()),
                  _buildCard('Crear Encuesta', Icons.create, context,
                      AdminPollCreatePage()),
                  _buildCard(
                      'Ver Encuestas',
                      Icons.poll,
                      context,
                      AdminPollListPage(
                        toggleTheme: toggleTheme,
                        isDarkMode: isDarkMode,
                        isAdmin: true,
                        dni: dni,
                        userId: userId,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String title, IconData icon, BuildContext context, Widget goTo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => goTo),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Radio de borde
          side: const BorderSide(
            width: 0.2, // Grosor del borde
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
