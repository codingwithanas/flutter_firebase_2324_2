import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_2324/auth/servei_auth.dart';
import 'package:flutter_firebase_2324/chat/servei_chat.dart';
import 'package:flutter_firebase_2324/components/bombolla_missatge.dart';
import 'package:intl/intl.dart';

class PaginaChat extends StatefulWidget {
  final String emailAmbQuiParlem;
  final String idReceptor;

  const PaginaChat({
    super.key,
    required this.emailAmbQuiParlem,
    required this.idReceptor,
  });

  @override
  State<PaginaChat> createState() => _PaginaChatState();
}

class _PaginaChatState extends State<PaginaChat> {
  final TextEditingController controllerMissatge = TextEditingController();
  final ScrollController controllerScroll = ScrollController();

  final ServeiChat _serveiChat = ServeiChat();
  final ServeiAuth _serveiAuth = ServeiAuth();

  // Variable pel teclat d'un mòbil.
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    controllerMissatge.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => ferScrollCapAvall(),
      );
    });

    // Ens esperem un moment, i llavors movem cap a baix.
    Future.delayed(
      const Duration(milliseconds: 500),
      () => ferScrollCapAvall(),
    );
  }

  Future<String> getNomUsuari(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('Usuaris').doc(uid).get();
    return doc['nom'] ?? '';
  }

  void ferScrollCapAvall() {
    controllerScroll.animateTo(
      controllerScroll.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void enviarMissatge() async {
    if (controllerMissatge.text.isNotEmpty) {
      // Enviar el missatge.
      await _serveiChat.enviarMissatge(
          widget.idReceptor, controllerMissatge.text);

      // Netejar el camp.
      controllerMissatge.clear();
    }
    ferScrollCapAvall();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getNomUsuari(widget.idReceptor), 
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(
                  child:
                      CircularProgressIndicator())); 
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data ??
                  widget
                      .emailAmbQuiParlem), 
            ),
            body: Column(
              children: [
                // Zona missatges.
                Expanded(
                  child: _construirLlistaMissatges(),
                ),
                // Zona escriure missatge.
                _construirZonaInputUsuari(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _construirLlistaMissatges() {
    String idUsuariActual = _serveiAuth.getUsuariActual()!.uid;

    return StreamBuilder(
      stream: _serveiChat.getMissatges(idUsuariActual, widget.idReceptor),
      builder: (context, snapshot) {
        // Cas que hi hagi error.
        if (snapshot.hasError) {
          return const Text("Error carregant missatges.");
        }

        // Estar encara carregant.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Carregant...");
        }

        // Retornar dades (ListView).
        return ListView(
          controller: controllerScroll,
          children: snapshot.data!.docs
              .map((document) => _construirItemMissatge(document))
              .toList(),
        );
      },
    );
  }

  String calcularTiempoTranscurrido(Timestamp timestamp) {
    DateTime fechaMensaje = timestamp.toDate();
    DateTime ahora = DateTime.now();
    Duration diferencia = ahora.difference(fechaMensaje);

    if (diferencia.inDays == 0) {
      return DateFormat('HH:mm').format(fechaMensaje);
    } else {
      return 'Fa ${diferencia.inDays} dia${diferencia.inDays == 1 ? '' : 's'}';
    }
  }

  Widget _construirItemMissatge(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    bool esUsuariActual = data["idAutor"] == _serveiAuth.getUsuariActual()!.uid;

    Color colorBombolla =
        esUsuariActual ? Colors.green[200]! : Colors.amber[200]!;
    String tiempoTranscurrido = calcularTiempoTranscurrido(data["timestamp"]);

    return Column(
      crossAxisAlignment:
          esUsuariActual ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        BombollaMissatge(
          colorBombolla: colorBombolla,
          missatge: data["missatge"],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0, right: 8.0, left: 8.0),
          child: Text(
            tiempoTranscurrido,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirZonaInputUsuari() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controllerMissatge,
              decoration: InputDecoration(
                fillColor: Colors.amber[200],
                filled: true,
                hintText: "Escriu el missatge...",
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
            icon: const Icon(Icons.send),
            color: Colors.white,
            onPressed: enviarMissatge,
          ),
        ],
      ),
    );
  }
}
