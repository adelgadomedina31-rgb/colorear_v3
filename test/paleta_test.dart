import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:colorear_ninos/config.dart';
import 'package:colorear_ninos/models/dibujo.dart';
import 'package:colorear_ninos/models/paleta_dibujo.dart';
import 'package:colorear_ninos/models/pintura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dibujo _dibujo(String id, {List<String> colores = const <String>[]}) => Dibujo(
      id: id,
      nombre: id,
      lado: 1000,
      regiones: <Region>[],
      detalles: <Detalle>[],
      colores: colores,
    );

List<String> _nombres(List<ColorConNombre> lista) =>
    <String>[for (final c in lista) c.nombre];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('colores de cada dibujo', () {
    test('los dibujos de la app tienen su paleta de hasta 5 colores', () {
      final indice = jsonDecode(
        File('assets/drawings/indice.json').readAsStringSync(),
      ) as List<dynamic>;
      for (final archivo in indice.cast<String>()) {
        final datos = jsonDecode(
          File('assets/drawings/$archivo').readAsStringSync(),
        ) as Map<String, dynamic>;
        final id = datos['id'] as String;
        final nombres = Ajustes.paletasDibujos[id];
        expect(nombres, isNotNull, reason: 'falta la paleta de "$id"');
        final colores = PaletaDibujo.coloresDe(_dibujo(id));
        // Todos los nombres existen en la lista de colores.
        expect(colores.length, nombres!.length, reason: id);
        expect(colores.length, inInclusiveRange(1, 5), reason: id);
      }
    });

    test('un dibujo con "colores" en su JSON usa esos (con o sin tilde)', () {
      final d = Dibujo.desdeTexto(
        '{"id":"foto_gato","regiones":[{"path":"M 0 0 L 10 0 L 10 10 Z"}],'
        '"colores":["naranja","MARRON","Rosado","Celeste","Verde","Rojo"]}',
      );
      expect(_nombres(PaletaDibujo.coloresDe(d)),
          <String>['Naranja', 'Marrón', 'Rosado', 'Celeste', 'Verde']);
    });

    test('sin paleta propia usa la de por defecto', () {
      expect(_nombres(PaletaDibujo.coloresDe(_dibujo('foto_nuevo'))),
          Ajustes.paletaPorDefecto);
    });
  });

  group('cada color pinta como mucho el 70%', () {
    test('al llegar al límite se acaba y no vuelve', () async {
      final colores = PaletaDibujo.coloresDe(_dibujo('sol'));
      expect(colores.first.nombre, 'Amarillo');
      final paleta = await PaletaDibujo.cargar('limite');
      expect(paleta.actualizar(colores, <double>[0.35, 0, 0, 0, 0]), isEmpty);
      expect(paleta.nivel('Amarillo'), closeTo(0.5, 0.01));
      final acabados = paleta.actualizar(colores, <double>[0.70, 0.1, 0, 0, 0]);
      expect(_nombres(acabados), <String>['Amarillo']);
      expect(paleta.acabado('Amarillo'), isTrue);
      expect(paleta.nivel('Amarillo'), 0);
      expect(paleta.margen('Amarillo'), 0);
      expect(paleta.disponibles(colores).length, 4);
      // Aunque después se pinte encima con otro color, no vuelve.
      expect(paleta.actualizar(colores, <double>[0.1, 0.6, 0, 0, 0]), isEmpty);
      expect(paleta.acabado('Amarillo'), isTrue);
    });

    test('cuenta lo más que llegó a cubrir (tapar un color no lo rellena)',
        () async {
      final colores = PaletaDibujo.coloresDe(_dibujo('sol'));
      final paleta = await PaletaDibujo.cargar('maximo');
      paleta.actualizar(colores, <double>[0.5, 0, 0, 0, 0]);
      paleta.actualizar(colores, <double>[0.2, 0.3, 0, 0, 0]);
      expect(paleta.gasto('Amarillo'), closeTo(0.5, 0.001));
      expect(paleta.margen('Amarillo'), closeTo(0.2, 0.001));
    });
  });

  group('cada dibujo guarda su paleta', () {
    test('la paleta de un dibujo no se mezcla con la de otro', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'paleta_pintado': '{"gasto":{"Rojo":0.71},"acabados":["Rojo"]}',
      });
      final pintado = await PaletaDibujo.cargar('pintado');
      expect(pintado.acabado('Rojo'), isTrue);
      final nuevo = await PaletaDibujo.cargar('sin_pintar');
      expect(nuevo.acabado('Rojo'), isFalse);
      expect(nuevo.gasto('Rojo'), 0);
    });

    test('se guarda en el celular', () async {
      final colores = PaletaDibujo.coloresDe(_dibujo('casa'));
      final paleta = await PaletaDibujo.cargar('guardar');
      paleta.actualizar(colores, <double>[0.4, 0.2, 0, 0, 0]);
      await PaletaDibujo.guardarPendientes();
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString('paleta_guardar');
      expect(texto, isNotNull);
      expect(texto, contains('Rojo'));
    });

    test('recuerda si ya salió la celebración', () async {
      final paleta = await PaletaDibujo.cargar('celebrado');
      expect(paleta.celebrado, isFalse);
      paleta.marcarCelebrado();
      await PaletaDibujo.guardarPendientes();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('paleta_celebrado'), contains('celebrado'));
      Pintura.borrarId('celebrado');
      expect(PaletaDibujo.enMemoria('celebrado')!.celebrado, isFalse);
    });

    test('la celebración guardada se lee al abrir la app', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'paleta_terminado': '{"gasto":{"Rojo":0.71},"acabados":["Rojo"],'
            '"celebrado":true}',
      });
      final paleta = await PaletaDibujo.cargar('terminado');
      expect(paleta.celebrado, isTrue);
    });

    test('borrar lo pintado deja la paleta completa y borra lo guardado',
        () async {
      final colores = PaletaDibujo.coloresDe(_dibujo('sol'));
      final vieja = await PaletaDibujo.cargar('borrar');
      vieja.actualizar(colores, <double>[0.7, 0.3, 0, 0, 0]);
      await PaletaDibujo.guardarPendientes();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('paleta_borrar'), isNotNull);

      Pintura.borrarId('borrar');
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('paleta_borrar'), isNull);
      final nueva = PaletaDibujo.enMemoria('borrar')!;
      expect(identical(nueva, vieja), isFalse);
      expect(nueva.acabado('Amarillo'), isFalse);
      expect(nueva.disponibles(colores).length, 5);

      // Algo que llegue tarde para la paleta vieja ya no se guarda.
      vieja.actualizar(colores, <double>[0.7, 0.7, 0.7, 0, 0]);
      await PaletaDibujo.guardarPendientes();
      expect(prefs.getString('paleta_borrar'), isNull);
    });
  });

  testWidgets('se mide cuánto del dibujo cubre cada color', (tester) async {
    await tester.runAsync(() async {
      // Un fondo que cubre todo y un cuadro encima en la mitad izquierda.
      final d = Dibujo.desdeTexto(
        '{"id":"medida","regiones":['
        '{"id":"fondo","path":"M 0 0 L 1000 0 L 1000 1000 L 0 1000 Z"},'
        '{"id":"cuadro","path":"M 0 0 L 500 0 L 500 1000 L 0 1000 Z"}]}',
      );
      const rojo = Color(0xFFE53935);
      const azul = Color(0xFF1E88E5);
      const amarillo = Color(0xFFFDD835);
      // Manchas gigantes: el rojo llena el cuadro y el azul el fondo (que
      // queda tapado por el cuadro en la mitad izquierda).
      final manchaRoja = Trazo(
        region: 1,
        color: rojo,
        radio: 1500,
        semilla: 0,
        inicio: const Offset(250, 500),
      );
      final manchaAzul = Trazo(
        region: 0,
        color: azul,
        radio: 1500,
        semilla: 0,
        inicio: const Offset(750, 500),
      );
      final medida = await Pintura.medirColores(
        d,
        <Trazo>[manchaRoja, manchaAzul],
        const <Color>[rojo, azul, amarillo],
      );
      expect(medida, isNotNull);
      expect(medida!.colores[0], closeTo(0.5, 0.03));
      expect(medida.colores[1], closeTo(0.5, 0.03));
      expect(medida.colores[2], 0);
      // Todo el dibujo está pintado.
      expect(medida.pintado, closeTo(1.0, 0.02));
      expect(Pintura.fraccionPintable('medida'), closeTo(1.0, 0.01));

      // Solo el azul, en el fondo: cubre la mitad derecha.
      final soloAzul = await Pintura.medirColores(
        d,
        <Trazo>[
          Trazo(
            region: 0,
            color: azul,
            radio: 1500,
            semilla: 0,
            inicio: const Offset(750, 500),
          ),
        ],
        const <Color>[rojo, azul],
      );
      expect(soloAzul!.colores[0], 0);
      expect(soloAzul.colores[1], closeTo(0.5, 0.03));
      // Lo pintado cuenta igual aunque el color no esté en la paleta.
      expect(soloAzul.pintado, closeTo(0.5, 0.03));
      final sinPaleta = await Pintura.medirColores(
        d,
        <Trazo>[
          Trazo(
            region: 0,
            color: azul,
            radio: 1500,
            semilla: 0,
            inicio: const Offset(750, 500),
          ),
        ],
        const <Color>[rojo],
      );
      expect(sinPaleta!.colores[0], 0);
      expect(sinPaleta.pintado, closeTo(0.5, 0.03));
    });
  });
}
