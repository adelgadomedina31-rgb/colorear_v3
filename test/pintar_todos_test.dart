import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

// Cada prueba de pantalla va en su propio archivo: así cada una empieza con
// la app "recién abierta".
void main() {
  setUp(prepararPrueba);

  testWidgets('si se acaban todos los colores, la bandeja dice ¡Muy bien!',
      (tester) async {
    sinAvisosDeSonido();
    final dibujo = cuadrado('todos');
    final lienzo = await abrirPantalla(tester, <Dibujo>[dibujo]);
    final paleta = PaletaDibujo.enMemoria('todos')!;
    final colores = PaletaDibujo.coloresDe(dibujo);
    final lugares = <Offset>[
      for (final y in const <double>[100, 300, 500, 700, 900])
        for (final x in const <double>[100, 300, 500, 700, 900])
          lienzo.topLeft +
              Offset(lienzo.width * x / 1000, lienzo.height * y / 1000),
    ];
    var toques = 0;
    while (paleta.disponibles(colores).isNotEmpty && toques < 400) {
      await tester.tapAt(lugares[toques % lugares.length]);
      toques++;
      await esperar(tester, vueltas: 3);
    }
    expect(paleta.disponibles(colores), isEmpty);
    await esperar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('¡Muy bien!'), findsOneWidget);
    expect(frases, contains('¡Se acabaron todos los colores! ¡Muy bien!'));
    for (final c in colores) {
      expect(paleta.gasto(c.nombre), lessThan(0.78), reason: c.nombre);
    }

    // Tocar el dibujo ya no pinta nada.
    final antes = <double>[for (final c in colores) paleta.gasto(c.nombre)];
    await tester.tapAt(lugares[12]);
    await esperar(tester);
    expect(<double>[for (final c in colores) paleta.gasto(c.nombre)], antes);

    // Borrar deja todo como nuevo.
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await esperar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('¡Muy bien!'), findsNothing);
    expect(tarritosVisibles(tester).length, 5);
    await cerrarPantalla(tester);
  });
}
