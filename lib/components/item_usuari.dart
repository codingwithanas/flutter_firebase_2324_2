import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Future<String?> getUrlImatgePerfil(String uid) async {
  try {
    final Reference ref =
        FirebaseStorage.instance.ref().child("$uid/avatar/$uid");
    final String urlImatge = await ref.getDownloadURL();
    return urlImatge;
  } catch (e) {
    return null;
  }
}

class ItemUsuari extends StatelessWidget {
  final String uid;
  final String emailUsuari;
  final void Function()? onTap;

  const ItemUsuari({
    Key? key,
    required this.uid,
    required this.emailUsuari,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            FutureBuilder<String?>(
              future: getUrlImatgePerfil(uid),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      width: 50, 
                      height: 50,
                      child: Image.network(snapshot.data!, fit: BoxFit.cover),
                    );
                  } else {
                    return Icon(Icons.person);
                  }
                }
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Text(emailUsuari),
          ],
        ),
      ),
    );
  }
}
