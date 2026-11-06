import 'dart:math' as math;

/// Representa una coordenada geográfica.
class Coordenada {
  final double lat;
  final double lon;

  const Coordenada(this.lat, this.lon);

  @override
  String toString() => '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
}

// Radio promedio de la Tierra en metros.
const double _radioTierra = 6371000.0;

/// Convierte grados a radianes.
double _rad(double grados) => grados * math.pi / 180;

/// Convierte radianes a grados.
/// Se utilizará en la siguiente ronda.
// ignore: unused_element
double _grados(double rad) => rad * 180 / math.pi;

/// Calcula la distancia entre dos coordenadas GPS
/// utilizando la fórmula de Haversine.
double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);

  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);

  return 2 * _radioTierra * math.asin(math.sqrt(h.clamp(0.0, 1.0).toDouble()));
}

/// Calcula el rumbo desde una coordenada hacia otra.
/// 0° = Norte, 90° = Este, 180° = Sur, 270° = Oeste.
double rumboGrados(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);

  final y = math.sin(dLon) * math.cos(lat2);

  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

  return normalizar360(_grados(math.atan2(y, x)));
}

/// Normaliza cualquier ángulo al intervalo de 0 a 360 grados.
double normalizar360(double g) => ((g % 360) + 360) % 360;

/// Calcula el giro más corto entre dos ángulos.
/// Positivo = derecha.
/// Negativo = izquierda.
double diferenciaAngular(double objetivo, double actual) {
  var d = normalizar360(objetivo - actual);

  if (d > 180) {
    d -= 360;
  }

  return d;
}

/// Suaviza las lecturas de la brújula.
/// Evita saltos bruscos al cruzar de 359° a 0°.
double suavizarAngulo(double anterior, double nuevo, {double alfa = 0.2}) {
  return normalizar360(anterior + alfa * diferenciaAngular(nuevo, anterior));
}

/// Convierte un rumbo a su nombre cardinal.
String nombreCardinal(double grados) {
  const puntos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];

  return puntos[((normalizar360(grados) + 22.5) ~/ 45) % 8];
}

/// Calcula la posición horizontal de un lugar en pantalla.
/// 0.0 = izquierda
/// 0.5 = centro
/// 1.0 = derecha
///
/// Devuelve null cuando el lugar queda fuera
/// del campo de visión de la cámara.
double? posicionHorizontal(double diferencia, {double campoVision = 60}) {
  if (diferencia.abs() > campoVision / 2) {
    return null;
  }

  return 0.5 + diferencia / campoVision;
}

/// Convierte una distancia en metros a texto.
/// Menos de 1000 metros: "85 m"
/// Desde 1000 metros: "1.3 km"
String formatearDistancia(double metros) {
  return metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1)} km';
}
