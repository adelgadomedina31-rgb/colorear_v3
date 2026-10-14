import 'package:colorear_ninos/config.dart';
import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

// Cada prueba de pantalla va en su propio archivo: así cada una empieza con
// la app "recién abierta".
void main() {
  setUp(prepararPrueba);

  testWidgets(
      'al pintar el 95% del dibujo sale la celebración (sin usar todos '
      'los colores)', (tester) async {
    sinAvisosDeSonido();
    final dibujo = cuadrado('fiesta');
    final lienzo = await abrirPantalla(tester, <Dibujo>[dibujo]);
    final paleta = PaletaDibujo.enMemoria('fiesta')!;
    final colores = PaletaDibujo.coloresDe(dibujo);
    final fiesta = celebracion;
    final lugares = <Offset>[
      for (final y in const <double>[100, 300, 500, 700, 900])
        for (final x in const <double>[100, 300, 500, 700, 900])
          lienzo.topLeft +
              Offset(lienzo.width * x / 1000, lienzo.height * y / 1000),
    ];
    var toques = 0;
    var vioPrimerAcabado = false;
    while (fiesta.evaluate().isEmpty && toques < 300) {
      await tester.tapAt(lugares[toques % lugares.length]);
      toques++;
      await esperar(tester, vueltas: 3);
      if (!vioPrimerAcabado && paleta.disponibles(colores).length < 5) {
        vioPrimerAcabado = true;
        // Con un solo color (el 70%) todavía no está terminado.
        expect(fiesta, findsNothing);
        expect(paleta.celebrado, isFalse);
      }
    }
    expect(vioPrimerAcabado, isTrue);
    expect(fiesta, findsOneWidget);
    expect(paleta.celebrado, isTrue);
    // No hizo falta gastar todos los colores.
    expect(paleta.disponibles(colores), isNotEmpty);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text(Ajustes.celebracionLinea1), findsOneWidget);
    expect(find.text(Ajustes.celebracionLinea2), findsOneWidget);
    expect(
      find.descendant(of: fiesta, matching: find.byIcon(Icons.star_rounded)),
      findsAtLeastNWidgets(12),
    );
    await esperar(tester, vueltas: 2);
    expect(frases, contains(Ajustes.vozCelebracion));

    // Se va sola después de unos segundos.
    await tester.pump(const Duration(seconds: Ajustes.segundosCelebracion));
    await tester.pump(const Duration(seconds: 1));
    expect(fiesta, findsNothing);

    // Seguir pintando no la repite.
    frases.clear();
    for (var k = 0; k < 6; k++) {
      await tester.tapAt(lugares[k]);
      await esperar(tester, vueltas: 3);
    }
    expect(fiesta, findsNothing);
    expect(frases, isNot(contains(Ajustes.vozCelebracion)));

    // Borrar lo pintado deja que vuelva a salir la próxima vez.
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await esperar(tester);
    expect(PaletaDibujo.enMemoria('fiesta')!.celebrado, isFalse);
    await cerrarPantalla(tester);
  });
}
