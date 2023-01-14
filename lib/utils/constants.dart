import 'package:flutter/material.dart';

var kBoxDecoIndigo = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Colors.blue.withOpacity(0.30),
      Colors.white.withOpacity(0.10),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomCenter,
    stops: const [0.0, 1.0],
  ),
);

var kBoxDecoWhite = BoxDecoration(
  borderRadius: BorderRadius.circular(10.0),
  border: Border.all(color: Colors.white.withOpacity(0.08)),
  gradient: LinearGradient(
    colors: [
      Colors.white.withOpacity(0.5),
      Colors.white.withOpacity(0.2),
    ],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    stops: const [0.0, 1.0],
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.indigo.withOpacity(0.02),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
);

var kBoxDecoWithBoxShadow = BoxDecoration(
  borderRadius: BorderRadius.circular(5.0),
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ],
);
const dimen_8 = 8.0;
const dimen_12 = 12.0;
const dimen_10 = 10.0;
const dimen_0 = 0.0;
const dimen_20 = 20.0;
const dimen_4 = 4.0;
const dimen_15 = 15.0;
Color primaryColor = const Color(0xff0080B6);
Color disableButtonColor = const Color(0xffd1d1d1);
int maxAllowedLimit = 5010000;
int oneMb = 1000000;
