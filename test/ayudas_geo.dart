import 'dart:math' as math;

import 'package:dolores_ar/dominio/geo.dart';
import 'package:dolores_ar/dominio/lugar.dart';

// Coordenadas de referencia: Plaza Principal de Dolores Hidalgo.
const origen = Coordenada(21.1561, -100.9318);

/// Desplaza una coordenada cierta cantidad de metros
/// hacia el norte y hacia el este.
Coordenada desplazar(Coordenada c, {double norte = 0, double este = 0}) {
  const metrosPorGrado = 111194.93;

  return Coordenada(
    c.lat + norte / metrosPorGrado,
    c.lon + este / (metrosPorGrado * math.cos(c.lat * math.pi / 180)),
  );
}

/// Crea un lugar ficticio para las pruebas.
Lugar lugarEn(String id, Coordenada c) => Lugar(
  id: id,
  nombre: id,
  emoji: '📍',
  categoria: Categoria.plaza,
  descripcion: '',
  datoCurioso: '',
  coordenada: c,
);
