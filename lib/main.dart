import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dominio/pasaporte.dart';
import 'presentacion/pantalla_inicio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantener la aplicación en orientación vertical.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dolores AR',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: PantallaInicio(pasaporte: Pasaporte()),
    ),
  );
}
