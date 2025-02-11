/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pwa_app/data/firestore_services.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_poll_create_page.dart';
import 'package:my_pwa_app/presentation/ui/widgets/action_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/poll_widget.dart';

class UserPollPage extends StatefulWidget {
  //final int unitsNumber;
  final bool isAdmin;
  final String userId;
  final bool isDarkMode;
  final String dni;
  final Function toggleTheme;

  UserPollPage({
    // required this.unitsNumber,
    required this.isAdmin,
    required this.isDarkMode,
    required this.userId,
    required this.dni,
    required this.toggleTheme,
  });

  @override
  State<UserPollPage> createState() => _UserPollPageState();
}

class _UserPollPageState extends State<UserPollPage> {
  final FirestoreService _packagesFirestoreService =
      FirestoreService(collection: 'packages');
  String _selectedStatus = 'Todas';

  final List<String> _orderStatusFilters = [
    'Todas',
    'En curso',
    'Finalizada',
  ];

  bool darkValue = true;
  void toggleIcon() {
    setState(() {
      darkValue = !darkValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    var textStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14);

    return Scaffold(
      appBar: AppBar(
        bottom: getBottomAppBar(
          context,
          widget.isAdmin! ? "Encuestas (Admin)" : "Encuestas",
        ),
        actions: [
          IconButton(
            icon: widget.isDarkMode
                ? const Icon(
                    Icons.brightness_7,
                    color: Colors.amberAccent,
                  )
                : const Icon(
                    Icons.brightness_3,
                    color: Colors.lightBlue,
                  ),
            // onPressed: toggleTheme(),
            onPressed: () {
              widget.toggleTheme();
              toggleIcon();
            },
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin!
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
          // Dropdown y Barra de Filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12.0),
                    elevation: 1,
                    style: textStyle,
                    value: _selectedStatus,
                    items: _orderStatusFilters
                        .map((e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.search,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('polls').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aún no hay encuestas disponibles.",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
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

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: polls.length,
                    itemBuilder: (context, index) {
                      final QueryDocumentSnapshot pollData = polls[index];

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('polls')
                            .doc(pollData.id)
                            .snapshots(),
                        builder: (context, pollSnapshot) {
                          if (!pollSnapshot.hasData ||
                              !pollSnapshot.data!.exists) {
                            return const Center(
                              child: Text("Encuesta no disponible"),
                            );
                          }

                          final poll =
                              pollSnapshot.data!.data() as Map<String, dynamic>;
                          List<String> options =
                              List<String>.from(poll['options'] ?? []);
                          List<int> votes =
                              (poll['votes'] != null && poll['votes'] is List)
                                  ? List<int>.from(poll['votes'])
                                  : List<int>.filled(options.length, 0);

                          // Fechas
                          String startingDate = poll['creationDate'] != null
                              ? DateFormat('dd-MM-yyyy').format(
                                  (poll['creationDate'] as Timestamp).toDate())
                              : 'Sin fecha';
                          String startingTime = poll['creationDate'] != null
                              ? DateFormat('hh:mm a').format(
                                  (poll['creationDate'] as Timestamp).toDate())
                              : '';
                          String endingDate = poll['maxCompletionDate'] != null
                              ? DateFormat('dd-MM-yyyy').format(
                                  (poll['maxCompletionDate'] as Timestamp)
                                      .toDate())
                              : 'Sin fecha de cierre';
                          String endingTime = poll['maxCompletionDate'] != null
                              ? DateFormat('hh:mm a').format(
                                  (poll['maxCompletionDate'] as Timestamp)
                                      .toDate())
                              : '';

                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('polls')
                                .doc(pollData.id)
                                .collection('userVotes')
                                .doc(widget.userId)
                                .snapshots(),
                            builder: (context, userVoteSnapshot) {
                              bool hasVoted =
                                  userVoteSnapshot.data?.exists ?? false;
                              int? selectedVoteIndex;

                              if (hasVoted &&
                                  userVoteSnapshot.data!.data() != null) {
                                final data = userVoteSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                selectedVoteIndex = data['voteIndex'];
                              }

                              return PollWidget(
                                pollId: pollData.id,
                                unitsNumber: 7,
                                isDarkMode: widget.isDarkMode,
                                isAdmin: widget.isAdmin!,
                                title: poll['question'] ?? 'Sin título',
                                answer: poll['totalVotes']?.toString() ?? '0',
                                startingDate: startingDate,
                                startingTime: startingTime,
                                endingDate: endingDate,
                                endingTime: endingTime,
                                status: poll['status'] ?? 'Sin estado',
                                options: options,
                                votes: votes,
                                hasVoted: hasVoted,
                                onVote: (voteIndex) async {
                                  if (!hasVoted &&
                                      voteIndex >= 0 &&
                                      voteIndex < votes.length) {
                                    final pollDoc = FirebaseFirestore.instance
                                        .collection('polls')
                                        .doc(pollData.id);

                                    final pollSnapshot = await pollDoc.get();
                                    if (pollSnapshot.exists) {
                                      final pollData = pollSnapshot.data()
                                          as Map<String, dynamic>;
                                      List<int> updatedVotes = List<int>.from(
                                          pollData['votes'] ?? []);

                                      updatedVotes[voteIndex] += 1;

                                      // Actualizar Firestore
                                      await pollDoc
                                          .update({'votes': updatedVotes});

                                      // Registrar el voto del usuario
                                      await pollDoc
                                          .collection('userVotes')
                                          .doc(widget.userId)
                                          .set({
                                        'voted': true,
                                        'unitName': widget.dni,
                                        'voteIndex': voteIndex,
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }
                                  }
                                },
                                selectedVoteIndex: selectedVoteIndex,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pwa_app/data/firestore_services.dart';
import 'package:my_pwa_app/presentation/ui/admin/admin_poll_create_page.dart';
import 'package:my_pwa_app/presentation/ui/widgets/action_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';

class UserPollPage extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final bool isDarkMode;
  final String dni;
  final Function toggleTheme;

  UserPollPage({
    required this.isAdmin,
    required this.isDarkMode,
    required this.userId,
    required this.dni,
    required this.toggleTheme,
  });

  @override
  State<UserPollPage> createState() => _UserPollPageState();
}

class _UserPollPageState extends State<UserPollPage> {
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
        actions: [
          IconButton(
            icon: widget.isDarkMode
                ? const Icon(Icons.brightness_7, color: Colors.amberAccent)
                : const Icon(Icons.brightness_3, color: Colors.lightBlue),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
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
