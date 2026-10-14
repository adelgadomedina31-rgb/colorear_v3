#!/usr/bin/env python3
"""Genera los sonidos de la app en assets/sonidos/ (archivos .wav).

  - gota1.wav ... gota5.wav: una gota de pintura que cae y salpica
    (al tocar el dibujo). Cada una termina en una nota distinta de una
    escala alegre, así al tocar seguido suena como una melodía.
  - trazo1.wav ... trazo4.wav: el pincel que pasa sobre el papel
    (al arrastrar el dedo), con un brillito suave.
  - felicidades.wav: la fiesta al terminar un dibujo (campanitas que
    suben, destellos y aplausos).

Todo se sintetiza con matemáticas (no se descarga nada).
Necesita numpy.  Uso:  python3 tools/generar_sonidos.py
"""
import os
import wave

import numpy as np

FS = 44100  # muestras por segundo


def guardar(ruta, senal):
    senal = np.clip(senal, -1.0, 1.0)
    datos = (senal * 32000).astype("<i2")
    with wave.open(ruta, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FS)
        w.writeframes(datos.tobytes())


def tiempo(dur):
    return np.arange(int(FS * dur)) / FS


def filtrar(x, bajo=None, alto=None, orden=2):
    """Filtro pasa-banda suave (hecho con la transformada de Fourier)."""
    n = len(x)
    largo = 1 << int(np.ceil(np.log2(n * 2)))
    espectro = np.fft.rfft(x, largo)
    f = np.fft.rfftfreq(largo, 1 / FS)
    f[0] = 1e-3
    ganancia = np.ones_like(f)
    if alto is not None:
        ganancia /= np.sqrt(1 + (f / alto) ** (2 * orden))
    if bajo is not None:
        ganancia /= np.sqrt(1 + (bajo / f) ** (2 * orden))
    return np.fft.irfft(espectro * ganancia, largo)[:n]


def normalizar(x, pico):
    return x * (pico / max(1e-9, np.max(np.abs(x))))


def suavizar_final(x, ms=15):
    cola = int(FS * ms / 1000)
    x[-cola:] *= np.linspace(1, 0, cola)
    return x


def nota(nombre):
    tabla = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    letra, octava = nombre[0], int(nombre[-1])
    semitonos = tabla[letra] + (octava - 4) * 12
    return 440.0 * 2 ** (semitonos / 12.0)


def poner(pista, inicio, senal):
    i = int(inicio * FS)
    fin = min(len(pista), i + len(senal))
    if fin > i:
        pista[i:fin] += senal[: fin - i]


def burbuja(frec, dur=0.16, subida=1.5, decaimiento=0.045):
    """Burbuja de líquido: un tono que sube rapidito y se apaga
    (así suena el aire que queda atrapado cuando cae una gota)."""
    t = tiempo(dur)
    f = frec / subida + (frec - frec / subida) * (1 - np.exp(-t / 0.018))
    fase = 2 * np.pi * np.cumsum(f) / FS
    env = (1 - np.exp(-t / 0.002)) * np.exp(-t / decaimiento)
    return (np.sin(fase) + 0.18 * np.sin(2 * fase)) * env


def campanita(frec, dur, vol=1.0):
    """Nota tipo campanita / xilófono."""
    t = tiempo(dur)
    env = (1 - np.exp(-t / 0.002)) * np.exp(-t / (0.16 + 60.0 / frec))
    s = (np.sin(2 * np.pi * frec * t)
         + 0.4 * np.sin(2 * np.pi * 2.0 * frec * t) * np.exp(-t / 0.09)
         + 0.2 * np.sin(2 * np.pi * 3.01 * frec * t) * np.exp(-t / 0.05)
         + 0.08 * np.sin(2 * np.pi * 4.2 * frec * t) * np.exp(-t / 0.03))
    return vol * s * env


def gota(frec, semilla):
    """Una gota de pintura que cae: golpecito húmedo + salpicadura +
    burbuja que termina en la nota [frec] + gotitas más chiquitas."""
    azar = np.random.default_rng(semilla)
    dur = 0.32
    pista = np.zeros(int(FS * dur))
    t = tiempo(dur)

    # 1) El golpe: ruido grave y cortito ("plaf").
    golpe = filtrar(azar.standard_normal(len(t)), 120, 1800)
    golpe *= (1 - np.exp(-t / 0.0015)) * np.exp(-t / 0.012)
    pista += normalizar(golpe, 0.55)

    # 2) La salpicadura: ruido más agudo que se apaga enseguida.
    salpica = filtrar(azar.standard_normal(len(t)), 1500, 6000)
    salpica *= (1 - np.exp(-t / 0.003)) * np.exp(-t / 0.028)
    pista += normalizar(salpica, 0.22)

    # 3) La burbuja principal, afinada en una nota.
    poner(pista, 0.006, normalizar(burbuja(frec), 0.85))

    # 4) Gotitas que saltan y caen después.
    for _ in range(azar.integers(2, 4)):
        inicio = azar.uniform(0.05, 0.16)
        f = frec * azar.choice([1.5, 2.0, 2.5, 3.0])
        poner(pista, inicio,
              normalizar(burbuja(f, 0.07, 1.3, 0.016), azar.uniform(0.12, 0.25)))

    # 5) Un poquito de brillo musical (muy suave) en la misma nota.
    poner(pista, 0.012, campanita(frec * 2, 0.3, 0.08))

    return suavizar_final(normalizar(pista, 0.9), 30)


def trazo(frec, semilla, dur=0.34):
    """El pincel sobre el papel: un "shhh" con textura de cerdas,
    y un brillito suave para que suene bonito."""
    azar = np.random.default_rng(semilla)
    t = tiempo(dur)
    # Sube rápido, se mantiene y se va apagando (una pasada de pincel).
    env = np.minimum(1, t / 0.035) * np.exp(-np.maximum(0, t - 0.06) / 0.09)
    # Las cerdas: pequeños tironcitos irregulares.
    granos = filtrar(np.abs(azar.standard_normal(len(t))), None, 60)
    granos = 0.6 + 0.4 * normalizar(granos - granos.mean(), 1)
    shh = filtrar(azar.standard_normal(len(t)), 900, 5500)
    # Un tono de "silbido" del papel que cambia un poco durante la pasada.
    centro = filtrar(azar.standard_normal(len(t)), 2400, 3400, orden=3)
    pasada = normalizar(shh, 1) + 0.6 * normalizar(centro, 1)
    pasada = normalizar(pasada * env * granos, 0.55)

    pista = np.zeros(len(t))
    pista += pasada
    # Dos notitas brillantes de la escala (como polvo mágico).
    poner(pista, 0.02, campanita(frec * 2, 0.3, 0.13))
    poner(pista, 0.09, campanita(frec * 3, 0.25, 0.07))
    return suavizar_final(normalizar(pista, 0.75), 40)


def aplausos(dur, semilla):
    """Muchas palmaditas cortas al azar, cada vez más y luego menos."""
    azar = np.random.default_rng(semilla)
    pista = np.zeros(int(FS * dur))
    total = int(dur * 28)
    for _ in range(total):
        inicio = azar.beta(1.6, 2.6) * (dur - 0.05)
        largo = 0.03
        tt = tiempo(largo)
        palma = filtrar(azar.standard_normal(len(tt)),
                        azar.uniform(700, 1100), azar.uniform(2200, 3600))
        palma *= (1 - np.exp(-tt / 0.0008)) * np.exp(-tt / 0.006)
        poner(pista, inicio, normalizar(palma, azar.uniform(0.3, 1.0)))
    return pista


def felicidades():
    """Fanfarria de campanitas que suben, un acorde que brilla, destellos
    de estrellitas y aplausos."""
    total = 3.4
    pista = np.zeros(int(FS * total))
    # Arpegio que sube (Do mayor) y termina en un acorde.
    subida = [(0.00, "C5"), (0.11, "E5"), (0.22, "G5"), (0.33, "C6"),
              (0.44, "E6"), (0.55, "G6")]
    for inicio, n in subida:
        poner(pista, inicio, campanita(nota(n), 1.0, 0.45))
    for n in ("C5", "E5", "G5", "C6", "E6"):
        poner(pista, 0.78, campanita(nota(n), 1.8, 0.28))
    for inicio, n in [(0.0, "C3"), (0.78, "C3"), (0.78, "G3")]:
        poner(pista, inicio, campanita(nota(n), 1.4, 0.3))
    # Destellos (estrellitas) que caen.
    azar = np.random.default_rng(11)
    for _ in range(26):
        inicio = azar.uniform(0.7, 2.7)
        poner(pista, inicio, campanita(azar.uniform(2600, 5000), 0.3, 0.07))
    musica = normalizar(pista, 1)
    palmas = np.zeros_like(musica)
    poner(palmas, 0.65, aplausos(2.6, 5))
    final = musica + 0.32 * normalizar(palmas, 1)
    final = normalizar(final, 0.85)
    # Que termine suavecito.
    cola = int(0.6 * FS)
    final[-cola:] *= np.linspace(1, 0, cola) ** 1.5
    return final


def main():
    carpeta = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                            "..", "assets", "sonidos"))
    os.makedirs(carpeta, exist_ok=True)
    # Quita los sonidos de versiones anteriores.
    for viejo in ("plop1.wav", "plop2.wav", "plop3.wav"):
        ruta = os.path.join(carpeta, viejo)
        if os.path.exists(ruta):
            os.remove(ruta)
    # Escala pentatónica de Do (suena bien en cualquier orden).
    escala = ["C5", "D5", "E5", "G5", "A5"]
    for i, n in enumerate(escala):
        guardar(os.path.join(carpeta, f"gota{i + 1}.wav"), gota(nota(n), 100 + i))
    for i, n in enumerate(["C5", "E5", "G5", "A5"]):
        guardar(os.path.join(carpeta, f"trazo{i + 1}.wav"), trazo(nota(n), 200 + i))
    guardar(os.path.join(carpeta, "felicidades.wav"), felicidades())
    for f in sorted(os.listdir(carpeta)):
        print(f, os.path.getsize(os.path.join(carpeta, f)), "bytes")


if __name__ == "__main__":
    main()
