import 'dart:async';

import 'package:flutter/foundation.dart';

import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/lugar.dart';
import '../dominio/motor_ar.dart';
import '../dominio/pasaporte.dart';

class ArViewModel extends ChangeNotifier {
  // Fuentes de datos.
  final FuentePosicion posicion;
  final FuenteBrujula brujula;

  final List<Lugar> lugares;
  final Pasaporte pasaporte;
  final double campoVision;
  final double radioMax;

  // Constructor corregido.
  ArViewModel({
    required this.posicion,
    required this.brujula,
    required this.lugares,
    required this.pasaporte,
    this.campoVision = 60,
    this.radioMax = 2000,
  });

  // Posición actual del usuario.
  Coordenada? usuario;

  // Dirección actual de la brújula.
  double? rumbo;

  // Lugares visibles dentro del campo de visión.
  List<LugarVisible> visibles = [];

  // Mensaje de error seguro.
  String? error;

  // Último lugar que otorgó un sello.
  Lugar? ultimoSello;

  // Suscripciones a GPS y brújula.
  StreamSubscription<Coordenada>? _subPosicion;
  StreamSubscription<double>? _subBrujula;

  /// Indica si todavía faltan datos del GPS o brújula.
  bool get esperando => usuario == null || rumbo == null;

  /// Inicia la recepción de datos del GPS y la brújula.
  void iniciar() {
    _subPosicion = posicion.posiciones.listen((p) {
      usuario = p;
      _recalcular();
    }, onError: _alFallar);

    _subBrujula = brujula.rumbos.listen((g) {
      // La primera lectura se acepta directamente.
      // Las siguientes lecturas se suavizan.
      rumbo = rumbo == null ? g : suavizarAngulo(rumbo!, g);

      _recalcular();
    }, onError: _alFallar);
  }

  /// Controla los errores sin revelar detalles internos.
  void _alFallar(Object e) {
    error = mensajeSeguro(e);
    notifyListeners();
  }

  /// Calcula los lugares visibles y registra sellos.
  void _recalcular() {
    final u = usuario;
    final r = rumbo;

    if (u != null && r != null) {
      visibles = calcularVisibles(
        usuario: u,
        rumbo: r,
        lugares: lugares,
        campoVision: campoVision,
        radioMax: radioMax,
      );

      // Comprobar si el usuario merece un sello.
      for (final l in lugares) {
        if (pasaporte.registrarSiCerca(l, distanciaMetros(u, l.coordenada))) {
          ultimoSello = l;
        }
      }
    }

    notifyListeners();
  }

  /// Devuelve el último sello obtenido.
  /// Después lo elimina para no mostrarlo dos veces.
  Lugar? consumirSello() {
    final l = ultimoSello;
    ultimoSello = null;
    return l;
  }

  /// Cancela las suscripciones al cerrar el ViewModel.
  @override
  void dispose() {
    _subPosicion?.cancel();
    _subBrujula?.cancel();
    super.dispose();
  }
}
