import 'dart:async';

import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

/// Modo DEMO:
/// Permite simular una posición sin utilizar GPS real.
class PosicionSimulada implements FuentePosicion {
  final Coordenada punto;

  PosicionSimulada(this.punto);

  @override
  Stream<Coordenada> get posiciones => Stream<Coordenada>.value(punto);
}

/// Brújula simulada que puede controlarse
/// desde un deslizador de la interfaz.
class BrujulaSimulada implements FuenteBrujula {
  final _controlador = StreamController<double>.broadcast();

  double _ultimo = 0;

  @override
  Stream<double> get rumbos async* {
    yield _ultimo;
    yield* _controlador.stream;
  }

  /// Cambia la dirección simulada.
  void girar(double grados) {
    _ultimo = grados;
    _controlador.add(grados);
  }

  /// Libera los recursos utilizados.
  void cerrar() {
    _controlador.close();
  }
}
