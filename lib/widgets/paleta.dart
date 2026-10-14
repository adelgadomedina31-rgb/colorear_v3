import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config.dart';

/// Los colores del dibujo: tarritos redondos de pintura sobre una bandeja
/// blanca, en una sola fila (cada dibujo tiene como mucho 5 colores). Cada
/// tarrito muestra cuánta pintura le queda.
///
/// - El elegido se agranda, rebota y muestra una estrellita.
/// - Un color que se acabó se encoge y desaparece de la bandeja.
/// - Si se acabaron todos, la bandeja muestra una estrella y "¡Muy bien!".
/// - Mientras la voz habla, la paleta queda [bloqueada].
class Paleta extends StatelessWidget {
  const Paleta({
    super.key,
    required this.colores,
    required this.seleccionado,
    required this.alElegir,
    required this.niveles,
    required this.acabados,
    this.bloqueada = false,
    this.cargando = false,
  });

  /// Los colores del dibujo (como mucho 5).
  final List<ColorConNombre> colores;

  /// El color elegido (null si no queda ninguno).
  final ColorConNombre? seleccionado;

  final ValueChanged<ColorConNombre> alElegir;

  /// Pintura que le queda a cada color (0 a 1), en el mismo orden.
  final List<double> niveles;

  /// Nombres de los colores que ya se acabaron en este dibujo.
  final Set<String> acabados;

  final bool bloqueada;

  /// true mientras se lee la paleta del dibujo: la bandeja se ve vacía.
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFE0A3), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          // Lugar para 5 tarritos en fila, aunque el dibujo tenga menos.
          final cupo = math.max(Ajustes.maxColoresPorDibujo, colores.length);
          final ranura =
              (restricciones.maxWidth / cupo).clamp(44.0, 90.0).toDouble();
          final tamano = (ranura / 1.22).clamp(36.0, 72.0).toDouble();
          final quedan =
              colores.where((c) => !acabados.contains(c.nombre)).length;
          if (!cargando && colores.isNotEmpty && quedan == 0) {
            return SizedBox(
              width: restricciones.maxWidth,
              height: ranura,
              child: const Center(child: _MuyBien()),
            );
          }
          return SizedBox(
            height: ranura,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < colores.length; i++)
                  _Ranura(
                    ancho: ranura,
                    visible: !cargando && !acabados.contains(colores[i].nombre),
                    child: _Tarrito(
                      color: colores[i].color,
                      tamano: tamano,
                      nivel: i < niveles.length ? niveles[i] : 1.0,
                      elegido: colores[i].color == seleccionado?.color,
                      apagado:
                          bloqueada && colores[i].color != seleccionado?.color,
                      alTocar: (bloqueada ||
                              cargando ||
                              acabados.contains(colores[i].nombre))
                          ? null
                          : () => alElegir(colores[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// El lugar de un tarrito en la fila. Cuando el color se acaba, el tarrito
/// se encoge y su lugar se cierra (los demás se juntan).
class _Ranura extends StatelessWidget {
  const _Ranura({
    required this.ancho,
    required this.visible,
    required this.child,
  });

  final double ancho;
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: child,
      builder: (context, t, hijo) {
        if (t <= 0.01) return const SizedBox.shrink();
        return SizedBox(
          width: ancho * t,
          height: ancho,
          child: OverflowBox(
            minWidth: ancho,
            maxWidth: ancho,
            child: Transform.scale(
              scale: t,
              child: Opacity(opacity: t.clamp(0.0, 1.0).toDouble(), child: hijo),
            ),
          ),
        );
      },
    );
  }
}

/// Lo que muestra la bandeja cuando se acabaron todos los colores.
class _MuyBien extends StatelessWidget {
  const _MuyBien();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, escala, hijo) =>
          Transform.scale(scale: escala, child: hijo),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFFDD835), size: 52),
            SizedBox(width: 8),
            Text(
              '¡Muy bien!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFB8C00),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.star_rounded, color: Color(0xFFFDD835), size: 52),
          ],
        ),
      ),
    );
  }
}

class _Tarrito extends StatelessWidget {
  const _Tarrito({
    required this.color,
    required this.tamano,
    required this.nivel,
    required this.elegido,
    required this.apagado,
    required this.alTocar,
  });

  final Color color;
  final double tamano;
  final double nivel;
  final bool elegido;
  final bool apagado;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final double escala = elegido ? 1.12 : 0.92;
    final double opacidad = apagado ? 0.35 : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: alTocar,
      child: SizedBox(
        width: tamano * 1.12,
        height: tamano * 1.12,
        child: Center(
          child: AnimatedOpacity(
            opacity: opacidad,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: escala,
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              child: SizedBox(
                width: tamano,
                height: tamano,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: nivel),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, nivelAnimado, _) => CustomPaint(
                    painter: _PintorTarrito(
                      color: color,
                      nivel: nivelAnimado,
                      elegido: elegido,
                    ),
                    child: Center(
                      child: elegido
                          ? Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: tamano * 0.5,
                              shadows: const <Shadow>[
                                Shadow(color: Color(0x66000000), blurRadius: 4),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja un tarrito redondo: vidrio clarito, la pintura adentro hasta el
/// [nivel] (con la superficie ondulada) y un brillo.
class _PintorTarrito extends CustomPainter {
  _PintorTarrito({
    required this.color,
    required this.nivel,
    required this.elegido,
  });

  final Color color;
  final double nivel;
  final bool elegido;

  Color _tono(double cambio) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + cambio).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;
    final circulo = Rect.fromCircle(center: centro, radius: radio);
    final oscuro = _tono(-0.16);

    // Anillo de color cuando está elegido.
    if (elegido) {
      canvas.drawCircle(centro, radio + 4, Paint()..color = oscuro);
    }
    // Sombra.
    canvas.drawCircle(
      centro.translate(0, 3),
      radio,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Vidrio (tarrito vacío).
    canvas.drawCircle(centro, radio, Paint()..color = _tono(0.38));

    // Pintura adentro, hasta el nivel.
    final n = nivel.clamp(0.0, 1.0).toDouble();
    if (n > 0.001) {
      canvas.save();
      canvas.clipPath(Path()..addOval(circulo));
      final superficie = circulo.bottom - circulo.height * n;
      final ola = radio * 0.08 * (n < 0.98 ? 1.0 : 0.0);
      final liquido = Path()..moveTo(circulo.left, superficie);
      const pasos = 16;
      for (var k = 0; k <= pasos; k++) {
        final x = circulo.left + circulo.width * k / pasos;
        final y = superficie + ola * math.sin(k / pasos * 2 * math.pi * 1.5);
        liquido.lineTo(x, y);
      }
      liquido
        ..lineTo(circulo.right, circulo.bottom)
        ..lineTo(circulo.left, circulo.bottom)
        ..close();
      canvas.drawPath(
        liquido,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 0.95,
            colors: <Color>[_tono(0.18), color, oscuro],
            stops: const <double>[0.0, 0.55, 1.0],
          ).createShader(circulo),
      );
      canvas.restore();
    }

    // Borde.
    canvas.drawCircle(
      centro,
      radio - (elegido ? 2 : 1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = elegido ? 4 : 2
        ..color = elegido ? Colors.white : oscuro,
    );
    // Brillo, para que parezca de vidrio.
    final brillo = Rect.fromLTWH(
      centro.dx - radio * 0.6,
      centro.dy - radio * 0.72,
      radio * 0.6,
      radio * 0.36,
    );
    canvas.drawOval(brillo, Paint()..color = const Color(0x99FFFFFF));
  }

  @override
  bool shouldRepaint(covariant _PintorTarrito oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.nivel != nivel ||
      oldDelegate.elegido != elegido;
}
