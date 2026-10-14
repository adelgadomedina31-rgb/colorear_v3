import 'package:flutter/material.dart';

import '../config.dart';
import '../models/dibujo.dart';
import '../models/paleta_dibujo.dart';
import '../models/pintura.dart';
import '../servicios/sonidos.dart';
import '../servicios/voz.dart';
import '../widgets/botones.dart';
import '../widgets/lienzo.dart';
import '../widgets/paleta.dart';

/// Pantalla de pintar: arriba los botones grandes (inicio, anterior, siguiente,
/// borrar), en el medio el dibujo y abajo los colores de ESE dibujo.
class PantallaPintar extends StatefulWidget {
  const PantallaPintar({
    super.key,
    required this.dibujos,
    required this.indice,
  });

  final List<Dibujo> dibujos;
  final int indice;

  @override
  State<PantallaPintar> createState() => _EstadoPintar();
}

class _EstadoPintar extends State<PantallaPintar> {
  late int _indice;

  /// Los colores del dibujo abierto (como mucho 5).
  List<ColorConNombre> _colores = const <ColorConNombre>[];

  /// Cuánto pintó cada color en el dibujo abierto (null mientras se lee).
  PaletaDibujo? _paleta;

  /// El color elegido (null si ya no queda ninguno).
  ColorConNombre? _color;

  /// true mientras la voz dice el nombre del color (no se puede elegir otro).
  bool _hablando = false;

  /// Sube cada vez que se borra lo pintado (para empezar un lienzo nuevo).
  int _reinicios = 0;

  /// La primera medición al entrar a un dibujo no dice nada en voz alta:
  /// solo pone la paleta al día (por ejemplo, con lo pintado en la v6).
  bool _primeraMedicion = true;

  /// Una medición que llegó antes de que la paleta estuviera lista.
  List<double>? _medicionPendiente;

  /// Para no repetir los avisos a cada toque.
  DateTime _ultimoAviso = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _indice = widget.indice;
    _entrarAlDibujo();
    // La voz y los sonidos se preparan mientras tanto.
    Voz.preparar();
    Sonidos.preparar();
  }

  @override
  void dispose() {
    PaletaDibujo.guardarPendientes();
    super.dispose();
  }

  Dibujo get _dibujo => widget.dibujos[_indice];

  /// Cada vez que se entra a un dibujo (o se pasa a otro, o se borra), la
  /// paleta es la de ESE dibujo: completa si nunca se pintó, o como se dejó.
  void _entrarAlDibujo() {
    final dibujo = _dibujo;
    _colores = PaletaDibujo.coloresDe(dibujo);
    _primeraMedicion = true;
    _medicionPendiente = null;
    final lista = PaletaDibujo.enMemoria(dibujo.id);
    if (lista != null) {
      _usarPaleta(lista);
      return;
    }
    _paleta = null;
    _color = null;
    PaletaDibujo.cargar(dibujo.id).then((paleta) {
      if (!mounted || _dibujo.id != dibujo.id) return;
      setState(() => _usarPaleta(paleta));
    });
  }

  void _usarPaleta(PaletaDibujo paleta) {
    _paleta = paleta;
    final pendiente = _medicionPendiente;
    _medicionPendiente = null;
    if (pendiente != null) {
      paleta.actualizar(_colores, pendiente);
      _primeraMedicion = false;
    }
    // Al entrar queda elegido el primer color que quede.
    final libres = paleta.disponibles(_colores);
    _color = libres.isEmpty ? null : libres.first;
  }

  Future<void> _elegirColor(ColorConNombre opcion) async {
    final paleta = _paleta;
    if (_hablando || paleta == null || paleta.acabado(opcion.nombre)) return;
    setState(() => _color = opcion);
    await _hablar(opcion.nombre);
  }

  /// Dice una frase. Mientras habla, la paleta queda bloqueada para que la
  /// frase se escuche completa.
  Future<void> _hablar(String texto) async {
    if (_hablando) return;
    setState(() => _hablando = true);
    final inicio = DateTime.now();
    try {
      // Como mucho 5 segundos: la paleta nunca se queda bloqueada.
      await Voz.decir(texto).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Si la voz falla o tarda, igual se sigue.
    }
    // Pausa mínima, aunque la voz termine antes (o no haya voz).
    final pasado = DateTime.now().difference(inicio);
    const minimo = Duration(milliseconds: Ajustes.pausaMinimaColor);
    if (pasado < minimo) {
      await Future<void>.delayed(minimo - pasado);
    }
    if (!mounted) return;
    setState(() => _hablando = false);
  }

  /// Avisos de la pintura: se dicen SIN bloquear la paleta (así puede
  /// elegir otro color mientras escucha). Si [siempre] es false, no se
  /// repiten más de una vez cada 3 segundos.
  void _avisar(String texto, {bool siempre = false}) {
    final ahora = DateTime.now();
    if (!siempre) {
      if (_hablando || ahora.difference(_ultimoAviso) < const Duration(seconds: 3)) {
        return;
      }
    }
    _ultimoAviso = ahora;
    Voz.decir(texto);
  }

  String _conColor(String frase, ColorConNombre opcion) =>
      frase.replaceAll('{color}', opcion.nombre.toLowerCase());

  /// El lienzo pregunta antes de pintar. false = no se pinta.
  bool _puedePintar() {
    final paleta = _paleta;
    final color = _color;
    if (paleta == null) return false;
    if (color == null) {
      _avisar(Ajustes.vozSinColores);
      return false;
    }
    if (paleta.acabado(color.nombre)) {
      _avisar(Ajustes.vozEligeOtro);
      return false;
    }
    return true;
  }

  /// Cuánto más del dibujo puede pintar el color elegido (0 a 1).
  double _margen() {
    final paleta = _paleta;
    final color = _color;
    if (paleta == null || color == null) return 0;
    return paleta.margen(color.nombre);
  }

  /// El lienzo midió cuánto cubre cada color. Si alguno llegó a su límite,
  /// se avisa con la voz, desaparece de la paleta y queda elegido otro.
  void _alMedir(List<double> cobertura) {
    final paleta = _paleta;
    if (paleta == null) {
      _medicionPendiente = cobertura;
      return;
    }
    final enSilencio = _primeraMedicion;
    _primeraMedicion = false;
    final acabados = paleta.actualizar(_colores, cobertura);
    if (acabados.isEmpty) return;
    final elegido = _color;
    if (elegido == null || paleta.acabado(elegido.nombre)) {
      final libres = paleta.disponibles(_colores);
      _color = libres.isEmpty ? null : libres.first;
    }
    setState(() {});
    if (enSilencio) return;
    if (_color == null) {
      _avisar(Ajustes.vozSeAcabaronTodos, siempre: true);
    } else {
      // Si se acabaron dos a la vez, se nombra el que se estaba usando.
      final nombrado = acabados.firstWhere(
        (c) => c.color == elegido?.color,
        orElse: () => acabados.first,
      );
      _avisar(_conColor(Ajustes.vozSeAcabo, nombrado), siempre: true);
    }
  }

  void _mover(int paso) {
    final cantidad = widget.dibujos.length;
    setState(() {
      _indice = (_indice + paso + cantidad) % cantidad;
      _entrarAlDibujo();
    });
  }

  /// Borra lo pintado del dibujo y deja su paleta completa (sin preguntar).
  void _borrar() {
    Pintura.borrar(_dibujo);
    setState(() {
      _reinicios++;
      _entrarAlDibujo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ajustes.fondoApp,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BotonGrande(
                    icono: Icons.home_rounded,
                    color: const Color(0xFF1E88E5),
                    alTocar: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      BotonGrande(
                        icono: Icons.arrow_back_rounded,
                        color: const Color(0xFFFB8C00),
                        alTocar: () => _mover(-1),
                      ),
                      const SizedBox(width: 14),
                      BotonGrande(
                        icono: Icons.arrow_forward_rounded,
                        color: const Color(0xFFFB8C00),
                        alTocar: () => _mover(1),
                      ),
                    ],
                  ),
                  BotonGrande(
                    icono: Icons.refresh_rounded,
                    color: const Color(0xFFE53935),
                    alTocar: _borrar,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Lienzo(
                  key: ValueKey<String>('${_dibujo.id}#$_reinicios'),
                  dibujo: _dibujo,
                  color: _color?.color ?? const Color(0x00000000),
                  colores: <Color>[for (final c in _colores) c.color],
                  puedePintar: _puedePintar,
                  margen: _margen,
                  alMedir: _alMedir,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: _paleta == null
                  ? Paleta(
                      key: ValueKey<String>('${_dibujo.id}#$_reinicios'),
                      colores: _colores,
                      seleccionado: null,
                      alElegir: _elegirColor,
                      niveles: const <double>[],
                      acabados: const <String>{},
                      cargando: true,
                    )
                  : ListenableBuilder(
                      listenable: _paleta!,
                      builder: (context, _) {
                        final paleta = _paleta!;
                        return Paleta(
                          key: ValueKey<String>('${_dibujo.id}#$_reinicios'),
                          colores: _colores,
                          seleccionado: _color,
                          bloqueada: _hablando,
                          alElegir: _elegirColor,
                          niveles: <double>[
                            for (final c in _colores) paleta.nivel(c.nombre),
                          ],
                          acabados: <String>{
                            for (final c in _colores)
                              if (paleta.acabado(c.nombre)) c.nombre,
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
