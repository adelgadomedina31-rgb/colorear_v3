import 'package:flutter/material.dart';

/// Un color de la paleta y el nombre que dice la voz al elegirlo.
class ColorConNombre {
  const ColorConNombre(this.color, this.nombre);

  final Color color;
  final String nombre;
}

/// Ajustes de la app. Cambia estos valores para afinar cómo se siente.
///
/// Los dibujos se definen en un cuadrado de 1000 x 1000 unidades; las medidas
/// de abajo usan esas mismas unidades (100 = un 10% del ancho del dibujo).
class Ajustes {
  Ajustes._();

  // ---------------------------------------------------------------- pintura

  /// Las zonas con un área visible menor a esta se pintan completas con un
  /// solo toque. 30000 equivale a un cuadrado de unos 173 x 173.
  static const double areaUnToque = 30000;

  /// Cuántos toques, más o menos, hacen falta para llenar una zona que apenas
  /// pasa el tamaño de "un toque" y una zona enorme (el cielo, el fondo).
  /// Las zonas intermedias quedan entre esos dos números.
  /// Más toques = manchas más chicas.
  static const double toquesZonaChica = 3;
  static const double toquesZonaGrande = 10;

  /// Área que se considera "zona enorme" (casi todo el dibujo).
  static const double areaZonaGrande = 700000;

  /// Multiplica el tamaño de todas las manchas. 1.2 = un 20% más grandes.
  static const double escalaMancha = 1.2;

  /// Límites para el tamaño (radio) de cada mancha.
  static const double radioMinimo = 80;
  static const double radioMaximo = 310;

  /// Cuando a un color le queda poca pintura, sus manchas salen más chicas;
  /// este es el tamaño (radio) de la mancha más chica, la "última gota".
  static const double radioUltimaGota = 45;

  /// Cuánto tarda la pintura en "derramarse" hasta su tamaño final
  /// (milisegundos).
  static const int duracionDerrame = 650;

  /// Al arrastrar el dedo se pinta una franja; su ancho es el radio de la
  /// mancha multiplicado por este número.
  static const double anchoArrastre = 1.2;

  /// Grosor de la línea negra de los contornos.
  static const double grosorContorno = 10;

  /// Color de fondo de las pantallas (el "papel" de los dibujos es blanco).
  static const Color fondoApp = Color(0xFFFFF4D6);

  // --------------------------------------------------------------- sonidos

  /// true = suena un "plop" al pintar.
  static const bool sonidoPintar = true;

  /// Volumen del "plop" (0 a 1).
  static const double volumenPintar = 0.7;

  /// Al arrastrar el dedo, suena otro "plop" cada esta distancia recorrida.
  static const double distanciaEntrePlops = 300;

  // ---------------------------------------------------------- presentación

  /// true = al abrir la app se muestra la presentación con estrellas.
  static const bool mostrarPresentacion = true;

  /// Lo que se ve en grande en la presentación (dos líneas).
  static const String presentacionLinea1 = 'PINTEMOS';
  static const String presentacionLinea2 = 'ARLETH';

  // ------------------------------------------------------------------- voz

  /// true = al elegir un color, una voz dice su nombre.
  static const bool vozActiva = true;

  /// Tono de la voz: 1.0 es normal; más alto suena más infantil (máximo 2.0).
  static const double vozTono = 1.5;

  /// Velocidad de la voz: 0.5 es normal; más bajo = más lento y claro.
  static const double vozVelocidad = 0.42;

  /// Pausa mínima (milisegundos) antes de poder elegir otro color, aunque la
  /// voz termine antes. La paleta también espera a que la voz termine.
  static const int pausaMinimaColor = 700;

  // ------------------------------------------------- paleta de cada dibujo

  /// Cada color puede pintar como mucho esta parte del dibujo
  /// (0.70 = el 70% de todo lo que se puede pintar). Cuando llega ahí, la voz
  /// dice que se acabó y el color desaparece de la paleta de ese dibujo.
  static const double limitePorColor = 0.70;

  /// Cuántos colores, como mucho, tiene la paleta de cada dibujo.
  static const int maxColoresPorDibujo = 5;

  /// Lo que dice la voz. {color} se cambia por el nombre del color.
  static const String vozSeAcabo = '¡Se acabó el color {color}!';
  static const String vozSeAcabaronTodos =
      '¡Se acabaron todos los colores! ¡Muy bien!';
  static const String vozEligeOtro = '¡Elige otro color!';

  /// Lo que dice si toca el dibujo cuando ya no queda ningún color.
  static const String vozSinColores = '¡Ya no quedan colores! Elige otro dibujo.';

  // ---------------------------------------------------------------- colores

  /// Todos los colores que conoce la app, con el nombre que dice la voz.
  /// Cada dibujo usa solo algunos (ver [paletasDibujos]).
  static const List<ColorConNombre> colores = <ColorConNombre>[
    ColorConNombre(Color(0xFFE53935), 'Rojo'),
    ColorConNombre(Color(0xFFFB8C00), 'Naranja'),
    ColorConNombre(Color(0xFFFDD835), 'Amarillo'),
    ColorConNombre(Color(0xFF7CB342), 'Verde'),
    ColorConNombre(Color(0xFF00ACC1), 'Celeste'),
    ColorConNombre(Color(0xFF1E88E5), 'Azul'),
    ColorConNombre(Color(0xFF8E24AA), 'Morado'),
    ColorConNombre(Color(0xFFEC407A), 'Rosado'),
    ColorConNombre(Color(0xFF8D6E63), 'Marrón'),
    ColorConNombre(Color(0xFF90A4AE), 'Gris'),
    ColorConNombre(Color(0xFF424242), 'Negro'),
  ];

  /// Los colores de cada dibujo (como mucho 5), con su "id".
  /// Se escriben con el mismo nombre que en la lista [colores].
  /// El primero de la lista es el que queda elegido al entrar al dibujo.
  static const Map<String, List<String>> paletasDibujos = <String, List<String>>{
    'sol': <String>['Amarillo', 'Naranja', 'Celeste', 'Rojo', 'Rosado'],
    'flor': <String>['Rosado', 'Amarillo', 'Verde', 'Celeste', 'Morado'],
    'pez': <String>['Naranja', 'Amarillo', 'Celeste', 'Azul', 'Verde'],
    'casa': <String>['Rojo', 'Amarillo', 'Celeste', 'Verde', 'Marrón'],
    'gato': <String>['Naranja', 'Gris', 'Rosado', 'Amarillo', 'Celeste'],
    'globos': <String>['Rojo', 'Azul', 'Amarillo', 'Verde', 'Celeste'],
    'manzana': <String>['Rojo', 'Verde', 'Marrón', 'Amarillo', 'Celeste'],
    'mariposa': <String>['Morado', 'Amarillo', 'Rosado', 'Celeste', 'Negro'],
    'perro': <String>['Marrón', 'Amarillo', 'Rosado', 'Negro', 'Celeste'],
    'corazon': <String>['Rojo', 'Rosado', 'Morado', 'Amarillo', 'Celeste'],
    'helado': <String>['Rosado', 'Marrón', 'Naranja', 'Rojo', 'Celeste'],
    'pollito': <String>['Amarillo', 'Naranja', 'Rojo', 'Verde', 'Celeste'],
    'carro': <String>['Rojo', 'Celeste', 'Negro', 'Gris', 'Amarillo'],
    'arbol': <String>['Verde', 'Marrón', 'Rojo', 'Amarillo', 'Celeste'],
    'conejo': <String>['Gris', 'Rosado', 'Verde', 'Celeste', 'Amarillo'],
    'cupcake': <String>['Rosado', 'Marrón', 'Rojo', 'Celeste', 'Amarillo'],
    'nube_lluvia': <String>['Gris', 'Azul', 'Celeste', 'Amarillo', 'Morado'],
    'tortuga': <String>['Verde', 'Marrón', 'Amarillo', 'Celeste', 'Naranja'],
    'barco': <String>['Rojo', 'Azul', 'Amarillo', 'Celeste', 'Marrón'],
    'fresa': <String>['Rojo', 'Verde', 'Rosado', 'Amarillo', 'Celeste'],
    'oso': <String>['Marrón', 'Naranja', 'Rosado', 'Amarillo', 'Celeste'],
    'luna': <String>['Azul', 'Amarillo', 'Morado', 'Naranja', 'Celeste'],
    'pato': <String>['Amarillo', 'Naranja', 'Celeste', 'Azul', 'Verde'],
    'regalo': <String>['Rojo', 'Verde', 'Amarillo', 'Morado', 'Celeste'],
    'cerdito': <String>['Rosado', 'Rojo', 'Celeste', 'Verde', 'Amarillo'],
    'cohete': <String>['Rojo', 'Gris', 'Azul', 'Amarillo', 'Naranja'],
    'hongo': <String>['Rojo', 'Amarillo', 'Verde', 'Marrón', 'Celeste'],
    'rana': <String>['Verde', 'Amarillo', 'Celeste', 'Rosado', 'Azul'],
    'arcoiris': <String>['Rojo', 'Naranja', 'Amarillo', 'Verde', 'Celeste'],
    'abeja': <String>['Amarillo', 'Negro', 'Celeste', 'Naranja', 'Verde'],
    'paraguas': <String>['Rojo', 'Amarillo', 'Azul', 'Celeste', 'Morado'],
    'pinguino': <String>['Negro', 'Naranja', 'Celeste', 'Azul', 'Gris'],
    'avion': <String>['Rojo', 'Celeste', 'Azul', 'Gris', 'Amarillo'],
    'ballena': <String>['Azul', 'Celeste', 'Gris', 'Rosado', 'Amarillo'],
  };

  /// Colores de los dibujos que no están en [paletasDibujos] ni traen los
  /// suyos (por ejemplo, los de la carpeta mis_dibujos sin archivo .txt).
  static const List<String> paletaPorDefecto = <String>[
    'Rojo',
    'Amarillo',
    'Verde',
    'Azul',
    'Rosado',
  ];
}
