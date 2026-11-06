import 'geo.dart';
import 'lugar.dart';

/// Representa un lugar turístico que está dentro
/// del campo de visión de la cámara.
class LugarVisible {
  final Lugar lugar;

  // Distancia desde el usuario hasta el lugar, en metros.
  final double distancia;

  // Posición horizontal:
  // 0 = izquierda, 0.5 = centro, 1 = derecha.
  final double x;

  // Profundidad:
  // 0 = cerca del usuario, 1 = límite del radio.
  final double profundidad;

  // Escala:
  // 1.2 = lugar cercano, 0.6 = lugar lejano.
  final double escala;

  const LugarVisible(
    this.lugar,
    this.distancia,
    this.x,
    this.profundidad,
    this.escala,
  );
}

/// Calcula qué lugares turísticos son visibles
/// según el GPS y la dirección de la brújula.
List<LugarVisible> calcularVisibles({
  required Coordenada usuario,
  required double rumbo,
  required List<Lugar> lugares,
  double campoVision = 60,
  double radioMax = 2000,
}) {
  final resultado = <LugarVisible>[];

  // Recorrer todos los lugares turísticos.
  for (final l in lugares) {
    // Calcular distancia con Haversine.
    final d = distanciaMetros(usuario, l.coordenada);

    // Descartar lugares demasiado lejanos.
    if (d > radioMax) {
      continue;
    }

    // Calcular el ángulo hacia el lugar.
    final dif = diferenciaAngular(rumboGrados(usuario, l.coordenada), rumbo);

    // Convertir el ángulo en posición horizontal.
    final x = posicionHorizontal(dif, campoVision: campoVision);

    // Si está fuera del campo de visión, descartarlo.
    if (x == null) {
      continue;
    }

    // Calcular profundidad entre 0 y 1.
    final profundidad = (d / radioMax).clamp(0.0, 1.0).toDouble();

    // Crear el lugar visible.
    resultado.add(LugarVisible(l, d, x, profundidad, 1.2 - 0.6 * profundidad));
  }

  // Ordenar de lejos a cerca.
  // Así los lugares cercanos se dibujan encima.
  resultado.sort((a, b) => b.distancia.compareTo(a.distancia));

  return resultado;
}
