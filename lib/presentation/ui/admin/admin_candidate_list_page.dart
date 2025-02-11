import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class AdminCandidateListPage extends StatefulWidget {
  @override
  State<AdminCandidateListPage> createState() => _AdminCandidateListPageState();
}

class _AdminCandidateListPageState extends State<AdminCandidateListPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  TabController? _tabController; // ✅ Hacerlo nullable
  List<String> _categories = [];
  bool _isLoading = true; // ✅ Para evitar errores de inicialización

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(length: _categories.length, vsync: this);
    _fetchCategories();
  }

  /// **🔹 Obtener nombres únicos de los tabs desde Firestore**
  Future<void> _fetchCategories() async {
    QuerySnapshot snapshot =
        await _firestore.collection("candidateLists").get();

    List<String> categories = snapshot.docs
        .map((doc) => doc["name"].toString())
        .toSet() // Eliminar duplicados
        .toList();

    if (mounted) {
      setState(() {
        _categories = categories;
        _tabController = TabController(length: _categories.length, vsync: this);
        _isLoading = false; // ✅ Marcar que terminó de cargar
      });
    }
  }

  /// **🔹 Obtener listas de candidatos en tiempo real según la categoría**
  Stream<QuerySnapshot> _getCandidateLists(String category) {
    return _firestore
        .collection("candidateLists")
        .where("name", isEqualTo: category)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// **🔹 Subir imagen a Firebase Storage**
  Future<String?> _uploadImage(XFile? imageFile) async {
    if (imageFile == null) return null;
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('candidates/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Error al subir imagen: $e");
      return null;
    }
  }

  /// **🔹 Agregar o Editar Candidato**
  void _addOrEditCandidate(String category,
      {String? listId, Map<String, dynamic>? candidate}) {
    final titleController =
        TextEditingController(text: candidate?["title"] ?? "");
    final subtitleController =
        TextEditingController(text: candidate?["subtitle"] ?? "");
    XFile? image1, image2;
    String? imageUrl1 = candidate?["image1"];
    String? imageUrl2 = candidate?["image2"];
    bool isLoading = false;

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
                  Text(
                    candidate == null
                        ? "Agregar Candidato"
                        : "Editar Candidato",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Partido Politico"),
                  ),
                  if (category != "Congresal" &&
                      category != "Parlamento Andino")
                    TextFormField(
                      controller: subtitleController,
                      decoration:
                          InputDecoration(labelText: "Nombre del Candidato"),
                    ),

                  SizedBox(height: 10),

                  /// 🔹 Mostrar SIEMPRE la opción de elegir logo del partido
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            XFile? pickedImage = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setModalState(() => image1 = pickedImage);
                            }
                          },
                          child: Text("Elegir Logo del Partido"),
                        ),
                      ),
                      if (image1 != null)
                        Image.file(File(image1!.path), width: 80, height: 80)
                      else if (imageUrl1 != null)
                        Image.network(imageUrl1!, width: 80, height: 80),
                    ],
                  ),

                  SizedBox(height: 10),

                  /// 🔹 Mostrar el campo de imagen del candidato SOLO si NO es "Congresal" o "Parlamento Andino"
                  if (category != "Congresal" &&
                      category != "Parlamento Andino")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              XFile? pickedImage = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage != null) {
                                setModalState(() => image2 = pickedImage);
                              }
                            },
                            child: Text("Elegir Imagen del Candidato"),
                          ),
                        ),
                        if (image2 != null)
                          Image.file(File(image2!.path), width: 80, height: 80)
                        else if (imageUrl2 != null)
                          Image.network(imageUrl2!, width: 80, height: 80),
                      ],
                    ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.pink)),
                    onPressed: () async {
                      if (isLoading) return;
                      setModalState(() => isLoading = true);

                      if (image1 != null) {
                        imageUrl1 = await _uploadImage(image1);
                      }
                      if (image2 != null) {
                        imageUrl2 = await _uploadImage(image2);
                      }

                      Map<String, dynamic> newCandidate = {
                        "title": titleController.text.trim(),
                        "subtitle": subtitleController.text.trim(),
                        "image1": imageUrl1,
                      };

                      // 🔹 Solo guardar `image2` si no es "Congresal" o "Parlamento Andino"
                      if (category != "Congresal" &&
                          category != "Parlamento Andino") {
                        newCandidate["image2"] = imageUrl2;
                      }

                      if (candidate == null) {
                        await _firestore.collection("candidateLists").add({
                          "name": category,
                          "createdAt": FieldValue.serverTimestamp(),
                          "candidates": [newCandidate],
                        });
                      } else {
                        await _firestore
                            .collection("candidateLists")
                            .doc(listId)
                            .update({
                          "candidates": FieldValue.arrayRemove([candidate]),
                        });

                        await _firestore
                            .collection("candidateLists")
                            .doc(listId)
                            .update({
                          "candidates": FieldValue.arrayUnion([newCandidate]),
                        });
                      }

                      Navigator.pop(context);
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(candidate == null ? "Agregar" : "Actualizar",
                            style: TextStyle(color: Colors.white)),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// **🔹 Mostrar modal de confirmación antes de eliminar**
  void _showDeleteConfirmationDialog(
      String listId, Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar este candidato?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancelar
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Cerrar el modal
                _deleteCandidate(listId, candidate); // Eliminar candidato
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// **🔹 Eliminar candidato individualmente**
  void _deleteCandidate(String listId, Map<String, dynamic> candidate) async {
    await _firestore.collection("candidateLists").doc(listId).update({
      "candidates": FieldValue.arrayRemove([candidate])
    });
  }

  /// **🔹 Agregar Candidato a una lista existente**
  void _addCandidate(String category, String listId) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    XFile? image1, image2;
    bool isLoading = false;
    String? errorMessage;

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
                  Text("Agregar Candidato",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  /// 🔹 Campo que siempre se muestra (Partido Político)
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Partido Político"),
                  ),

                  /// 🔹 Mostrar el campo "Nombre del Candidato" SOLO si NO es "Congresal" o "Parlamento Andino"
                  if (category != "Congresal" &&
                      category != "Parlamento Andino")
                    TextFormField(
                      controller: subtitleController,
                      decoration:
                          InputDecoration(labelText: "Nombre del Candidato"),
                    ),

                  SizedBox(height: 10),

                  /// 🔹 Siempre mostrar el botón para elegir el logo del partido
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            XFile? pickedImage = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setModalState(() => image1 = pickedImage);
                            }
                          },
                          child: Text("Elegir Logo del Partido"),
                        ),
                      ),
                      if (image1 != null)
                        Image.file(File(image1!.path), width: 80, height: 80),
                    ],
                  ),

                  SizedBox(height: 10),

                  /// 🔹 Mostrar el campo de imagen del candidato SOLO si NO es "Congresal" o "Parlamento Andino"
                  if (category != "Congresal" &&
                      category != "Parlamento Andino")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              XFile? pickedImage = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage != null) {
                                setModalState(() => image2 = pickedImage);
                              }
                            },
                            child: Text("Elegir Imagen del Candidato"),
                          ),
                        ),
                        if (image2 != null)
                          Image.file(File(image2!.path), width: 80, height: 80),
                      ],
                    ),

                  SizedBox(height: 10),

                  /// 🔹 Mostrar mensaje de error si los campos están vacíos
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.pink)),
                    onPressed: () async {
                      if (isLoading) return;

                      // 🔹 Validar que los campos no estén vacíos
                      if (titleController.text.trim().isEmpty ||
                          (category != "Congresal" &&
                              category != "Parlamento Andino" &&
                              subtitleController.text.trim().isEmpty) ||
                          image1 == null ||
                          (category != "Congresal" &&
                              category != "Parlamento Andino" &&
                              image2 == null)) {
                        setModalState(() {
                          errorMessage =
                              "Por favor, completa todos los campos.";
                        });
                        return;
                      }

                      setModalState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      String? imageUrl1 = await _uploadImage(image1);
                      String? imageUrl2 = image2 != null
                          ? await _uploadImage(image2)
                          : null; // Si image2 es null, la imagen no se sube

                      if (imageUrl1 == null ||
                          (category != "Congresal" &&
                              category != "Parlamento Andino" &&
                              imageUrl2 == null)) {
                        setModalState(() {
                          isLoading = false;
                          errorMessage =
                              "Error al subir imágenes. Intenta de nuevo.";
                        });
                        return;
                      }

                      Map<String, dynamic> newCandidate = {
                        "title": titleController.text.trim(),
                        "image1": imageUrl1,
                      };

                      // 🔹 Agregar el campo "subtitle" SOLO si NO es "Congresal" o "Parlamento Andino"
                      if (category != "Congresal" &&
                          category != "Parlamento Andino") {
                        newCandidate["subtitle"] =
                            subtitleController.text.trim();
                      }

                      // 🔹 Agregar `image2` SOLO si NO es "Congresal" o "Parlamento Andino"
                      if (category != "Congresal" &&
                          category != "Parlamento Andino") {
                        newCandidate["image2"] = imageUrl2;
                      }

                      // 🔹 Agregar candidato a la lista existente en Firestore
                      await _firestore
                          .collection("candidateLists")
                          .doc(listId)
                          .update({
                        "candidates": FieldValue.arrayUnion([newCandidate]),
                      });

                      Navigator.pop(context);
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            "Agregar Candidato",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gestionar Listas:"),
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _categories.isNotEmpty && _tabController != null
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(50),
                      child: TabBar(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        tabAlignment: TabAlignment.start,
                        controller: _tabController,
                        isScrollable:
                            true, // 🔹 Permite desplazamiento horizontal si hay muchos tabs
                        indicatorSize: TabBarIndicatorSize
                            .label, // 🔹 Ajusta el tamaño del indicador
                        labelPadding: EdgeInsets.symmetric(
                            horizontal: 12), // 🔹 Reducir margen entre tabs
                        tabs: _categories
                            .map((category) => Tab(text: category))
                            .toList(),
                      ),
                    )
                  : null,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _categories.isNotEmpty && _tabController != null
                ? TabBarView(
                    controller: _tabController,
                    children: _categories.map((category) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: _getCandidateLists(category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Text("No hay candidatos en esta lista"));
                          }

                          final candidateLists = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: candidateLists.length,
                            itemBuilder: (context, index) {
                              final listData = candidateLists[index].data()
                                  as Map<String, dynamic>;
                              final listId = candidateLists[index].id;
                              final candidates =
                                  listData["candidates"] as List<dynamic>? ??
                                      [];

                              return Column(
                                children: [
                                  SizedBox(height: 10),
                                  for (var candidate in candidates)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: category == "Congresal" ||
                                              category == "Parlamento Andino"
                                          ? ListTile(
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                    candidate["image1"],
                                                    width: 50,
                                                    height: 50),
                                              ),
                                              title: Text(
                                                candidate["title"],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert),
                                                onSelected: (value) {
                                                  if (value == "edit") {
                                                    _addOrEditCandidate(
                                                        category,
                                                        listId: listId,
                                                        candidate: candidate);
                                                  } else if (value ==
                                                      "delete") {
                                                    _showDeleteConfirmationDialog(
                                                        listId, candidate);
                                                  }
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'edit',
                                                    child: ListTile(
                                                      leading: Icon(Icons.edit,
                                                          color: Colors.blue),
                                                      title: Text('Editar'),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: ListTile(
                                                      leading: Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      title: Text('Eliminar'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListTile(
                                              contentPadding:
                                                  EdgeInsets.only(left: 6),
                                              leading: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                        candidate["image1"],
                                                        width: 50,
                                                        height: 50),
                                                  ),
                                                  SizedBox(width: 5),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                        candidate["image2"],
                                                        width: 50,
                                                        height: 50),
                                                  ),
                                                ],
                                              ),
                                              title: Text(
                                                candidate["title"],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle:
                                                  Text(candidate["subtitle"]),
                                              trailing: PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert),
                                                onSelected: (value) {
                                                  if (value == "edit") {
                                                    _addOrEditCandidate(
                                                        category,
                                                        listId: listId,
                                                        candidate: candidate);
                                                  } else if (value ==
                                                      "delete") {
                                                    _showDeleteConfirmationDialog(
                                                        listId, candidate);
                                                  }
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'edit',
                                                    child: ListTile(
                                                      leading: Icon(Icons.edit,
                                                          color: Colors.blue),
                                                      title: Text('Editar'),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: ListTile(
                                                      leading: Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      title: Text('Eliminar'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  )
                : Center(child: Text("No hay categorías disponibles.")),
        floatingActionButton: _categories.isNotEmpty && _tabController != null
            ? FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: Colors.pink,
                onPressed: () {
                  String category = _categories[_tabController!.index];
                  _firestore
                      .collection("candidateLists")
                      .where("name", isEqualTo: category)
                      .get()
                      .then((querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      String listId = querySnapshot.docs.first.id;
                      _addCandidate(category, listId);
                    }
                  });
                },
                child: Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
