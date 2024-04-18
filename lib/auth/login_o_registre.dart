import 'package:flutter/material.dart';
import 'package:flutter_firebase_2324/pagines/pagina_login.dart';
import 'package:flutter_firebase_2324/pagines/pagina_registre.dart';

class LoginORegistre extends StatefulWidget {
  const LoginORegistre({super.key});

  @override
  State<LoginORegistre> createState() => _LoginORegistreState();
}

class _LoginORegistreState extends State<LoginORegistre> {

  bool mostraPaginaLogin = true;

  void intercanviarPaginesLoginRegistre() {
    setState(() {
      mostraPaginaLogin = !mostraPaginaLogin;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (mostraPaginaLogin) {
      return PaginaLogin(alFerClic: intercanviarPaginesLoginRegistre,);
    } else {
      return PaginaRegistre(alFerClic: intercanviarPaginesLoginRegistre,);
    }
    
  }
}