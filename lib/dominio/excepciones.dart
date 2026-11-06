/// Clase base de los errores conocidos de la aplicación.
abstract class ErrorDeApp implements Exception {
  const ErrorDeApp();
}

/// Se produce cuando no tenemos permiso de ubicación.
class PermisoUbicacionException extends ErrorDeApp {
  const PermisoUbicacionException();

  @override
  String toString() =>
      'Necesito el permiso de ubicación para mostrarte '
      'los lugares cercanos. Actívalo en Ajustes.';
}

/// Se produce cuando el GPS está desactivado.
class UbicacionApagadaException extends ErrorDeApp {
  const UbicacionApagadaException();

  @override
  String toString() =>
      'El GPS está apagado. Actívalo para usar '
      'la realidad aumentada.';
}

/// Se produce cuando el dispositivo no tiene brújula.
class SinBrujulaException extends ErrorDeApp {
  const SinBrujulaException();

  @override
  String toString() =>
      'Este dispositivo no tiene brújula (magnetómetro). '
      'Usa el modo demo.';
}

/// Devuelve mensajes seguros para mostrar al usuario.
/// No expone detalles internos de errores desconocidos.
String mensajeSeguro(Object error) => error is ErrorDeApp
    ? error.toString()
    : 'Ocurrió un error inesperado. Intenta de nuevo.';
