import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImageWidget extends StatefulWidget {
  final Function(XFile) onImageSelected;
  final String? initialImageUrl; // Añadir el parámetro de imagen inicial

  const AddImageWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
  });

  @override
  State<AddImageWidget> createState() => _AddImageWidgetState();
}

class _AddImageWidgetState extends State<AddImageWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? image;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      // Solo inicializa si hay una URL válida
      setState(() {
        image = null; // No se asigna como XFile; se usará NetworkImage
      });
    }
  }

  getImageGallery() async {
    XFile? selectImageGallery =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectImageGallery != null) {
      setState(() {
        image = selectImageGallery;
      });
      widget.onImageSelected(selectImageGallery);
    }
  }

  getImageCamera() async {
    XFile? selectImageCamera =
        await _picker.pickImage(source: ImageSource.camera);
    if (selectImageCamera != null) {
      setState(() {
        image = selectImageCamera;
      });
      widget.onImageSelected(selectImageCamera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.clear_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              getImageGallery();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 52,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.pinkAccent,
                                    Colors.deepPurpleAccent,
                                    Colors.blue
                                  ],
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Galeria",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              getImageCamera();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 52,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.pinkAccent,
                                    Colors.deepPurpleAccent,
                                    Colors.blue
                                  ],
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Camara",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Center(
            child: (image != null)
                ? Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(image!.path)),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        width: 0.5,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 90,
                    width: 90,
                  )
                : widget.initialImageUrl != null
                    ? Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.initialImageUrl!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 90,
                        width: 90,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: 90,
                        height: 90,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Añadir imagen",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
