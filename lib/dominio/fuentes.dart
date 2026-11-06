import 'geo.dart';

/// Contrato para obtener coordenadas GPS.
/// Puede utilizar GPS real o una fuente simulada.
abstract class FuentePosicion {
  Stream<Coordenada> get posiciones;
}

/// Contrato para obtener las lecturas de la brújula.
/// Rumbo en grados: 0 = norte.
abstract class FuenteBrujula {
  Stream<double> get rumbos;
}
