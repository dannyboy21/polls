import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pwa_app/data/firestore_services.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_poll_create_page.dart';
import 'package:my_pwa_app/presentation/ui/widgets/action_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';

class AdminPollListPage extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final bool isDarkMode;
  final String dni;
  final Function toggleTheme;

  AdminPollListPage({
    required this.isAdmin,
    required this.isDarkMode,
    required this.userId,
    required this.dni,
    required this.toggleTheme,
  });

  @override
  State<AdminPollListPage> createState() => _AdminPollListPageState();
}

class _AdminPollListPageState extends State<AdminPollListPage> {
  final FirestoreService _pollFirestoreService =
      FirestoreService(collection: 'polls');

  String _selectedStatus = 'Todas';

  final List<String> _orderStatusFilters = [
    'Todas',
    'En curso',
    'Finalizada',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: getBottomAppBar(
          context,
          widget.isAdmin ? "Encuestas (Admin)" : "Encuestas",
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? ActionButton(
              buttonName: "Crear encuesta",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPollCreatePage(),
                  ),
                );
              },
            )
          : null,
      body: Column(
        children: [
          // Dropdown para filtrar encuestas por estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: _orderStatusFilters
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const Icon(Icons.search, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('polls')
                  .orderBy('creationDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aún no hay encuestas disponibles.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                List<QueryDocumentSnapshot> polls = snapshot.data!.docs;

                // Filtrar encuestas según el estado
                if (_selectedStatus != 'Todas') {
                  polls = polls
                      .where((poll) =>
                          (poll.data() as Map<String, dynamic>)['status'] ==
                          _selectedStatus)
                      .toList();
                }

                return ListView.builder(
                  itemCount: polls.length,
                  itemBuilder: (context, index) {
                    final pollData = polls[index];

                    return _buildPollItem(pollData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Método para construir un item de encuesta correctamente
  Widget _buildPollItem(QueryDocumentSnapshot pollData) {
    final poll = pollData.data() as Map<String, dynamic>;

    String pollName = poll["pollName"] ?? "Sin título";
    String pollType = poll["pollType"] ?? "Desconocido";
    String status = poll["status"] ?? "Sin estado";

    // Manejo de fechas
    String creationDate = poll['creationDate'] != null
        ? DateFormat('dd-MM-yyyy')
            .format((poll['creationDate'] as Timestamp).toDate())
        : 'Fecha desconocida';
    String maxCompletionDate = poll['maxCompletionDate'] != null
        ? DateFormat('dd-MM-yyyy')
            .format((poll['maxCompletionDate'] as Timestamp).toDate())
        : 'Fecha de cierre desconocida';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Radio de borde
          side: const BorderSide(
            width: 0.2, // Grosor del borde
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent, // Ocultar líneas
          ),
          child: ExpansionTile(
            title: Text(
              pollName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tipo: $pollType"),
                Text("Estado: $status"),
                Text("Creación: $creationDate"),
                Text("Cierre: $maxCompletionDate"),
              ],
            ),
            children: pollType == "Referéndum"
                ? _buildReferendumContent(poll)
                : [_buildCandidatePollContent(poll)],
          ),
        ),
      ),
    );
  }

  /// 🔹 Construye el contenido de una encuesta de Referéndum con alineación correcta
  List<Widget> _buildReferendumContent(Map<String, dynamic> poll) {
    List<dynamic> questions = poll["questions"] ?? [];

    return questions.asMap().entries.map((entry) {
      int questionIndex = entry.key + 1; // Para numerar desde 1
      Map<String, dynamic> questionData = entry.value;

      String question = questionData["question"] ?? "Pregunta sin definir";
      List<String> options = questionData["options"] is List
          ? List<String>.from(questionData["options"])
          : [];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, //con esto las opciones de respuesta van a la izquierda
          children: [
            // 🔹 Pregunta numerada en negrita
            Row(
              children: [
                Text(
                  "$questionIndex) $question",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  //  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 4), // Espacio entre pregunta y opciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options.asMap().entries.map((optEntry) {
                int optionIndex = optEntry.key + 1; // Para numerar desde 1
                String option = optEntry.value;

                return Padding(
                  padding: const EdgeInsets.only(
                      left: 12, top: 2), // Sangría de las opciones
                  child: Text(
                    "$optionIndex. $option",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6), // Espacio entre preguntas
            Divider(thickness: 0.5, color: Colors.grey[400]),
            SizedBox(height: 4),
          ],
        ),
      );
    }).toList();
  }

  /// 🔹 Construye el contenido de una encuesta de Candidatos con datos actualizados
  Widget _buildCandidatePollContent(Map<String, dynamic> poll) {
    return FutureBuilder<List<dynamic>>(
      future: _getUpdatedCandidates(poll["pollType"]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<dynamic> candidates = snapshot.data ?? [];

        return Column(
          children: candidates.map((candidate) {
            return ListTile(
              title: Text(candidate["title"] ?? "Sin título"),
              subtitle: Text(candidate["subtitle"] ?? ""),
              leading: candidate["image1"] != null
                  ? Image.network(candidate["image1"], width: 50, height: 50)
                  : SizedBox.shrink(),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<dynamic>> _getUpdatedCandidates(String pollType) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("candidateLists")
        .where("name", isEqualTo: pollType)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs.isNotEmpty ? snapshot.docs.first["candidates"] : [];
  }
}
