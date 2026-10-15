/// Ayudas para las pruebas de los juegos de Colores y Animales.
library;

import 'package:colorear_ninos/juegos/animales/animales_ajustes.dart';
import 'package:colorear_ninos/juegos/colores/colores_ajustes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

/// Lo que se ve con una clave que empieza con [prefijo] ('globo_', 'animal_').
Finder conClave(String prefijo) => find.byWidgetPredicate((w) {
      final clave = w.key;
      return clave is ValueKey<String> && clave.value.startsWith(prefijo);
    });

/// Los nombres (lo que va después del prefijo) de lo que se ve.
List<String> nombresCon(WidgetTester tester, String prefijo) => <String>[
      for (final w in tester.widgetList(conClave(prefijo)))
        (w.key! as ValueKey<String>).value.substring(prefijo.length),
    ];

/// Las estrellas que muestra la barra de arriba.
int estrellas(WidgetTester tester) => int.parse(
    tester.widget<Text>(find.byKey(const ValueKey<String>('estrellas'))).data!);

// ------------------------------------------------------------------ Colores

/// Lo que dice la voz para pedir el globo de color [nombre] ('Rojo').
String pedirGlobo(String nombre) =>
    AjustesColores.vozBusca.replaceAll('{color}', nombre.toLowerCase());

/// El color que pidió la voz por última vez, como en las claves ('Rojo').
String globoPedido() {
  final pedidos = <String, String>{
    for (final c in AjustesColores.colores) pedirGlobo(c): c,
  };
  return pedidos[frases.lastWhere(pedidos.containsKey)]!;
}

/// Toca el globo de color [nombre] ('Rojo').
Future<void> tocarGlobo(WidgetTester tester, String nombre) async {
  await tester.tap(find.byKey(ValueKey<String>('globo_$nombre')));
  await esperar(tester, vueltas: 3);
}

/// Toca el globo correcto y espera a que empiece la siguiente ronda.
Future<void> acertarGlobo(WidgetTester tester) async {
  await tocarGlobo(tester, globoPedido());
  await tester.pump(const Duration(milliseconds: 4600));
  await esperar(tester, vueltas: 3);
}

// ----------------------------------------------------------------- Animales

/// La pregunta de la voz por el animal [a].
String preguntaPor(Animal a) =>
    AjustesAnimales.vozPregunta.replaceAll('{sonido}', a.sonido);

/// El animal por el que preguntó la voz por última vez.
Animal animalPedido() {
  final preguntas = <String, Animal>{
    for (final a in AjustesAnimales.animales) preguntaPor(a): a,
  };
  return preguntas[frases.lastWhere(preguntas.containsKey)]!;
}

/// Toca al animal [id] ('perro').
Future<void> tocarAnimal(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey<String>('animal_$id')));
  await esperar(tester, vueltas: 3);
}

/// Toca al animal correcto y espera a que empiece la siguiente ronda (en la
/// prueba la voz nunca avisa que terminó: se espera lo más que espera la
/// app).
Future<void> acertarAnimal(WidgetTester tester) async {
  await tocarAnimal(tester, animalPedido().id);
  await tester.pump(const Duration(milliseconds: 4600));
  await esperar(tester, vueltas: 3);
}
