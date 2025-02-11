import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_pwa_app/presentation/ui/widgets/get_leading_button_widget.dart';
import 'package:my_pwa_app/presentation/ui/widgets/top_action_button_widget.dart';

class AdminCandidateListCreatePage extends StatefulWidget {
  @override
  State<AdminCandidateListCreatePage> createState() =>
      _AdminCandidateListCreatePageState();
}

class _AdminCandidateListCreatePageState
    extends State<AdminCandidateListCreatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _candidates = [];
  final TextEditingController _listNameController = TextEditingController();

  Future<String?> _uploadImage(XFile? imageFile) async {
    if (imageFile == null) {
      print("❌ Error: El archivo de imagen es nulo.");
      return null;
    }

    File file = File(imageFile.path);

    if (!await file.exists()) {
      print(
          "❌ Error: El archivo de imagen no existe en la ruta: ${imageFile.path}");
      return null;
    }

    try {
      print("🚀 Subiendo imagen: ${imageFile.path}");

      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('candidates/${DateTime.now().millisecondsSinceEpoch}.jpg');

      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      firebase_storage.TaskSnapshot snapshot =
          await uploadTask.whenComplete(() => {});

      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("✅ Imagen subida con éxito: $downloadUrl");
      return downloadUrl;
    } catch (e, stackTrace) {
      print("❌ Error al subir imagen: $e");
      print(stackTrace);
      return null;
    }
  }

  void _addOrEditCandidate({int? index}) {
    final titleController = TextEditingController(
        text: index != null ? _candidates[index]["title"] : "");
    final subtitleController = TextEditingController(
        text: index != null ? _candidates[index]["subtitle"] : "");
    XFile? image1 = index != null ? _candidates[index]["image1"] : null;
    XFile? image2 = index != null ? _candidates[index]["image2"] : null;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(index == null ? "Agregar Candidato" : "Editar Candidato",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Partido Politico"),
                  ),
                  TextFormField(
                    controller: subtitleController,
                    decoration:
                        InputDecoration(labelText: "Nombre del Candidato"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            XFile? pickedImage = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setModalState(() {
                                image1 = pickedImage;
                              });
                            }
                          },
                          child: Text("Elegir Logo del Partido"),
                        ),
                      ),
                      if (image1 != null) ...[
                        SizedBox(width: 10),
                        Image.file(File(image1!.path),
                            width: 80, height: 80, fit: BoxFit.cover),
                      ],
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            XFile? pickedImage = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setModalState(() {
                                image2 = pickedImage;
                              });
                            }
                          },
                          child: Text("Elegir Imagen del Candidato"),
                        ),
                      ),
                      if (image2 != null) ...[
                        SizedBox(width: 10),
                        Image.file(File(image2!.path),
                            width: 80, height: 80, fit: BoxFit.cover),
                      ],
                    ],
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          Text(errorText!, style: TextStyle(color: Colors.red)),
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
                            backgroundColor: WidgetStatePropertyAll(
                          Colors.pink,
                        )),
                        onPressed: () {
                          if (titleController.text.isEmpty ||
                              subtitleController.text.isEmpty ||
                              image1 == null ||
                              image2 == null) {
                            setModalState(() {
                              errorText = "Completa todos los campos";
                            });
                            return;
                          }
                          setState(() {
                            if (index == null) {
                              _candidates.add({
                                "title": titleController.text.trim(),
                                "subtitle": subtitleController.text.trim(),
                                "image1": image1,
                                "image2": image2,
                              });
                            } else {
                              _candidates[index] = {
                                "title": titleController.text.trim(),
                                "subtitle": subtitleController.text.trim(),
                                "image1": image1,
                                "image2": image2,
                              };
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          index == null ? "Agregar" : "Actualizar",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveCandidateList() async {
    if (_candidates.isEmpty || _listNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Debes agregar candidatos y un nombre a la lista")),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> formattedCandidates = [];

      for (var candidate in _candidates) {
        // ✅ Subir imágenes a Firebase Storage y obtener URL
        String? imageUrl1 = await _uploadImage(candidate["image1"]);
        String? imageUrl2 = await _uploadImage(candidate["image2"]);

        if (imageUrl1 == null || imageUrl2 == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al subir imágenes")),
          );
          return;
        }

        formattedCandidates.add({
          "title": candidate["title"],
          "subtitle": candidate["subtitle"],
          "image1": imageUrl1, // ✅ Guardamos URL en vez de `XFile`
          "image2": imageUrl2,
        });
      }

      // ✅ Guardar en Firestore
      await _firestore.collection("candidateLists").add({
        "name": _listNameController.text.trim(),
        "candidates": formattedCandidates,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // ✅ Notificación y limpieza
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lista de candidatos guardada exitosamente")),
      );

      setState(() {
        _candidates.clear();
        _listNameController.clear();
      });
    } catch (e) {
      print("❌ Error al guardar la lista: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar la lista: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TopActionButton(
              buttonName: "Guardar Lista",
              onPressed: _saveCandidateList,
            ),
          )
        ],
        bottom: getBottomAppBar(context, "Crear listas:"),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _addOrEditCandidate,
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
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  final candidate = _candidates[index];
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 6),
                    title: Text(candidate["title"]),
                    subtitle: Text(candidate["subtitle"]),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10), // Bordes redondeados
                          child: Image.file(
                            File(candidate["image1"].path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 2), // Espaciado entre imágenes
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10), // Bordes redondeados
                          child: Image.file(
                            File(candidate["image2"].path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (String result) {
                        if (result == 'edit') {
                          _addOrEditCandidate(
                              index: _candidates.indexOf(candidate));
                        } else if (result == 'delete') {
                          setState(() => _candidates.remove(candidate));
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
