import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

// Cada prueba de pantalla va en su propio archivo: así cada una empieza con
// la app "recién abierta".
void main() {
  setUp(prepararPrueba);

  testWidgets('arrastrando el dedo tampoco se pasa del 70%', (tester) async {
    sinAvisosDeSonido();
    final dibujo = cuadrado('arrastre');
    final lienzo = await abrirPantalla(tester, <Dibujo>[dibujo]);
    final paleta = PaletaDibujo.enMemoria('arrastre')!;
    final primero = PaletaDibujo.coloresDe(dibujo).first.nombre; // Rojo
    Offset punto(double x, double y) =>
        lienzo.topLeft + Offset(lienzo.width * x / 1000, lienzo.height * y / 1000);

    // Zigzag por todo el dibujo, sin levantar el dedo.
    var pasadas = 0;
    while (!paleta.acabado(primero) && pasadas < 12) {
      final dedo = await tester.startGesture(punto(60, 60));
      for (var fila = 0; fila < 8 && !paleta.acabado(primero); fila++) {
        final y = 60.0 + fila * 125;
        for (var k = 0; k <= 10; k++) {
          final x = fila.isEven ? 60.0 + k * 88 : 940.0 - k * 88;
          await dedo.moveTo(punto(x, y));
          await tester.pump(const Duration(milliseconds: 16));
          if (k % 3 == 0) await esperar(tester, vueltas: 1);
        }
      }
      await dedo.up();
      await esperar(tester, vueltas: 4);
      pasadas++;
    }
    expect(paleta.acabado(primero), isTrue);
    expect(paleta.gasto(primero), lessThan(0.78));
    await cerrarPantalla(tester);
  });
}
