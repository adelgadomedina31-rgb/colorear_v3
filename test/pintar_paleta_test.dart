import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ayuda_pintar.dart';

// Cada prueba de pantalla va en su propio archivo: así cada una empieza con
// la app "recién abierta".
void main() {
  setUp(prepararPrueba);

  testWidgets('la paleta es de cada dibujo, se acaba al 70% y se reinicia',
      (tester) async {
    sinAvisosDeSonido();
    final sol = leerDibujo('sol.json');
    final luna = leerDibujo('luna.json');
    final lienzo = await abrirPantalla(tester, <Dibujo>[sol, luna]);

    // El sol tiene sus 5 colores; el primero (amarillo) está elegido.
    expect(tarritosVisibles(tester).length, 5);
    final paletaSol = PaletaDibujo.enMemoria('sol')!;
    expect(paletaSol.disponibles(PaletaDibujo.coloresDe(sol)).length, 5);

    // Se pinta con amarillo, muchos toques, hasta que se acabe.
    Offset punto(double x, double y) =>
        lienzo.topLeft + Offset(lienzo.width * x / 1000, lienzo.height * y / 1000);
    // Toques repartidos por todo el dibujo (cielo, cara y rayos del sol).
    final lugares = <Offset>[
      for (final y in const <double>[80, 220, 360, 500, 640, 780, 920])
        for (final x in const <double>[80, 220, 360, 500, 640, 780, 920])
          Offset(x, y),
    ];
    var toques = 0;
    while (!paletaSol.acabado('Amarillo') && toques < 150) {
      final l = lugares[toques % lugares.length];
      await tester.tapAt(punto(l.dx, l.dy));
      toques++;
      await esperar(tester, vueltas: 4);
    }
    expect(paletaSol.acabado('Amarillo'), isTrue,
        reason: 'el amarillo debía acabarse');
    // No se pasa del 70% (más o menos).
    expect(paletaSol.gasto('Amarillo'), lessThan(0.76));
    expect(paletaSol.gasto('Amarillo'), greaterThan(0.68));
    await esperar(tester);
    expect(frases, contains('¡Se acabó el color amarillo!'));
    // Desapareció de la paleta: quedan 4.
    await tester.pump(const Duration(seconds: 1));
    expect(tarritosVisibles(tester).length, 4);

    // Si sigue tocando, pinta con el siguiente color (naranja).
    await tester.tapAt(punto(500, 80));
    await esperar(tester);
    expect(paletaSol.gasto('Naranja'), greaterThan(0));

    // La luna tiene su propia paleta, completa.
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await esperar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(tarritosVisibles(tester).length, 5);
    final paletaLuna = PaletaDibujo.enMemoria('luna')!;
    expect(paletaLuna.acabado('Azul'), isFalse);

    // Al volver al sol, su paleta está como se dejó (sin amarillo).
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await esperar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(tarritosVisibles(tester).length, 4);

    // Y quedó guardada en el celular.
    await PaletaDibujo.guardarPendientes();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('paleta_sol'), contains('Amarillo'));

    // Borrar (sin preguntar): se borra lo pintado y la paleta vuelve completa.
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await esperar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tarritosVisibles(tester).length, 5);
    final paletaNueva = PaletaDibujo.enMemoria('sol')!;
    expect(paletaNueva.acabado('Amarillo'), isFalse);
    expect(paletaNueva.gasto('Naranja'), 0);
    expect(prefs.getString('paleta_sol'), isNull);

    await cerrarPantalla(tester);
  });
}
