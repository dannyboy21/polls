import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pwa_app/presentation/ui/widgets/action_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';
import 'package:my_pwa_app/presentation/utils/colors.dart';

class AdminPollCreatePage extends StatefulWidget {
  @override
  State<AdminPollCreatePage> createState() => _AdminPollCreatePageState();
}

class _AdminPollCreatePageState extends State<AdminPollCreatePage> {
  DateTime? maxCompletionDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _options = [];
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _pollNameController =
      TextEditingController(); // Nuevo controlador para el título
  String?
      _selectedPollType; // Cambiado a `null` para que no tenga selección inicial

  Future<void> _loadCandidates() async {
    if (_selectedPollType == null) return; // No ejecutar si no hay selección

    _options.clear();
    _questions.clear();

    try {
      if (_selectedPollType == "Referéndum") {
        // 🔹 Cargar preguntas desde `referendumList`
        QuerySnapshot snapshot =
            await _firestore.collection("referendumList").get();

        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            List<dynamic> questions = doc["questions"] ?? [];

            for (var q in questions) {
              if (q is Map<String, dynamic>) {
                _questions.add({
                  "question": q["question"] ?? "Pregunta sin definir",
                  "options": q["options"] is List
                      ? List<String>.from(q["options"])
                      : [],
                });
              }
            }
          }
        }
      } else {
        // 🔹 Cargar candidatos desde `candidateLists`
        QuerySnapshot snapshot = await _firestore
            .collection("candidateLists")
            .where("name", isEqualTo: _selectedPollType)
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<dynamic> candidates = snapshot.docs.first["candidates"] ?? [];

          for (var candidate in candidates) {
            if (candidate is Map<String, dynamic>) {
              _options.add({
                "title": candidate["title"] ?? "Sin título",
                "subtitle": candidate["subtitle"] ?? "",
                "image1": candidate["image1"] ?? "",
                "image2": candidate["image2"] ?? "",
              });
            }
          }
        }
      }

      setState(() {}); // ✅ Refrescar la UI solo después de cargar datos
    } catch (e) {
      print("❌ Error cargando datos: $e");
    }
  }

  /// **🔹 Método para cargar datos según el tipo de encuesta**
/*
  Future<void> _loadCandidates() async {
    if (_selectedPollType == null) return; // Evita ejecutar si no hay selección

    _options.clear();
    _questions.clear();

    try {
      if (_selectedPollType == "Referéndum") {
        // 🔹 Cargar preguntas desde `referendumList`
        QuerySnapshot snapshot =
            await _firestore.collection("referendumList").get();

        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            List<dynamic> questions = doc["questions"] ?? [];

            for (var q in questions) {
              _questions.add({
                "question": q["question"],
                "options": List<String>.from(q["options"]),
              });
            }
          }
        }
      } else {
        // 🔹 Cargar candidatos desde `candidateLists`
        QuerySnapshot snapshot = await _firestore
            .collection("candidateLists")
            .where("name", isEqualTo: _selectedPollType)
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<dynamic> candidates = snapshot.docs.first["candidates"] ?? [];
          for (var candidate in candidates) {
            _options.add({
              "title": candidate["title"],
              "subtitle": candidate["subtitle"],
              "image1": candidate["image1"],
              "image2": candidate["image2"],
            });
          }
        }
      }

      setState(() {}); // ✅ Refrescar la UI
    } catch (e) {
      print("❌ Error cargando datos: $e");
    }
  }
*/

  void resetFields() {
    _options.clear();
    setState(() {
      maxCompletionDate = null;
    });
  }

  /// **🔹 Selector de fecha**
  Future<void> _pickMaxCompletionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != maxCompletionDate) {
      setState(() {
        maxCompletionDate = picked;
      });
    }
  }

  /// **🔹 Guardar Encuesta**
  Future<void> _savePoll() async {
    if (_pollNameController.text.isEmpty ||
        _selectedPollType == null ||
        maxCompletionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Completa todos los campos antes de enviar",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.rejectColor,
        ),
      );
      return;
    }

    if ((_selectedPollType == "Referéndum" && _questions.isEmpty) ||
        (_selectedPollType != "Referéndum" && _options.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Debes agregar candidatos o preguntas antes de continuar",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.rejectColor,
        ),
      );
      return;
    }

    try {
      Map<String, dynamic> pollData = {
        "pollName":
            _pollNameController.text.trim(), // Guardar el nombre de la encuesta
        "pollType": _selectedPollType,
        "maxCompletionDate": maxCompletionDate,
        "status": "En curso",
        "creationDate": FieldValue.serverTimestamp(),
      };

      if (_selectedPollType != "Referéndum") {
        pollData["options"] = _options
            .map((option) => {
                  "title": option["title"],
                  "subtitle": option["subtitle"],
                  "image1": option["image1"],
                  "image2": option["image2"],
                  "votes": 0,
                })
            .toList();
      } else {
        pollData["questions"] = _questions
            .map((question) => {
                  "question": question["question"],
                  "options": question["options"],
                })
            .toList();
      }

      await _firestore.collection("polls").add(pollData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Encuesta guardada exitosamente",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.acceptColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("❌ Error al guardar la encuesta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al guardar la encuesta",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.rejectColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: getBottomAppBar(context, "Crear encuesta:"),
      ),
      floatingActionButton: ActionButton(
        onPressed: _selectedPollType == null ? null : _savePoll,
        buttonName: "Enviar encuesta",
      ),
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _pollNameController,
                decoration: InputDecoration(
                  labelText: "Título de la Encuesta",
                  hintText: "Ingrese el nombre de la encuesta",
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  maxCompletionDate == null
                      ? "Seleccionar fecha de cierre para la encuesta"
                      : "Cierre de encuesta: ${DateFormat.yMMMd().format(maxCompletionDate!)}",
                ),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: _pickMaxCompletionDate,
              ),
            ),

            SizedBox(height: 20),

            /// **🔹 Dropdown para seleccionar tipo de encuesta**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedPollType,
                decoration: InputDecoration(
                  labelText: "Elige el tipo de Encuesta",
                  hintText: "Selecciona el tipo de encuesta",
                ),
                items: [
                  "Presidencial",
                  "Congresal",
                  "Parlamento Andino",
                  "Referéndum"
                ]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPollType = value;
                  });
                  _loadCandidates();
                },
              ),

              /*
              DropdownButtonFormField<String>(
                value: _selectedPollType,
                decoration: InputDecoration(
                  labelText: "Elige el tipo de Encuesta",
                  hintText: "Selecciona el tipo de encuesta",
                ),
                items: [
                  "Presidencial",
                  "Congresal",
                  "Parlamento Andino",
                  "Referéndum"
                ]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPollType = value;
                  });
                  _loadCandidates();
                },
              ),
            */
            ),

            SizedBox(height: 20),

            /// **🔹 Mostrar candidatos/preguntas según selección**
            if (_selectedPollType != null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      _selectedPollType == "Referéndum"
                          ? "Preguntas"
                          : "Candidatos",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),

              // 🔹 Si es Presidencial o Municipal, mostrar candidatos con imágenes
              if (_selectedPollType == "Presidencial") ...[
                for (var option in _options)
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 6),
                    title: Text(option["title"]),
                    subtitle: Text(option["subtitle"]),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(option["image1"],
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        SizedBox(width: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(option["image2"],
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
              ],

              // 🔹 Si es Congresal o Parlamento Andino, mostrar en formato ListTile
              if (_selectedPollType == "Congresal" ||
                  _selectedPollType == "Parlamento Andino") ...[
                for (var option in _options)
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 6),
                    title: Text(option["title"]),
                    //subtitle: Text(option["subtitle"]),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(option["image1"],
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
/*
                        SizedBox(width: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(option["image2"],
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        */
                      ],
                    ),
                  ),
              ],

              // 🔹 Si es Referéndum, mostrar preguntas en formato Card
              if (_selectedPollType == "Referéndum") ...[
                for (int index = 0; index < _questions.length; index++)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: const BorderSide(width: 0.2),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 8),
                      title: Text(
                        "${index + 1}) ${_questions[index]["question"]}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            _questions[index]["options"].length,
                            (i) => Text(
                                "  ${i + 1}. ${_questions[index]["options"][i]}")),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
