import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_2324/auth/servei_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditarDadesUsuari extends StatefulWidget {
  const EditarDadesUsuari({super.key});

  @override
  State<EditarDadesUsuari> createState() => _EditarDadesUsuariState();
}

class _EditarDadesUsuariState extends State<EditarDadesUsuari> {
  File? _imatgeSeleccionadaApp;
  Uint8List? _imatgeSeleccionadaWeb;
  bool _imatgeAPuntPerPujar = false;
  final _nomController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> _carregarDadesUsuari() async {
    final usuari = _auth.currentUser;
    if (usuari != null) {
      final doc = await _db.collection('Usuaris').doc(usuari.uid).get();
      setState(() {
        _nomController.text = doc['nom'] ?? '';
      });
    }
  }

  Future<void> _guardarDadesUsuari() async {
    if (_nomController.text.isNotEmpty) {
      final usuari = _auth.currentUser;
      if (usuari != null) {
        await _db.collection('Usuaris').doc(usuari.uid).update({
          'nom': _nomController.text,
        });
        Navigator.pop(context);
      }
    }
  }

  Future<void> _triaImatge() async {
    final ImagePicker picker = ImagePicker();
    XFile? imatge = await picker.pickImage(source: ImageSource.gallery);

    // Si trien i trobem la imatge.
    if (imatge != null) {
      // Si l'App s'executa en un dispositiu mòbil.
      if (!kIsWeb) {
        File arxiuSeleccionat = File(imatge.path);

        setState(() {
          _imatgeSeleccionadaApp = arxiuSeleccionat;
          _imatgeAPuntPerPujar = true;
        });
      }

      // Si l'App s'executa en un navegador web.
      if (kIsWeb) {
        Uint8List arxiuEnBytes = await imatge.readAsBytes();

        setState(() {
          _imatgeSeleccionadaWeb = arxiuEnBytes;
          _imatgeAPuntPerPujar = true;
        });
      }
    }
  }

  Future<bool> pujarImatgePerUsuari() async {
    String idUsuari = ServeiAuth().getUsuariActual()!.uid;

    Reference ref =
        FirebaseStorage.instance.ref().child("$idUsuari/avatar/$idUsuari");

    // Agafem la imatge de la variable que la tingui (la de web o la de App).
    if (_imatgeSeleccionadaApp != null) {
      try {
        await ref.putFile(_imatgeSeleccionadaApp!);
        return true;
      } catch (e) {
        return false;
      }
    }

    if (_imatgeSeleccionadaWeb != null) {
      try {
        await ref.putData(_imatgeSeleccionadaWeb!);
        return true;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  Future<String> getImatgePerfil() async {
    final String idUsuari = ServeiAuth().getUsuariActual()!.uid;
    final Reference ref =
        FirebaseStorage.instance.ref().child("$idUsuari/avatar/$idUsuari");

    final String urlImatge = await ref.getDownloadURL();

    return urlImatge;
  }

  Widget mostrarImatge() {
    return FutureBuilder(
      future: getImatgePerfil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const Icon(Icons.person);
        }

        return Image.network(
          snapshot.data!,
          errorBuilder: (context, error, stackTrace) {
            return Text("Error al carregar la imatge: $error");
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Dades'), // Set the title of the AppBar
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Cerrar la sesión
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${_auth.currentUser?.email ?? ''}'),
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  hintText: 'Escriu el teu nom...',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple[100],
                ),
                child: const Text('Guardar'),
                onPressed: _guardarDadesUsuari,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _triaImatge,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                  ),
                  child: const Text("Tria imatge"),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_imatgeAPuntPerPujar) {
                    bool imatgePujadaCorrectament =
                        await pujarImatgePerUsuari();

                    if (imatgePujadaCorrectament) {
                      mostrarImatge();
                      setState(() {});
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                  ),
                  child: const Text("Puja imatge"),
                ),
              ),
              if (_imatgeSeleccionadaWeb != null ||
                  _imatgeSeleccionadaApp != null)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: kIsWeb
                      ? Image.memory(
                          _imatgeSeleccionadaWeb!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _imatgeSeleccionadaApp!,
                          fit: BoxFit.cover,
                        ),
                ),

              // Visor del resultat de carregar la imatge de Firebase Storage.
              // =============================================================
              Container(
                child: mostrarImatge(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
