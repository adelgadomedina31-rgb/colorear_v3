# ARVI — app para colorear, sin anuncios

App Android hecha con Flutter para que una niña de 3 años pinte dibujos simples en blanco y negro.
No tiene anuncios, no usa internet y no pide cuentas. En el celular se llama **ARVI** y el menú de
dibujos dice **COLOREA ARLETH**.

## Cómo funciona

- **Presentación:** al abrir la app caen estrellas de colores, aparecen saltando las letras de **PINTEMOS ARLETH**. Es sin sonido, dura unos 3,5 segundos y tocar la pantalla la salta.
- **Pintar con toques:** se elige un color abajo y se toca el dibujo. Cada toque suena como una gota de pintura que cae y salpica (hay 5 gotas distintas, cada una termina en una nota musical, así tocar seguido suena como una melodía) y deja una mancha de pintura que se derrama desde el dedo, con gotitas salpicadas. Las zonas grandes (el cielo, la cabeza del gato) necesitan varios toques; las pequeñas (una ventana, una oreja) se llenan de un solo toque. Si arrastra el dedo, la pintura lo sigue con un sonido de pincel sobre el papel (4 distintos, con un brillito suave).
- El color queda siempre **dentro de la zona** donde empezó el dedo; aunque se salga de las líneas, no se sale la pintura.
- **Paleta de cada dibujo:** cada dibujo trae sus propios colores, como mucho 5, elegidos para que tengan sentido (el sol: amarillo, naranja, celeste, rojo y rosado; el pingüino: negro, naranja, celeste, azul y gris...). Cada color es un tarrito redondo de pintura y **los colores no se acaban**. El elegido crece, rebota y muestra una estrellita.
- **Ella elige el color:** al entrar a un dibujo no hay ningún color elegido: la voz dice **"¡Elige un color!"** y los tarritos saltan uno tras otro hasta que ella elige uno. Si toca el dibujo sin color, no se pinta y la voz se lo vuelve a pedir. Cuando hay que cambiar de color, el color se suelta y **nunca se elige otro solo**: siempre lo elige ella.
- **Dos modos de pintar** (se cambian en el engranaje del menú, ver "Ajustes"):
  - **Modo 1 – Pintado total** (el que viene puesto): pinta libre con los colores del dibujo. Cuando un mismo color ya cubre **la mitad del dibujo**, la voz dice **"¡Usa otro color, para que se vea más bonito!"** y ese color se suelta para que elija otro (si quiere, puede volver a elegir el mismo y seguir). Lo recomienda una sola vez por color en cada dibujo.
  - **Modo 2 – Pintado por objeto:** cada dibujo tiene un **personaje** (el pez, el sol con sus rayos, la casa, las alas de la mariposa...) que se pinta **entero de un solo color**: el primer color con el que toca el personaje queda como su color. Con otro color, el personaje no se pinta (la voz dice "¡Pinta el pez con el naranja!"), y con su color no se pinta el resto ("¡Este color es para el pez!"). Un color que ya usó en el fondo no puede ser el del personaje ("¡Elige otro color para el pez!"). Cuando termina el personaje, la voz dice **"¡Elige otro color para seguir pintando!"** y el color se suelta. El fondo y los detalles (la puerta, las burbujas, las manchas...) se pintan con los otros colores, uno o varios. Así cada dibujo queda con al menos 2 colores. Con su color puede seguir retocando el personaje.
- **Celebración al terminar:** cuando el dibujo queda pintado al menos en un **95%** (con cualquier color, no hace falta usar todos, en los dos modos), sale un cartel grande **"¡FELICIDADES! LO PINTASTE MUY BIEN"** con estrellas que giran y brillan alrededor y estrellitas que salen volando, suena una fiesta (campanitas y aplausos) y la voz dice "¡Felicidades! ¡Lo pintaste muy bien!". Se quita sola a los 7 segundos o tocándola. Sale una sola vez por dibujo; si se borra y se vuelve a pintar, sale otra vez.
- **Cada dibujo recuerda lo suyo:** el color de su personaje (Modo 2), los colores a los que ya se les recomendó cambiar (Modo 1) y si ya salió la celebración, aunque se cierre la app. Un dibujo pintado en un modo se puede seguir pintando en el otro.
- **Voz de los colores:** al elegir un color, una voz dice su nombre ("¡Rojo!"). Mientras habla, los demás colores se ven más claros y no responden, así la palabra se escucha completa. La voz usa un tono casi normal (antes era muy aguda y sonaba a robot) y la app elige la voz en español de mejor calidad que tenga el celular.
- **Voces grabadas (opcional, las más naturales):** si grabas tu voz diciendo los colores y las frases, y pones los archivos en `assets/voces/`, la app usa esas grabaciones en vez de la voz del celular. Lo que no esté grabado lo sigue diciendo la voz del celular. Ver `assets/voces/LEEME.txt`.
- **Se guarda solo:** lo pintado queda guardado en el celular (una imagen por dibujo), aunque se cierre la app o se apague el teléfono.
- **Siempre fluida:** cada mancha, al terminar de derramarse, se "hornea" dentro de la imagen del dibujo. Por eso pintar cuesta lo mismo al principio que después de horas de uso.
- Botones grandes arriba: **inicio**, **anterior**, **siguiente** y **borrar** (el rojo). Borrar no pregunta: deja el dibujo en blanco y como nuevo (el color elegido se queda).
- **Menú:** arriba hay dos botones: el naranja (escoba) **borra lo pintado de todos los dibujos** (pregunta antes), y el rojo (apagado) **cierra la app** al instante y vuelve a la pantalla del celular.
- El menú principal muestra los dibujos con lo que ya se pintó, de dos en dos. Se desliza hacia arriba y abajo con el dedo (la barra de la derecha muestra en qué parte de la lista va). Se toca un dibujo y se abre.
- Viene con **34 dibujos** (animales, frutas, vehículos, cosas del cielo y del jardín...) y **los que tú agregues en la carpeta `mis_dibujos`** (ver "Agregar dibujos nuevos").
- **Ícono propio:** un arcoíris pintado con un pincel (carpeta `icono/`, se crea con `tools/generar_icono.py`).
- **Ajustes:** tocar el engranaje gris (arriba a la derecha del menú). Ahí se elige el **modo de pintar** (vale para todos los dibujos y queda guardado) y se agregan o borran dibujos pegando su texto.

### Si la voz no suena

La voz es la del propio celular ("texto a voz"), así que no necesita internet. Si no se escucha:
1. Sube el volumen multimedia.
2. En el celular: **Ajustes → Accesibilidad (o Sistema) → Salida de texto a voz**. Elige el motor de Google y en su configuración descarga la voz **Español (Estados Unidos)** o **Español (España)**.
3. Cierra y vuelve a abrir ARVI.

### Para que la voz suene más natural

- En **Salida de texto a voz → Motor de Google → Instalar datos de voz → Español**, cada idioma trae varias voces (Voz I, Voz II...). Escúchalas con el botón de prueba y elige la que más te guste: ARVI usa la voz que tenga el celular.
- Actualiza la app **"Servicios de voz de Google"** desde la Play Store: las versiones nuevas traen voces más naturales.
- Las voces "de internet" suenan todavía mejor, pero sin internet se callan. Si el celular siempre tiene internet, pon `vozPermitirInternet = true` en `lib/config.dart`.
- Lo más natural de todo: **grabar tu voz** (ver `assets/voces/LEEME.txt`).

### Afinar cómo se siente

Todo está en `lib/config.dart`:

| Quiero… | Cambia |
|---|---|
| Que se necesiten más (o menos) toques | `toquesZonaChica` y `toquesZonaGrande` |
| Que más zonas se llenen de un toque | sube `areaUnToque` |
| Manchas más grandes o más chicas | `escalaMancha` (1.2 = 20% más grandes) |
| Derrame más lento o más rápido | `duracionDerrame` |
| Quitar o bajar el sonido al pintar | `sonidoPintar`, `volumenPintar` (gota), `volumenTrazo` (pincel) |
| Que el pincel suene más o menos seguido | `distanciaEntreTrazos` |
| Cuánto hay que pintar para la celebración | `porcentajeCelebracion` (0.95 = el 95%) |
| Lo que dice el cartel y la voz al terminar | `celebracionLinea1`, `celebracionLinea2`, `vozCelebracion` |
| Cuánto dura la celebración | `segundosCelebracion` |
| Quitar o bajar la fiesta al terminar | `sonidoCelebracion`, `volumenCelebracion` |
| Quitar o cambiar la presentación | `mostrarPresentacion`, `presentacionLinea1/2` |
| Voz más aguda o más grave | `vozTono` (1.0 normal, hasta 2.0; muy alta suena a robot) |
| Usar las voces "de internet" del celular | `vozPermitirInternet` |
| Usar (o no) tus voces grabadas | `usarVocesGrabadas` |
| Voz más lenta o más rápida | `vozVelocidad` |
| El modo que viene puesto (si nunca se eligió otro) | `modoPorDefecto` (1 o 2) |
| Cuándo se recomienda otro color en el Modo 1 | `parteParaRecomendar` (0.50 = la mitad del dibujo) |
| Que en el Modo 1 el color NO se suelte al recomendar otro | `soltarColorAlRecomendar = false` |
| Cuándo el personaje está terminado en el Modo 2 | `personajeTerminado` (0.97 = el 97% del personaje) |
| El personaje de cada dibujo (Modo 2) | `personajes` (sus partes son los `id` de las zonas) |
| Lo que dice la voz | `vozEligeUnColor`, `vozUsaOtroColor`, `vozEligeOtroParaSeguir`, `vozColorDelPersonaje`, `vozPintaPersonajeCon`, `vozOtroColorParaPersonaje` |
| Los colores de cada dibujo | `paletasDibujos` |
| Los colores de los dibujos que no están en la lista | `paletaPorDefecto` |
| Apagar la voz | `vozActiva = false` |
| Agregar colores o cambiar sus nombres | la lista `colores` |

## Cómo sacar el APK

### Camino A — con GitHub (no instalas nada)

1. Crea una cuenta en github.com y un repositorio nuevo, privado (por ejemplo `colorear`).
2. Abre esta carpeta en VS Code, abre la Terminal y ejecuta (cambia `TU_USUARIO`):

   ```
   git init
   git add .
   git commit -m "Primera versión"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/colorear.git
   git push -u origin main
   ```

3. En GitHub entra a la pestaña **Actions**. El trabajo "Compilar APK" arranca solo y demora unos 5-10 minutos.
4. Cuando termine con el check verde, ábrelo y abajo, en **Artifacts**, descarga `colorear-apk`. Es un zip que contiene `app-release.apk`.
5. Pasa el APK al celular (cable, Drive, WhatsApp, correo) y ábrelo. Android te pedirá permitir instalar apps de fuentes desconocidas para la app desde la que lo abras.

Cada vez que cambies algo y hagas `git push`, se genera un APK nuevo. También puedes lanzarlo a mano desde Actions → Compilar APK → Run workflow.

**Instalar una versión nueva encima de la anterior:** la carpeta `signing/` contiene una firma fija
(`debug.keystore`). Gracias a ella, todos los APK que se compilen desde ahora tienen la misma firma y
se instalan **encima** del anterior, sin desinstalar. Mantén esa carpeta en el repositorio.
(Los APK compilados *antes* de existir esa carpeta tenían una firma al azar: la primera vez hay que
desinstalar la app vieja y luego instalar la nueva.)

### Camino B — en tu computadora

1. Instala Flutter (docs.flutter.dev/get-started/install), Android Studio (trae el SDK de Android) y la extensión *Flutter* de VS Code. Verifica con `flutter doctor`.
2. En esta carpeta, **solo la primera vez**, crea la parte Android (no toca tu código):

   ```
   flutter create --platforms=android --project-name colorear_ninos --org com.arvi .
   ```

3. Descarga las librerías y prueba en el celular (conectado por USB con depuración activada):

   ```
   flutter pub get
   flutter run
   ```

4. Para el APK: `flutter build apk --release`. Queda en `build/app/outputs/flutter-apk/app-release.apk`.
5. Para que el nombre bajo el ícono sea "ARVI" y funcione la voz, corre una vez `python3 tools/preparar_android.py`
   (en GitHub Actions esto se hace solo).

## Consejo para que ella no se salga de la app

En Android puedes **fijar la pantalla** (en Ajustes busca "Fijar app" o "Fijar pantalla", según el celular). Con la app fijada no se puede salir sin el gesto o el código de desbloqueo.

## Agregar dibujos nuevos

### Forma 0 — la más fácil: tus propias imágenes (carpeta `mis_dibujos`)

1. Copia imágenes de **líneas negras sobre fondo blanco** (láminas para colorear, PNG o JPG) en la carpeta `mis_dibujos/`.
2. `git add .`, `git commit -m "Nuevos dibujos"`, `git push`.
3. Al compilar, GitHub convierte cada imagen en un dibujo para pintar con toques (cada zona blanca cerrada por líneas se vuelve una zona) y lo pone **al principio del menú**. El nombre del archivo es el nombre del dibujo.

**Sus colores:** junto a la imagen pon un archivo de texto con el mismo nombre (por ejemplo `gato feliz.txt` al lado de `gato feliz.png`) con hasta 5 colores separados por comas: `Naranja, Rosado, Verde, Celeste, Amarillo`. Los nombres posibles son los de la lista `colores` de `lib/config.dart` (Rojo, Naranja, Amarillo, Verde, Celeste, Azul, Morado, Rosado, Marrón, Gris y Negro). Sin archivo de texto, el dibujo usa `paletaPorDefecto`.

**En el Modo 2:** el personaje de tus imágenes se busca solo: es lo que no toca los bordes de la imagen, menos los detalles que quedan adentro de una zona más grande (los ojos, las manchas, una ventana), que se pintan con los otros colores. Funciona mejor con un solo personaje por imagen: si hay varias cosas sueltas (un gato y un sol), cuentan como un solo personaje.

Consejos: figuras cerradas (sin huecos en las líneas), líneas gruesas y pocas zonas pequeñas. Las zonas muy chiquitas no se pintan. Para probar en tu computadora antes de subir: `pip install opencv-python-headless numpy` y `python3 tools/convertir_imagenes.py` (crea los archivos `foto_*.json` y `foto_*.png` en `assets/drawings/`; no hace falta subirlos, GitHub los vuelve a crear).

Hay dos formas. Cada dibujo es un archivo de texto (JSON).

### Forma 1 — desde el celular (uno por uno, sin recompilar)

1. Copia el texto del dibujo en el celular.
2. Abre la app y toca el engranaje del menú.
3. Toca **Pegar** y luego **Guardar**. El dibujo aparece al final del menú.

Los dibujos agregados quedan guardados en el celular y se pueden borrar desde la misma pantalla. Si guardas uno con el mismo `id` que otro que ya agregaste, lo reemplaza.

### Forma 2 — dentro de la app, "de fábrica" (muchos de una vez)

1. Copia el archivo `.json` del dibujo a la carpeta `assets/drawings/`.
2. Abre `assets/drawings/indice.json` y agrega el nombre del archivo en la lista, **entre comillas y separado por comas**. El orden de la lista es el orden del menú.
3. Guarda y sube los cambios (`git add .`, `git commit -m "Más dibujos"`, `git push`). GitHub compila un APK nuevo con los dibujos incluidos.

El nombre dentro de `indice.json` debe ser exactamente el del archivo, y cada dibujo debe tener un `id` distinto.

### Formato de un dibujo

```json
{
  "id": "sol",
  "nombre": "Sol",
  "lado": 1000,
  "regiones": [
    {"id": "cielo", "path": "M 10 70 L 990 70 ... Z"},
    {"id": "cara",  "path": "M 690 500 C ... Z"}
  ],
  "detalles": [
    {"path": "M ... Z", "relleno": "#000000"},
    {"path": "M 415 545 C 455 625 545 625 585 545", "grosor": 12}
  ],
  "colores": ["Amarillo", "Naranja", "Celeste", "Rojo", "Rosado"],
  "personaje": {"nombre": "el sol", "partes": ["cara", "rayo1", "rayo2"]}
}
```

- El dibujo es un cuadrado de `lado` x `lado` (1000 por defecto). Las medidas de los trazos van en esas unidades.
- `regiones` son las zonas que se pintan. Se dibujan en orden: las últimas quedan **encima** de las primeras (así se hacen capas, por ejemplo el cielo primero y la casa después). Cada región es un trazo SVG cerrado.
- `detalles` son adornos que no se pintan: `relleno` (color `#RRGGBB`) para puntos como los ojos, `grosor` para líneas como las sonrisas. Es opcional.
- Cada región debe tener un `id` distinto: con él se guarda lo pintado.
- Un dibujo agregado no puede usar el mismo `id` que uno de los que trae la app.
- `colores` es opcional: la paleta del dibujo (hasta 5 nombres de la lista `colores` de `lib/config.dart`). Si el `id` del dibujo está en `paletasDibujos` de `lib/config.dart`, manda lo de `config.dart`.
- `personaje` es opcional (para el Modo 2): cómo lo nombra la voz y los `id` de sus zonas, que se pintan todas de un solo color. También vale solo la lista: `"personaje": ["cara", "rayo1"]`. Si el `id` del dibujo está en `personajes` de `lib/config.dart`, manda lo de `config.dart`; si no hay ninguno, se busca solo (lo que no toca los bordes, menos los detalles de adentro).

## Dónde cambiar cosas

| Quiero cambiar… | Archivo |
|---|---|
| Nombre de la app bajo el ícono | `.github/workflows/compilar-apk.yml` (busca `android:label`) |
| Título del menú ("COLOREA ARLETH") y su cuadrícula | `lib/pantallas/pantalla_inicio.dart` |
| Tamaño de las manchas, voz, contornos, colores | `lib/config.dart` |
| Cómo se pinta con el dedo | `lib/widgets/lienzo.dart` |
| Guardado de lo pintado | `lib/models/pintura.dart` |
| Voz de los colores | `lib/servicios/voz.dart` |
| Voces grabadas (opcional) | `assets/voces/` (ver `LEEME.txt` ahí) |
| Celebración al terminar un dibujo | `lib/widgets/celebracion.dart` |
| Los dos modos de pintar (qué se puede pintar y cuándo habla la voz) | `lib/pantallas/pantalla_pintar.dart` |
| El modo elegido (se guarda en el celular) | `lib/models/modo_pintado.dart` |
| El personaje de cada dibujo (Modo 2) | `personajes` en `lib/config.dart` y `lib/models/personaje_dibujo.dart` |
| Paleta de cada dibujo y lo que recuerda | `lib/models/paleta_dibujo.dart` y `lib/widgets/paleta.dart` |
| Cómo se mide cuánto pinta cada color | `medirColores` en `lib/models/pintura.dart` |
| Convertir imágenes en dibujos | `tools/convertir_imagenes.py` (carpeta `mis_dibujos/`) |
| Ícono de la app | `tools/generar_icono.py` (carpeta `icono/`) |
| Sonidos (gotas, pincel y fiesta) | `lib/servicios/sonidos.dart` y `assets/sonidos/` (se crean con `tools/generar_sonidos.py`, necesita `pip install numpy`) |
| Presentación al abrir | `lib/pantallas/pantalla_presentacion.dart` |
| Pantalla de pintar (botones, posición de la paleta) | `lib/pantallas/pantalla_pintar.dart` |
| Ajustes (modo de pintar y agregar dibujos) | `lib/pantallas/pantalla_padres.dart` |
| Formato y lectura de dibujos | `lib/models/dibujo.dart` |
| De dónde se cargan los dibujos | `lib/data/repositorio.dart` |
| Los 34 dibujos de fábrica | `assets/drawings/*.json` (se generan con `tools/generar_dibujos.py`) |
| Firma del APK | `signing/debug.keystore` |

La carpeta `tools/` tiene scripts de Python opcionales:

- `generar_dibujos.py` crea los 34 dibujos y el `indice.json`. Los dibujos están definidos en `dibujos_base.py`, `dibujos_animales.py` y `dibujos_cosas.py`; las herramientas para armarlos (círculos, óvalos, polígonos, curvas...) están en `formas.py`. Para correrlo: `python3 tools/generar_dibujos.py` (ojo: borra y vuelve a crear todos los `.json` de `assets/drawings/`).
- `vista_previa.py` (necesita `pip install matplotlib`) hace imágenes para revisar los dibujos antes de pasarlos al celular: `python3 tools/vista_previa.py vista.png` crea `vista_1.png`, `vista_2.png`... con 6 dibujos cada una.

## Ideas para mejorar

- Cargar dibujos desde un archivo en vez de pegar texto.
- Categorías en el menú (animales, vehículos, comida...).
