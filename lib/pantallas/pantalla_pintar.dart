import 'package:flutter/material.dart';

import '../config.dart';
import '../models/dibujo.dart';
import '../models/paleta_dibujo.dart';
import '../models/pintura.dart';
import '../servicios/sonidos.dart';
import '../servicios/voz.dart';
import '../widgets/botones.dart';
import '../widgets/celebracion.dart';
import '../widgets/lienzo.dart';
import '../widgets/paleta.dart';

/// Pantalla de pintar: arriba los botones grandes (inicio, anterior, siguiente,
/// borrar), en el medio el dibujo y abajo los colores de ESE dibujo.
/// Cuando el dibujo queda pintado casi entero (el 95%), sale la celebración.
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
  Medida? _medicionPendiente;

  /// true mientras se ve la celebración de "¡Felicidades!".
  bool _celebrando = false;

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
    _celebrando = false;
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
      paleta.actualizar(_colores, pendiente.colores);
      // Si ya estaba terminado de antes, no se celebra al entrar.
      if (_terminado(pendiente)) paleta.marcarCelebrado();
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
    await _hablar(opcion.nombre, grabaciones: <String>[opcion.nombre]);
  }

  /// Dice una frase. Mientras habla, la paleta queda bloqueada para que la
  /// frase se escuche completa. [grabaciones]: ver [Voz.decir].
  Future<void> _hablar(
    String texto, {
    List<String> grabaciones = const <String>[],
  }) async {
    if (_hablando) return;
    setState(() => _hablando = true);
    final inicio = DateTime.now();
    try {
      // Como mucho 5 segundos: la paleta nunca se queda bloqueada.
      await Voz.decir(
        texto,
        grabaciones: grabaciones,
      ).timeout(const Duration(seconds: 5));
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
  /// repiten más de una vez cada 3 segundos. [grabaciones]: ver [Voz.decir].
  void _avisar(
    String texto, {
    bool siempre = false,
    List<String> grabaciones = const <String>[],
  }) {
    final ahora = DateTime.now();
    if (!siempre) {
      if (_hablando ||
          ahora.difference(_ultimoAviso) < const Duration(seconds: 3)) {
        return;
      }
    }
    _ultimoAviso = ahora;
    Voz.decir(texto, grabaciones: grabaciones);
  }

  String _conColor(String frase, ColorConNombre opcion) =>
      frase.replaceAll('{color}', opcion.nombre.toLowerCase());

  /// El lienzo pregunta antes de pintar. false = no se pinta.
  bool _puedePintar() {
    final paleta = _paleta;
    final color = _color;
    if (paleta == null) return false;
    if (color == null) {
      _avisar(
        Ajustes.vozSinColores,
        grabaciones: const <String>['ya_no_quedan_colores'],
      );
      return false;
    }
    if (paleta.acabado(color.nombre)) {
      _avisar(
        Ajustes.vozEligeOtro,
        grabaciones: const <String>['elige_otro_color'],
      );
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

  /// true si el dibujo ya está pintado casi entero (el 95%).
  bool _terminado(Medida medida) =>
      medida.pintado >= Ajustes.porcentajeCelebracion - 0.0005;

  /// El lienzo midió cuánto cubre cada color y cuánto está pintado.
  ///  - Si un color llegó a su límite, se avisa con la voz, desaparece de la
  ///    paleta y queda elegido otro.
  ///  - Si el dibujo quedó pintado casi entero, sale la celebración (una sola
  ///    vez por dibujo). No hace falta usar todos los colores.
  void _alMedir(Medida medida) {
    final paleta = _paleta;
    if (paleta == null) {
      _medicionPendiente = medida;
      return;
    }
    final enSilencio = _primeraMedicion;
    _primeraMedicion = false;
    final acabados = paleta.actualizar(_colores, medida.colores);
    final celebrar = !paleta.celebrado && _terminado(medida);
    if (celebrar) paleta.marcarCelebrado();
    if (acabados.isEmpty && !celebrar) return;
    final elegido = _color;
    if (elegido == null || paleta.acabado(elegido.nombre)) {
      final libres = paleta.disponibles(_colores);
      _color = libres.isEmpty ? null : libres.first;
    }
    setState(() {});
    // Al entrar no se dice nada (si ya estaba terminado, no se celebra).
    if (enSilencio) return;
    if (celebrar) {
      _celebrar();
    } else if (_color == null) {
      _avisar(
        Ajustes.vozSeAcabaronTodos,
        siempre: true,
        grabaciones: const <String>['se_acabaron_todos'],
      );
    } else {
      // Si se acabaron dos a la vez, se nombra el que se estaba usando.
      final nombrado = acabados.firstWhere(
        (c) => c.color == elegido?.color,
        orElse: () => acabados.first,
      );
      _avisar(
        _conColor(Ajustes.vozSeAcabo, nombrado),
        siempre: true,
        grabaciones: <String>['se_acabo_el_color', nombrado.nombre],
      );
    }
  }

  /// ¡Terminó el dibujo! Estrellas, la fiesta y la voz que la felicita.
  void _celebrar() {
    setState(() => _celebrando = true);
    Sonidos.felicidades();
    final id = _dibujo.id;
    // La voz entra después de las primeras campanitas.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || !_celebrando || _dibujo.id != id) return;
      _avisar(
        Ajustes.vozCelebracion,
        siempre: true,
        grabaciones: const <String>['felicidades'],
      );
    });
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
      body: Stack(
        children: [
          SafeArea(
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
                              key: ValueKey<String>(
                                '${_dibujo.id}#$_reinicios',
                              ),
                              colores: _colores,
                              seleccionado: _color,
                              bloqueada: _hablando,
                              alElegir: _elegirColor,
                              niveles: <double>[
                                for (final c in _colores)
                                  paleta.nivel(c.nombre),
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
          if (_celebrando)
            Positioned.fill(
              child: Celebracion(
                key: ValueKey<String>('fiesta_${_dibujo.id}#$_reinicios'),
                alTerminar: () {
                  if (mounted) setState(() => _celebrando = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}
