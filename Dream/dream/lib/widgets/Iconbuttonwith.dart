import 'package:flutter/material.dart';

class Iconbuttonwith extends StatelessWidget {

  final String text ;
  final IconData icon ;
  final  Function()? Functions ;

  const Iconbuttonwith({super.key, required this.text , required this.icon, required this.Functions});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: Functions,
      ),Text(text ,style: TextStyle(color: Colors.white,fontSize: 24),)
    ]);
  }
}
