import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_2324/auth/login_o_registre.dart';
import 'package:flutter_firebase_2324/auth/portal_auth.dart';
import 'package:flutter_firebase_2324/firebase_options.dart';
import 'package:flutter_firebase_2324/pagines/pagina_login.dart';
import 'package:flutter_firebase_2324/pagines/pagina_registre.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PortalAuth(),
    );
  }
}

/*
1) Tenir el Node.js instal·lat.
2) npm install -g firebase-tools
3) Fer login a Firebase: firebase login
    - Si dona error de l'arxiu firebase.ps1, canviar-li el nom (o esborrar-lo
    i tornar a fer login).
    - Si tornem a fer firebase login, ens diu en quin compte estem.
    - Si vulguéssim canviar el compte, fem firebase logout.

4) Fer: dart pub global activate flutterfire_cli
5) Vincular projecte local amb projecte Firebase de la Consola.
    - flutterfire configure

6) Incloure les llibreries de Firebase que vulguem utilitzar.
    - flutter pub add firebase_auth
    - flutter pub add firebase_core

*/

/*
Imatges:
========

1) Habilitar Firebase Storage en el projecte vinculat de Firebase.
  - Es pot posar les reglas a true el write i read.

2) Descarreguem dependència de Firebase Storage al projecte.
  - flutter pub add firebase_storage

3) Desccarreguem una dependència per seleccionar imatges (un picker).
  - N'hi ha diversos.
  - Fem servir el image_picker
    - flutter pub add image_picker

4) Perquè funcioni en Android:
  - Anar a android > app > src > main > AndroidManifest.xml
    Escriure just abans del tag <aplication> (fora d'aplication):
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>

  - A més a més, segurament, caldrà anar a: android > app > build.gradle
      - On diu minSdkVersion flutter.minSdkVersion, canviar-ho per:
          minSdkVersion 21
  
  - Si dona error diuent: One or more plugins require a higher Android SDK version.
      - Anar a: android > app > build.gradle, i posar-hi:
          - compileSdkVersion 34

5) Perquè funcioni en iOS:
  - Anar a ios > Runner > Info.plist
  - Afegir els permisos amb les següents línies:
      <key>NSPhotoLibraryUsageDescription</key>
      <string>Privacy - Photo Library Usage Description</string>
      <key>NSMotionUsageDescription</key>
      <string>Motion usage description</string>
      <key>NSPhotoLibraryAddUsageDescription</key>
      <string>NSPhotoLibraryAddUsageDescription</string>

6) Perquè funcioni en web:
  - Anar a web > index.html
  - On diu "onEntrypointLoaded":
      onEntrypointLoaded: function(engineInitializer) {
        engineInitializer.initializeEngine().then(function(appRunner) {
          appRunner.runApp();
        });
      }
    - Canviar-ho per:
        onEntrypointLoaded: function(engineInitializer) {
          let config = { renderer: 'html' };
          engineInitializer.initializeEngine(config).then(function(appRunner) {
            appRunner.runApp();
          });
        }

*/