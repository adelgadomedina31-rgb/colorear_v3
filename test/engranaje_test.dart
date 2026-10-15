import 'package:colorear_ninos/models/modo_pintado.dart';
import 'package:colorear_ninos/pantallas/pantalla_inicio.dart';
import 'package:colorear_ninos/pantallas/pantalla_padres.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayuda_pintar.dart';

void main() {
  setUp(prepararPrueba);

  testWidgets('el engranaje del menú abre los Ajustes', (tester) async {
    sinAvisosDeSonido();
    await tester.binding.setSurfaceSize(const Size(420, 860));
    await tester.pumpWidget(const MaterialApp(home: PantallaInicio()));
    await esperar(tester);
    final engranaje = find.byKey(const ValueKey<String>('engranaje'));
    expect(engranaje, findsOneWidget);

    // Un toque normal (ya no hace falta dejarlo apretado).
    await tester.tap(engranaje);
    await esperar(tester, vueltas: 10);
    expect(find.byType(PantallaPadres), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('modo_2')));
    await tester.pump();
    expect(ModoPintado.actual, ModoPintado.porObjeto);

    // Volver al menú.
    await tester.pageBack();
    await esperar(tester, vueltas: 10);
    expect(find.byType(PantallaPadres), findsNothing);
    expect(engranaje, findsOneWidget);
  });
}
