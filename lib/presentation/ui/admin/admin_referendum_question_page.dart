import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/top_action_button_widget.dart';
import 'package:my_pwa_app/presentation/utils/colors.dart';

class AdminReferendumQuestionPage extends StatefulWidget {
  @override
  _AdminReferendumQuestionPageState createState() =>
      _AdminReferendumQuestionPageState();
}

class _AdminReferendumQuestionPageState
    extends State<AdminReferendumQuestionPage> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _listNameController = TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // 🔹 Instancia de Firestore

  void _saveReferendumList() async {
    if (_questions.isEmpty || _listNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejectColor,
          content: Text(
            "Debes agregar preguntas y un nombre a la lista",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> formattedQuestions =
          _questions.map((question) {
        return {
          "question": question["question"],
          "options": question["options"],
        };
      }).toList();

      await _firestore.collection("referendumList").add({
        "name": _listNameController.text.trim(),
        "questions": formattedQuestions,
        "createdAt":
            FieldValue.serverTimestamp(), // Guardar con fecha de creación
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.acceptColor,
          content: Text(
            "Lista guardada exitosamente",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

      setState(() {
        _questions.clear();
        _listNameController.clear();
      });
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("❌ Error al guardar la lista: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: AppColors.rejectColor,
            content: Text(
              "Error al guardar la lista: $e",
              style: TextStyle(
                color: Colors.white,
              ),
            )),
      );
    }
  }

  void _showAddQuestionModal({int? index}) {
    final TextEditingController questionController = TextEditingController(
      text: index != null ? _questions[index]['question'] : '',
    );
    final List<TextEditingController> optionControllers = index != null
        ? List<TextEditingController>.from(_questions[index]['options']
            .map((option) => TextEditingController(text: option)))
        : [TextEditingController(), TextEditingController()];
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(index == null ? "Agregar Pregunta" : "Editar Pregunta",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(labelText: "Pregunta"),
                    ),
                    SizedBox(height: 10),
                    Text("Opciones de respuesta (mínimo 2, máximo 5)"),
                    ...optionControllers.map((controller) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(labelText: "Opción"),
                          ),
                        )),
                    if (optionControllers.length < 5)
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            optionControllers.add(TextEditingController());
                          });
                        },
                        child: Text("Agregar Opción"),
                      ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(errorText!,
                            style: TextStyle(color: Colors.red)),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar"),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.pink),
                          ),
                          onPressed: () {
                            setModalState(() {
                              if (questionController.text.isEmpty ||
                                  optionControllers.any((controller) =>
                                      controller.text.isEmpty) ||
                                  optionControllers.length < 2) {
                                errorText =
                                    "Completa todos los campos y al menos 2 opciones";
                              } else {
                                errorText = null;
                              }
                            });

                            if (errorText == null) {
                              setState(() {
                                if (index == null) {
                                  _questions.add({
                                    "question": questionController.text.trim(),
                                    "options": optionControllers
                                        .map((c) => c.text.trim())
                                        .toList(),
                                  });
                                } else {
                                  _questions[index] = {
                                    "question": questionController.text.trim(),
                                    "options": optionControllers
                                        .map((c) => c.text.trim())
                                        .toList(),
                                  };
                                }
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            index == null ? "Agregar" : "Actualizar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Se puede retroceder: ${Navigator.of(context).canPop()}");

    return Scaffold(
        appBar: AppBar(
          bottom: getBottomAppBar(context, "Preguntas de Referéndum:"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TopActionButton(
                  buttonName: "Guardar Lista", onPressed: _saveReferendumList),
            )
          ],
        ),
        floatingActionButton: ElevatedButton(
          onPressed: _showAddQuestionModal,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(), // Hace que el botón sea circular
            padding: EdgeInsets.all(15), // Ajusta el tamaño del botón
            backgroundColor: Colors.pink, // Color del botón
            elevation: 5, // Sombra
          ),
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _listNameController,
                  decoration: InputDecoration(labelText: "Nombre de la Lista"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16.0), // Radio de borde
                        side: const BorderSide(
                          width: 0.2, // Grosor del borde
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 8),
                        title: Text(
                          "${index + 1}) ${_questions[index]["question"]}", // Agrega el número de la pregunta
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              _questions[index]["options"].length, (i) {
                            return Text(
                                "  ${i + 1}. ${_questions[index]["options"][i]}");
                          }),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (String result) {
                            if (result == 'edit') {
                              _showAddQuestionModal(index: index);
                            } else if (result == 'delete') {
                              setState(() => _questions.removeAt(index));
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('Editar'),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
