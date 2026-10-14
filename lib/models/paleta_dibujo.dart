import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'dibujo.dart';

/// La paleta de UN dibujo: qué colores tiene y cuánto pintó cada uno.
///
/// - Cada dibujo tiene sus propios colores (como mucho 5, ver config.dart).
/// - Cada color puede pintar como mucho [Ajustes.limitePorColor] del dibujo
///   (el 70%). Lo que cuenta es cuánto del dibujo llegó a cubrir ese color:
///   pintar encima de algo que ya es de ese mismo color no gasta más.
/// - Cuando un color llega al límite se acaba: desaparece de la paleta de ese
///   dibujo y no vuelve hasta que se borre lo pintado.
/// - Cada dibujo guarda su paleta aparte, en el celular. Un dibujo sin pintar
///   empieza con la paleta completa, y uno ya pintado aparece como se dejó.
/// - También recuerda si ya salió la celebración de ese dibujo (sale una
///   sola vez, hasta que se borre lo pintado).
class PaletaDibujo extends ChangeNotifier {
  PaletaDibujo._(this.id);

  final String id;

  /// La mayor parte del dibujo (0 a 1) que llegó a cubrir cada color.
  final Map<String, double> _gasto = <String, double>{};

  /// Colores que ya se acabaron en este dibujo.
  final Set<String> _acabados = <String>{};

  bool _celebrado = false;

  static final Map<String, PaletaDibujo> _memoria = <String, PaletaDibujo>{};
  static final Set<PaletaDibujo> _sinGuardar = <PaletaDibujo>{};
  static Timer? _temporizador;
  static const String _prefijo = 'paleta_';

  /// Un color se da por acabado un poquito antes del límite exacto, para que
  /// las últimas gotas no se hagan eternas.
  static const double _tolerancia = 0.015;

  // ------------------------------------------------------- colores del dibujo

  /// Los colores de [d], en orden (el primero queda elegido al entrar).
  /// Se buscan en config.dart ([Ajustes.paletasDibujos]), después en el
  /// propio dibujo (campo "colores" del JSON) y si no, se usan los de
  /// [Ajustes.paletaPorDefecto].
  static List<ColorConNombre> coloresDe(Dibujo d) {
    for (final nombres in <List<String>>[
      Ajustes.paletasDibujos[d.id] ?? const <String>[],
      d.colores,
      Ajustes.paletaPorDefecto,
    ]) {
      final lista = _buscar(nombres);
      if (lista.isNotEmpty) return lista;
    }
    return Ajustes.colores.take(Ajustes.maxColoresPorDibujo).toList();
  }

  static List<ColorConNombre> _buscar(List<String> nombres) {
    final lista = <ColorConNombre>[];
    for (final nombre in nombres) {
      final buscado = _normalizar(nombre);
      for (final c in Ajustes.colores) {
        if (_normalizar(c.nombre) == buscado && !lista.contains(c)) {
          lista.add(c);
          break;
        }
      }
      if (lista.length >= Ajustes.maxColoresPorDibujo) break;
    }
    return lista;
  }

  /// "Marrón" = "marron" = "MARRON".
  static String _normalizar(String texto) {
    const conTilde = 'áéíóúü';
    const sinTilde = 'aeiouu';
    final minusculas = texto.trim().toLowerCase();
    final salida = StringBuffer();
    for (final letra in minusculas.split('')) {
      final i = conTilde.indexOf(letra);
      salida.write(i >= 0 ? sinTilde[i] : letra);
    }
    return salida.toString();
  }

  // ------------------------------------------------------------------ estado

  /// Cuánto del dibujo llegó a cubrir el color (0 a 1).
  double gasto(String nombre) => _gasto[nombre] ?? 0;

  bool acabado(String nombre) => _acabados.contains(nombre);

  /// Lo que le queda al tarrito del color: 1 = lleno, 0 = vacío.
  double nivel(String nombre) {
    if (acabado(nombre)) return 0;
    return (1 - gasto(nombre) / Ajustes.limitePorColor)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// Cuánto más del dibujo puede pintar el color (0 a 1).
  double margen(String nombre) {
    if (acabado(nombre)) return 0;
    return math.max(0.0, Ajustes.limitePorColor - gasto(nombre));
  }

  /// Los colores de [colores] que todavía no se acabaron.
  List<ColorConNombre> disponibles(List<ColorConNombre> colores) =>
      <ColorConNombre>[
        for (final c in colores)
          if (!acabado(c.nombre)) c,
      ];

  /// Anota cuánto del dibujo cubre ahora cada color ([cobertura] va en el
  /// mismo orden que [colores]). Devuelve los colores que se acabaron justo
  /// con esta medición.
  List<ColorConNombre> actualizar(
    List<ColorConNombre> colores,
    List<double> cobertura,
  ) {
    final recienAcabados = <ColorConNombre>[];
    var cambio = false;
    for (var i = 0; i < colores.length && i < cobertura.length; i++) {
      final nombre = colores[i].nombre;
      if (_acabados.contains(nombre)) continue;
      final ahora = cobertura[i];
      if (ahora > gasto(nombre) + 0.002) {
        _gasto[nombre] = ahora;
        cambio = true;
      }
      if (gasto(nombre) >= Ajustes.limitePorColor - _tolerancia) {
        _acabados.add(nombre);
        recienAcabados.add(colores[i]);
        cambio = true;
      }
    }
    if (cambio) {
      _marcarCambio();
      notifyListeners();
    }
    return recienAcabados;
  }

  /// true si ya salió la celebración de este dibujo.
  bool get celebrado => _celebrado;

  /// Anota que ya salió la celebración (para que no se repita).
  void marcarCelebrado() {
    if (_celebrado) return;
    _celebrado = true;
    _marcarCambio();
  }

  // ------------------------------------------------- memoria y guardado

  /// La paleta de [id] si ya se leyó (si no, null).
  static PaletaDibujo? enMemoria(String id) => _memoria[id];

  /// Lee la paleta guardada de [id] (completa si nunca se pintó).
  static Future<PaletaDibujo> cargar(String id) async {
    final hay = _memoria[id];
    if (hay != null) return hay;
    final nueva = PaletaDibujo._(id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString('$_prefijo$id');
      if (texto != null) nueva._leer(texto);
    } catch (_) {
      // Si no se pudo leer, se empieza con la paleta completa.
    }
    // Mientras se leía pudo leerse o borrarse otra vez: gana la que ya está.
    return _memoria.putIfAbsent(id, () => nueva);
  }

  /// Lee de una vez las paletas de todos estos dibujos (al abrir la app),
  /// así al entrar a un dibujo la paleta ya está lista.
  static Future<void> cargarVarias(Iterable<String> ids) async {
    try {
      await Future.wait(ids.map(cargar));
    } catch (_) {}
  }

  /// Deja la paleta de [id] completa otra vez y borra lo guardado
  /// (se llama al borrar lo pintado).
  static void olvidar(String id) {
    final vieja = _memoria[id];
    if (vieja != null) _sinGuardar.remove(vieja);
    _memoria[id] = PaletaDibujo._(id);
    _quitarGuardada(id);
  }

  static Future<void> _quitarGuardada(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefijo$id');
    } catch (_) {}
  }

  void _marcarCambio() {
    _sinGuardar.add(this);
    _temporizador?.cancel();
    _temporizador = Timer(const Duration(seconds: 2), guardarPendientes);
  }

  /// Guarda ya mismo las paletas que cambiaron.
  static Future<void> guardarPendientes() async {
    _temporizador?.cancel();
    _temporizador = null;
    if (_sinGuardar.isEmpty) return;
    final lista = _sinGuardar.toList();
    _sinGuardar.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final paleta in lista) {
        // Si se borró lo pintado mientras tanto, ya no se guarda.
        if (!identical(_memoria[paleta.id], paleta)) continue;
        await prefs.setString('$_prefijo${paleta.id}', paleta._aTexto());
      }
    } catch (_) {
      // Si no se pudo guardar, se reintenta con el próximo cambio.
    }
  }

  String _aTexto() => jsonEncode(<String, Object>{
        'gasto': _gasto,
        'acabados': _acabados.toList(),
        if (_celebrado) 'celebrado': true,
      });

  void _leer(String texto) {
    try {
      final datos = jsonDecode(texto);
      if (datos is! Map) return;
      final gasto = datos['gasto'];
      if (gasto is Map) {
        gasto.forEach((nombre, valor) {
          if (nombre is String && valor is num)
            _gasto[nombre] = valor.toDouble();
        });
      }
      final acabados = datos['acabados'];
      if (acabados is List) {
        for (final nombre in acabados) {
          if (nombre is String) _acabados.add(nombre);
        }
      }
      _celebrado = datos['celebrado'] == true;
    } catch (_) {
      // Datos dañados: se empieza con la paleta completa.
      _gasto.clear();
      _acabados.clear();
      _celebrado = false;
    }
  }
}
