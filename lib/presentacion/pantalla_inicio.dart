import 'package:flutter/material.dart';

import '../datos/fuentes_reales.dart';
import '../datos/fuentes_simuladas.dart';
import '../dominio/catalogo.dart';
import '../dominio/geo.dart';
import '../dominio/pasaporte.dart';
import 'ar_viewmodel.dart';
import 'pantalla_ar.dart';
import 'pantalla_modelo3d.dart';

class PantallaInicio extends StatelessWidget {
  final Pasaporte pasaporte;

  const PantallaInicio({super.key, required this.pasaporte});

  // Abrir realidad aumentada utilizando GPS real.
  void _irReal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaAr(
          crearVm: () => ArViewModel(
            posicion: PosicionGps(),
            brujula: BrujulaReal(),
            lugares: catalogoDolores,
            pasaporte: pasaporte,
          ),
        ),
      ),
    );
  }

  // Abrir realidad aumentada en modo DEMO.
  void _irDemo(BuildContext context) {
    final brujula = BrujulaSimulada();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaAr(
          crearVm: () => ArViewModel(
            posicion: PosicionSimulada(const Coordenada(21.15600, -100.93175)),
            brujula: brujula,
            lugares: catalogoDolores,
            pasaporte: pasaporte,
          ),
          controlesDemo: _DeslizadorRumbo(brujula: brujula),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dolores AR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Descubre Dolores Hidalgo con realidad aumentada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          const Text(
            'Apunta tu teléfono y mira qué lugares '
            'históricos te rodean.',
          ),

          const SizedBox(height: 20),

          // GPS real.
          FilledButton.icon(
            onPressed: () => _irReal(context),
            icon: const Icon(Icons.explore),
            label: const Text('Explorar con GPS real'),
          ),

          const SizedBox(height: 10),

          // Modo DEMO.
          OutlinedButton.icon(
            onPressed: () => _irDemo(context),
            icon: const Icon(Icons.school),
            label: const Text('Modo demo (salón de clases)'),
          ),

          const SizedBox(height: 10),

          // Modelo 3D.
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const PantallaModelo3D(),
                ),
              );
            },
            icon: const Icon(Icons.view_in_ar),
            label: const Text('Modelo 3D en tu espacio'),
          ),

          const SizedBox(height: 24),

          Text(
            'Lugares del recorrido',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          // Mostrar todos los lugares turísticos.
          for (final l in catalogoDolores)
            ListTile(
              leading: Text(l.emoji, style: const TextStyle(fontSize: 26)),
              title: Text(l.nombre),
              trailing: Icon(
                pasaporte.visitado(l.id)
                    ? Icons.verified
                    : Icons.circle_outlined,
              ),
            ),
        ],
      ),
    );
  }
}

/// Deslizador que controla la brújula simulada.
class _DeslizadorRumbo extends StatefulWidget {
  final BrujulaSimulada brujula;

  const _DeslizadorRumbo({required this.brujula});

  @override
  State<_DeslizadorRumbo> createState() => _DeslizadorRumboState();
}

class _DeslizadorRumboState extends State<_DeslizadorRumbo> {
  double _grados = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('Gira:', style: TextStyle(color: Colors.white)),

          Expanded(
            child: Slider(
              min: 0,
              max: 359,
              value: _grados,
              onChanged: (g) {
                setState(() {
                  _grados = g;
                });

                widget.brujula.girar(g);
              },
            ),
          ),

          Text(
            '${_grados.round()}°',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
