import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class PantallaModelo3D extends StatelessWidget {
  static const modeloDePractica =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  const PantallaModelo3D({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modelo 3D en tu espacio')),
      body: const ModelViewer(
        src: modeloDePractica,
        alt: 'Modelo 3D de práctica',
        ar: true,
        arModes: ['scene-viewer', 'webxr', 'quick-look'],
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}
