/// Ayudas para las pruebas de la pantalla de pintar.
library;

import 'dart:io';

import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/pantallas/pantalla_pintar.dart';
import 'package:colorear_ninos/widgets/lienzo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lo que dijo la voz durante la prueba.
final List<String> frases = <String>[];

/// La voz y los sonidos "de mentira": la voz anota lo que diría.
void simularCelular() {
  final mensajero =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  mensajero.setMockMethodCallHandler(const MethodChannel('flutter_tts'),
      (llamada) async {
    if (llamada.method == 'speak') frases.add('${llamada.arguments}');
    return 1;
  });
  for (final canal in <String>[
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
  ]) {
    mensajero.setMockMethodCallHandler(MethodChannel(canal), (_) async => null);
  }
}

Dibujo leerDibujo(String archivo) =>
    Dibujo.desdeTexto(File('assets/drawings/$archivo').readAsStringSync());

/// Los tarritos que se ven en la paleta.
Iterable<Widget> tarritosVisibles(WidgetTester tester) => tester.widgetList(
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Tarrito'));

/// Deja correr el tiempo de verdad (para las mediciones) y el de la prueba.
Future<void> esperar(WidgetTester tester, {int vueltas = 8}) async {
  for (var k = 0; k < vueltas; k++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Los sonidos no existen en la prueba: se ignoran sus avisos.
void sinAvisosDeSonido() {
  final avisoOriginal = FlutterError.onError;
  FlutterError.onError = (detalles) {
    if (detalles.exception is MissingPluginException) return;
    avisoOriginal?.call(detalles);
  };
  addTearDown(() => FlutterError.onError = avisoOriginal);
}

/// Un dibujo de prueba: un solo cuadrado grande (sin paleta en config.dart,
/// así que usa la de por defecto).
Dibujo cuadrado(String id) => Dibujo.desdeTexto(
      '{"id":"$id","regiones":[{"id":"todo",'
      '"path":"M 0 0 L 1000 0 L 1000 1000 L 0 1000 Z"}]}',
    );

/// Abre la pantalla de pintar y devuelve dónde quedó el dibujo.
Future<Rect> abrirPantalla(WidgetTester tester, List<Dibujo> dibujos) async {
  await tester.binding.setSurfaceSize(const Size(420, 860));
  await tester.pumpWidget(MaterialApp(
    home: PantallaPintar(dibujos: dibujos, indice: 0),
  ));
  await esperar(tester);
  return tester.getRect(find
      .descendant(of: find.byType(Lienzo), matching: find.byType(Listener))
      .first);
}

/// La celebración de "¡Felicidades!" (si está a la vista).
final Finder celebracion = find.byKey(const ValueKey<String>('celebracion'));

/// Toca la celebración para quitarla y espera a que se vaya.
Future<void> quitarCelebracion(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(celebracion);
  for (var k = 0; k < 8; k++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Cierra la pantalla y deja terminar las esperas de la voz y los sonidos.
Future<void> cerrarPantalla(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
}

/// Lo que se prepara antes de cada prueba.
void prepararPrueba() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  frases.clear();
  simularCelular();
}
