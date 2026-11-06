import 'package:flutter/material.dart';

import '../dominio/geo.dart';
import '../dominio/lugar.dart';
import '../dominio/motor_ar.dart';
import 'ar_viewmodel.dart';
import 'fondo_camara.dart';

class PantallaAr extends StatefulWidget {
  // Crea el ViewModel una sola vez.
  final ArViewModel Function() crearVm;

  // Controles opcionales para el modo DEMO.
  final Widget? controlesDemo;

  const PantallaAr({super.key, required this.crearVm, this.controlesDemo});

  @override
  State<PantallaAr> createState() => _PantallaArState();
}

class _PantallaArState extends State<PantallaAr> {
  late final ArViewModel vm = widget.crearVm();

  @override
  void initState() {
    super.initState();

    vm.addListener(_avisarSello);
    vm.iniciar();
  }

  // Mostrar aviso cuando se consigue un sello.
  void _avisarSello() {
    final sello = vm.consumirSello();

    if (sello != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🏅 ¡Sello conseguido: ${sello.nombre}!')),
      );
    }
  }

  @override
  void dispose() {
    vm.removeListener(_avisarSello);
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Fondo con cámara o imagen simulada.
              const FondoCamara(),

              // Etiquetas flotantes de lugares turísticos.
              LayoutBuilder(
                builder: (context, caja) {
                  return Stack(
                    children: [
                      for (final v in vm.visibles) _etiqueta(context, v, caja),
                    ],
                  );
                },
              ),

              // Información superior.
              SafeArea(child: _panelSuperior(vm)),

              // Controles del modo DEMO.
              if (widget.controlesDemo != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(child: widget.controlesDemo!),
                ),
            ],
          );
        },
      ),
    );
  }

  // Panel con rumbo, lugares visibles y sellos.
  Widget _panelSuperior(ArViewModel vm) {
    final coordenadas = vm.usuario?.toString() ?? 'Sin ubicación';

    final texto =
        vm.error ??
        (vm.esperando
            ? 'Buscando GPS y brújula…'
            : '${nombreCardinal(vm.rumbo!)} '
                  '${vm.rumbo!.round()}° · '
                  '${vm.visibles.length} lugares · '
                  '🏅 ${vm.pasaporte.total}/${vm.lugares.length}'
                  '\nGPS: $coordenadas');

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: vm.error != null ? Colors.red.shade800 : Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Construye una etiqueta sobre el fondo.
  Widget _etiqueta(BuildContext context, LugarVisible v, BoxConstraints caja) {
    const ancho = 150.0;

    // Los lugares lejanos aparecen más arriba.
    final top = caja.maxHeight * (0.55 - 0.30 * v.profundidad);

    return Positioned(
      left: v.x * caja.maxWidth - ancho / 2,
      top: top,
      width: ancho,
      child: Transform.scale(
        scale: v.escala,
        child: GestureDetector(
          onTap: () => _detalle(context, v),
          child: Card(
            color: Colors.white.withValues(alpha: 0.92),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(v.lugar.emoji, style: const TextStyle(fontSize: 26)),

                  Text(
                    v.lugar.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    formatearDistancia(v.distancia),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mostrar la información del lugar seleccionado.
  void _detalle(BuildContext context, LugarVisible v) {
    final Lugar l = v.lugar;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l.emoji} ${l.nombre}',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 4),

              Text(
                'A ${formatearDistancia(v.distancia)} de ti',
                style: Theme.of(context).textTheme.labelLarge,
              ),

              const SizedBox(height: 12),

              Text(l.descripcion),

              const SizedBox(height: 12),

              Text('💡 ${l.datoCurioso}'),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
