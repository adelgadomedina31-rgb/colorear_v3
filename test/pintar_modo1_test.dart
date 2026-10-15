import 'package:colorear_ninos/config.dart';
import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

// Cada prueba de pantalla va en su propio archivo: así cada una empieza con
// la app "recién abierta".
void main() {
  setUp(prepararPrueba);

  testWidgets(
      'Modo 1: al pintar la mitad con un color, la voz recomienda otro y '
      'ella elige (puede volver a elegir el mismo)', (tester) async {
    sinAvisosDeSonido();
    final dibujo = cuadrado('mitad');
    final lienzo = await abrirPantalla(tester, <Dibujo>[dibujo]);
    final paleta = PaletaDibujo.enMemoria('mitad')!;

    await elegirColor(tester, 0); // Rojo
    var toques = 0;
    while (!paleta.recomendado('Rojo') && toques < 25) {
      await tester.tapAt(enPantalla(lienzo, dibujo, cuadricula[toques]));
      toques++;
      await esperar(tester, vueltas: 3);
    }
    expect(paleta.recomendado('Rojo'), isTrue);
    await esperar(tester);
    expect(frases.where((f) => f == Ajustes.vozUsaOtroColor).length, 1);
    final mitad = await medir(tester, dibujo);
    expect(mitad.colores[0], greaterThan(Ajustes.parteParaRecomendar - 0.05));
    expect(mitad.pintado, lessThan(Ajustes.porcentajeCelebracion));

    // El color se soltó y no se eligió otro solo: los colores no se acaban.
    expect(colorElegido(tester), isNull);
    expect(hayTarritoElegido(), isFalse);
    expect(tarritosVisibles(tester).length, 5);

    // Sin color, tocar no pinta.
    Offset? enBlanco;
    for (final p in cuadricula.reversed) {
      if (await pintadoEn(tester, dibujo, p) == 0) {
        enBlanco = p;
        break;
      }
    }
    expect(enBlanco, isNotNull);
    await tocar(tester, lienzo, dibujo, enBlanco!);
    expect(await pintadoEn(tester, dibujo, enBlanco), 0);

    // Vuelve a elegir el rojo y sigue: la recomendación no se repite.
    frases.clear();
    final vecesElegido = await pintarHastaCelebrar(tester, lienzo, dibujo);
    expect(vecesElegido, 1);
    expect(celebracion, findsOneWidget);
    expect(frases, isNot(contains(Ajustes.vozUsaOtroColor)));
    await quitarCelebracion(tester);
    await cerrarPantalla(tester);
  });
}
