import 'package:colorear_ninos/servicios/voz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los nombres de las grabaciones van sin tildes ni espacios', () {
    expect(Voz.clave('Marrón'), 'marron');
    expect(Voz.clave('Se acabó el color'), 'se_acabo_el_color');
    expect(Voz.clave('  ¡Rojo!  '), 'rojo');
    expect(Voz.clave('YA-NO quedan colores'), 'ya_no_quedan_colores');
  });
}
