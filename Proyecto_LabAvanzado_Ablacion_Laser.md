# Proyecto LABORATORIO AVANZADO — Ablación láser con motores OWIS (MATLAB)

Documento de traspaso. Está escrito para alguien que no conoce el proyecto.
Todo lo que aquí se afirma sale de leer los archivos del proyecto; **no se ejecutó nada**
(el sistema depende de hardware: controlador OWIS PS35, tarjetas NI y láser).
Las partes que son interpretación mía o que hay que confirmar en el laboratorio están marcadas con **(verificar)**.

---

## 1. Qué es el proyecto

Un sistema para **dibujar (ablacionar) diseños sobre una muestra con un láser fijo**, moviendo la muestra con una
mesa de dos motores (X, Y) OWIS controlados desde MATLAB.

Flujo general:

1. Se dibuja el diseño en Inkscape (trazo **blanco** sobre fondo **negro**) y se exporta a `.png`
   (ver "Manual para trazar diseños con los motores OWIS").
2. MATLAB lee la imagen, la binariza y detecta la geometría.
3. La geometría se convierte en coordenadas (1 píxel = 1 µm) y se traduce a movimientos de los motores.
4. Una salida digital de la tarjeta NI enciende/apaga el láser mientras la mesa se mueve.

El láser no se mueve: **lo que se mueve es la mesa**. Por eso "dibujar una línea" es mover la mesa con el láser encendido.

---

## 2. Requisitos de software y hardware

**Hardware**
- Controlador de motores OWIS **PS35** (conexión por puerto COM, 230400 baud en la mayoría de las funciones).
  Eje 1 = X, eje 2 = Y (configurable en el panel, no cambiarlo salvo que el movimiento sea el contrario).
- Tarjeta NI que habilita el láser: dispositivo `Dev2`, línea `Port1/Line3` (digital) — ver `DAQstate.m`.
- Tarjeta NI para tren de pulsos: dispositivo `Dev3`, salida analógica `ao0` — ver `repRate.m`.
  Los nombres de dispositivo están escritos a mano; si cambia la computadora o la tarjeta hay que editarlos.

**Software (MATLAB)**: Add-Ons indicados en `Reedme.txt`: MinGW-w64 C/C++ Compiler, Arduino Hardware Support,
NI DAQ Toolbox, "Using Counter of NI DAQ card to generate a pulse train" y Data Acquisition Toolbox.
También se usan funciones del Image Processing Toolbox (`imbinarize`, `regionprops`, `bwboundaries`).

**Librería OWIS**: `ps35.dll` + `ps35.h` deben estar en la misma carpeta que `PanelOwis.m`
(se carga con `loadlibrary('ps35')`).

---

## 3. Mapa de archivos

### 3.1 Sistema original (polígonos / líneas rectas)

| Archivo | Para qué sirve |
|---|---|
| `PanelOwis.fig` / `PanelOwis.m` | Interfaz gráfica (GUIDE). Conecta, mueve, carga imagen, lanza la ablación. **El `.fig` no está en los archivos revisados.** |
| `VertexDetection.m` | Binariza la imagen, separa figuras con `regionprops` y busca 4 esquinas por figura con `pgonCorners`. |
| `pgonCorners.m` | Detecta las esquinas de un polígono **convexo** con número de vértices conocido (aquí k = 4). |
| `generalMov.m` | Recorre cada figura: se posiciona en su esquina mínima (láser apagado) y la rellena con zigzag usando `ps35New`. Usa solo el *rectángulo envolvente* de cada figura. |
| `ps35New.m` | Secuencia básica de zigzag (movimiento largo en un eje, paso corto `tr` en el otro, láser encendido). |
| `ps35tool.m`, `ps35toolX.m`, `ps35toolY.m` | Un solo movimiento relativo de un eje (con/sin láser). |
| `ps35toolX2.m`, `ps35toolY2.m` | Igual pero en modo **absoluto** (se usan en "Go Home"). |
| `DAQstate.m` | Enciende/apaga el láser (salida digital). |
| `repRate.m`, `twotr.m`, `unipolar.m`, `twotrun.m`, `unipolarrun.m` | Botón "Dots": repetición de pulsos a una frecuencia dada, generando la señal con la tarjeta NI. |
| `ps35.h` | Cabecera con todas las funciones de la librería OWIS. |
| `Reedme.txt` / `.docx` | Instrucciones de instalación y de uso del panel. |
| `Manual para trazar diseños con los motores OWIS.docx` | Cómo preparar la imagen en Inkscape. |

### 3.2 Versiones viejas / experimentos (no son parte del flujo actual)

| Archivo | Nota |
|---|---|
| `generalMov-copia.m`, `generalMovNoSerpiente.m` | Versiones anteriores de `generalMov`. La de "NoSerpiente" tiene los 3 algoritmos (`n=1,2,3`) que en la actual están comentados. |
| `ps35New29Jun2024.m` | Versión anterior de `ps35New` (hace `loadlibrary`/`unloadlibrary` por su cuenta). |
| `flagBasedStopExample.m`, `testGUI.m` | Pruebas para implementar pausa/stop. No funcionan como están (ver §7). |
| `initPulseStreamerEnv.m` | Configura Python/PulseStreamer. Tiene una ruta de Miniconda de un usuario fijo. No está conectado al panel. |

### 3.3 Scripts de tabla de vectores (`LabAdv_Motors_25_10_29 … 25_11_27_TableScript.m`) y pruebas de Antonio

- `ps35tool_Antonio.m`, `ps35tool_Circ_Antonio.m`: pruebas de movimiento simultáneo de dos motores y de
  `PS35_CircleToVectorTab` (primer contacto con la interpolación circular del PS35).
- Los `*_TableScript.m` son **scripts (no funciones)** que construyen y escriben en el controlador una *tabla de vectores*
  formada por semicírculos y tramos rectos ("circuit" y "funnel", ramas superior e inferior). Evolución, de más viejo a más nuevo:
  - `25_10_29` → `25_11_04`: versión base con semicírculos (IV/II, arriba/abajo) y pasos laterales.
  - `25_11_05`, `25_11_06`: se añade el "funnel" (embudo) y `plate_Length`.
  - `25_11_07_New`: dos ramas con radios R1/R2 separados por `circuit_Spacing_Int`. Tiene un error (se asigna el ángulo a `II_Up` en lugar de `II_Dw`).
  - `25_11_08` y `25_11_12`: corrige ese error; el paso lateral del funnel pasa a depender del ángulo.
  - `25_11_27`: colas izquierda/derecha de distinta longitud (`circuit_tailLength_LC/RC`); `s_Length` queda como entrada externa.
- **Dependen de variables que no están definidas en ningún archivo** (`axis_X`, `axis_Y`, `motorSpeed`, `mm2incrementsFactor`,
  `seconds`, `scale_Factor`, `plate_Length`, `table_Key`, etc.). Se supone que las define otra aplicación o live script
  que no se incluyó **(verificar)**.
- Su valor para este proyecto: documentan **cómo codificar un círculo para el PS35** (formato de renglón, límite de ~1.638 s por secante).

### 3.4 Trabajo nuevo para círculos (carpeta `claude/`)

| Archivo | Para qué sirve |
|---|---|
| `circlesMov.m` | Equivalente de `generalMov` pero para círculos y anillos. |
| `anilloMov.m` | Traza un círculo o un anillo relleno (círculos concéntricos separados por el paso del láser). Es la versión en función de `circulo_while` (live script, actualización 2026_05_28). |
| `RingDetection` | Detección de círculos y anillos. **No está entre los archivos revisados**, pero `circlesMov` espera su salida (ver §6). |

---

## 4. Cómo se opera el sistema original (resumen de `Reedme.txt`)

Cada cuadro de texto del panel debe confirmarse con **ENTER** para que el valor se guarde.

1. Puerto COM. 2. Ejes (dejar por defecto). 3. `Case n` (n=1: movimientos largos en X; n=2: largos en Y).
4. *Charge Image*: solo visualiza. 5. *Vertex Detection*: elige la imagen y muestra los vértices.
6. *Step-size*: traslape de ablación (µm). 7. *Change Vel*: velocidad de cada eje. 8. *Go Ablation*.
9. *Pause*, 10. *Stop*, 11. *Move* / barra de movimiento fino, *Set Home*, *Go Home*, *Disconnect*.
14. *Dots*: repetición de pulsos (líneas, puntos en X/Y, frecuencia, número de DUT).

---

## 5. Estado en el que se recibió

- El sistema funcionaba **solo para figuras que se pueden rellenar como rectángulo**: `VertexDetection` busca 4 esquinas por figura y
  `generalMov` usa únicamente `min/max` en X y Y de esas esquinas. Cualquier otra forma se trataba como su rectángulo envolvente.
- El láser solo se desplazaba en líneas rectas (zigzag).
- Existían, aparte, los scripts de tabla de vectores con semicírculos (§3.3), no conectados al panel ni a la detección de imagen.
- Objetivo planteado: **que el sistema funcione para círculos**. El plan fue:
  1. quitar `VertexDetection` y sustituirla por una función que detecte **centros y radios**;
  2. unirla con la función que ya traza círculos con secantes;
  3. poder trazar círculos sencillos **y anillos** (círculos concéntricos), detectando todos los de la imagen.

---

## 6. Qué se hizo para llegar al estado actual

1. **Detección de círculos y anillos** (`RingDetection`): se partió de una `CircleDetection` original y se hizo una versión nueva,
   separada de ella, que además agrupa círculos concéntricos. Reportado como funcionando.
   Entrega, según lo que consume `circlesMov`:
   - `res`: celda con un renglón `[cy cx r]` por cada borde detectado (centro fila/columna y radio, en píxeles);
   - `grupos`: celda donde cada elemento lista los índices de `res` que son concéntricos.
2. **Decisión de integración**: conectar primero con `circulo_while` (movimiento de los motores para hacer un círculo)
   y dejar para después la integración con el resto.
3. **`anilloMov.m`** (función a partir de `circulo_while`):
   - traza con la interpolación circular del PS35 (`PS35_CircleToVectorTab`, `secantNum = 100` secantes por vuelta por defecto);
   - si `R_int == R_ext` traza un círculo; si no, traza círculos concéntricos separados por el paso del láser
     (por defecto 0.7 µm) con un paso radial entre ellos;
   - escribe la tabla **una sola vez** y luego la ejecuta (`PS35_GoVectorTab`), en lotes de ≤2000 renglones;
   - modos `modoPaso = 'tabla'` (todo seguido) o `'separado'` (pieza por pieza);
   - se quitaron `clear`, `close all`, `loadlibrary`, `Connect`, `Disconnect` y `unloadlibrary`, que cerraban el panel o la conexión;
   - revisa el código de retorno de cada llamada al PS35 y avisa si falla.
4. **`circlesMov.m`** (equivalente de `generalMov`):
   - decide qué trazar con los grupos: revisa en la imagen binaria si entre dos radios consecutivos hay blanco
     (→ anillo relleno) o negro (→ dos líneas separadas, cada una un círculo sencillo);
   - mueve la mesa con el láser apagado al punto de arranque `(cx, cy + R_int)` y llama a `anilloMov`;
   - al terminar regresa al punto de inicio;
   - imprime el plan de trazos y los tiempos antes/después de mover;
   - puede conectarse por sí mismo al PS35 si recibe `p.COMp`.
5. **Convención de archivos**: las versiones modificadas (`PanelOwis`, `RingDetection`) deben llevar un nombre distinto
   al de los originales y guardarse en una carpeta aparte, para no confundirlas **(confirmar con el profesor responsable)**.

### Cambio importante de coordenadas respecto a `generalMov`

| | `generalMov` (original) | `circlesMov` (nuevo) |
|---|---|---|
| Origen | esquina de la imagen (píxel 0,0) | **centro de la imagen** |
| Escala | 1 px = 1 µm | 1 px = `p.pix2mm` (por defecto 1/1000 mm = 1 µm) |
| Ejes | X = columna, Y = fila | igual |

Consecuencia práctica: **al presionar "Run", el láser debe estar situado donde corresponde al centro de la imagen.**

---

## 7. Problemas actuales

Ordenados de mayor a menor importancia práctica.

### 7.1 Integración incompleta
- El `PanelOwis.m` revisado **sigue siendo el original**: `pushbutton7` llama a `VertexDetection` + `generalMov`.
  No hay ningún botón o ruta que llame a `RingDetection` + `circlesMov`. Si existe una copia modificada del panel, no estaba entre los archivos revisados **(verificar)**.
- `circlesMov(res, grupos, BW, p)` necesita una estructura `p` que nadie construye todavía. Campos esperados:
  `COMp`, `axis_X`, `axis_Y`, `pix2mm`, `vx`, `vy`, y los de `anilloMov` (`motorSpeed`, `laserStepWidth`, `secantNum`, `laserOn`, …).
- **Los parámetros del panel no llegan a la parte nueva**: el *Step-size* (µm) y la velocidad del panel no están conectados
  a `laserStepWidth` ni a `motorSpeed`; se usan los valores por defecto (0.7 µm y 0.2 mm/s).
- Faltan en los archivos revisados: `RingDetection.m`, `circulo_while` (live script) y `PanelOwis.fig`.

### 7.2 Unidades y velocidades mezcladas
- Los movimientos rectos (`ps35toolX/Y`, `moverRel`) fijan la velocidad con `PS35_SetPosF` en **Hz (pasos/s)**; el panel multiplica por 10 lo que se escribe.
- `anilloMov` fija la velocidad con `PS35_SetPosFEx` en **mm/s** y calcula tiempos de secante con `motorSpeed` en mm/ms.
- Conviene definir una sola unidad y comprobar con un cronómetro que la velocidad real coincide con la esperada.

### 7.3 Parámetros sin validar en hardware
- `tPasoMin = 20 ms`: el tiempo calculado del paso radial salía ≈4 ms, y se puso un mínimo "por si el PS35 no acepta segmentos tan cortos".
  Es una suposición, no una medición.
- `secantNum = 100` y `t_max = 1600 ms` (límite del PS35: 1638 ms por secante): comprobar que el círculo resultante es suficientemente redondo para los radios usados.
- Tamaño de tabla: el código asume 2000 renglones máximo por lote.
- La tabla se escribe renglón por renglón con `calllib`, lo cual es lento; ya hay mensajes de tiempo para medirlo, pero no hay una conclusión.

### 7.4 Modo relativo y error acumulado
- Todo se hace en modo relativo: el controlador **no conoce el centro** del círculo, solo arranca donde está la mesa.
  Cualquier error en el posicionamiento previo o en un movimiento se arrastra a los trazos siguientes y al regreso a casa.
- El regreso al punto de inicio es por suma de movimientos relativos; no hay verificación contra la posición real
  (`PS35_GetPositionEx`).

### 7.5 Decisión anillo vs. líneas separadas es heurística
- `entreEsBlanco` muestrea 72 puntos de la imagen binaria a mitad de radio entre dos bordes y compara con 0.5.
  Con líneas muy delgadas, imágenes ruidosas o con antialiasing puede decidir mal.

### 7.6 Láser
- `DAQstate(true)` escribe **0** en la línea digital y `DAQstate(false)` escribe **1**; los comentarios llaman "encender láser" a `true`.
  Eso sugiere lógica activa en bajo **(verificar con el montaje real antes de usar potencia)**.
- El panel llama `DAQstate('false')` con un **texto**; funciona por casualidad (la comparación `'false' == true` da falso).
- Cada llamada a `DAQstate` crea un nuevo objeto `daq('ni')` y vuelve a añadir la salida; en bucles largos puede ser lento o dejar recursos abiertos.
- En `anilloMov` el láser queda **encendido durante todo el lote**, incluido el paso radial entre círculos. Es probablemente lo deseado, pero debe confirmarse.
- Existe `p.laserOn = false` para hacer pruebas **sin láser**; usarlo siempre en la primera prueba de cada diseño.

### 7.7 Problemas heredados del sistema original
- `VertexDetection`: ordena `corners` por altura pero devuelve `cornersRounded` sin ordenar (el ordenamiento no tiene efecto); asume figuras convexas de 4 vértices; cada región pequeña de ruido cuenta como figura.
- `generalMov` solo rellena rectángulos envolventes; en la versión actual el `switch (n)` está comentado y la condición de retorno es `if n == 1`, mientras que en `generalMov-copia` es `if n == 2`. No queda claro qué hace cada caso **(verificar)**.
- `PanelOwis`:
  - los cuadros de texto se inicializan con `str2double(get(h,'Value'))` (un edit no tiene `Value` numérico útil) → pueden quedar en `NaN` hasta que se presione ENTER;
  - **Pause** solo cambia el texto y el LED; no pausa nada. **Stop** apaga los motores pero no interrumpe un ciclo en marcha;
  - `pushbutton9` grafica en los ejes actuales y no necesariamente en `axes1`;
  - *Go Home* usa modo absoluto con `xhome/10000` (supone unidades de 1/10000 mm).
- `flagBasedStopExample.m` y `testGUI.m` (intentos de pausa/stop) no funcionan tal cual: el primero modifica una variable "no local" que no es válida; el segundo rompe el ciclo con `break` en vez de reanudar.
- Varias funciones `ps35tool*` usan `else if ... end` anidado sin su `end` correspondiente; funciona por cómo cierra el archivo, pero es frágil.
- `ps35toolX/Y` se reconectan al controlador en **cada** movimiento.
- Rutas y nombres fijos: `Dev2`, `Dev3`, ruta de Miniconda, puerto COM por defecto.

---

## 8. Qué puede hacer el proyecto hoy

| Capacidad | Estado |
|---|---|
| Mover X/Y a mano desde el panel (valor escrito y barra fina), fijar casa y volver | Operativo (original) |
| Cargar una imagen blanco/negro y mostrar vértices detectados | Operativo (original) |
| Rellenar con zigzag el rectángulo envolvente de figuras de 4 vértices (`n=1` / `n=2`, paso y velocidad configurables) | Operativo (original) |
| Repetición de pulsos del láser en puntos/líneas ("Dots") | Operativo, de uso experimental |
| Detectar círculos y anillos concéntricos en una imagen | Reportado como funcionando (`RingDetection`, no revisada aquí) |
| Trazar un círculo, un anillo relleno o varios, con interpolación circular del PS35 | Escrito (`circlesMov` + `anilloMov`); **sin evidencia de prueba completa en hardware en lo revisado** |
| Construir tablas de vectores de semicírculos y tramos rectos ("circuit"/"funnel") | Scripts existentes; dependen de un entorno externo de variables |
| Ablación de formas arbitrarias (curvas libres, polígonos no rectangulares) | No soportado |

---

## 9. Siguientes pasos sugeridos

1. **Recuperar o confirmar los archivos faltantes**: `RingDetection.m`, la copia modificada de `PanelOwis` (`.m` y `.fig`), `circulo_while`, `ps35.dll`.
2. **Probar sin láser**: `p.laserOn = false`, un círculo pequeño, con cronómetro, y comparar tiempo esperado vs. real (`anilloMov` ya imprime ambos).
3. **Verificar la polaridad del láser** con `DAQstate` en un banco seguro (sin muestra / potencia mínima).
4. **Unificar unidades de velocidad** y conectar al panel el *Step-size* y la velocidad.
5. **Añadir un botón** (o modo) en el panel nuevo (con otro nombre que el original) que llame a `RingDetection` → `circlesMov`, armando `p` desde los valores del panel.
6. **Validar el punto de arranque**: comprobar con una muestra de prueba que "centro de imagen = posición del láser" y que el regreso a casa no deriva.
7. **Medir el rendimiento de la escritura de tabla** y decidir `secantNum`, lotes y `modoPaso`.
8. **Implementar pausa/stop reales** (bandera revisada dentro de los bucles de movimiento y `PS35_StopVectorTab` para la tabla).
9. Limpiar el repositorio: separar versiones viejas y experimentos, y documentar en un solo lugar las variables que esperan los `TableScript`.

---

## 10. Anexo: referencias rápidas

**Renglón de tabla para un arco** (`PS35_CircleToVectorTab`, 10 valores separados por comas):

`eje X, eje Y, tiempo por secante (ms), código de función (0), nº de secantes, radio (incrementos), ángulo inicial (°), ángulo de arco (°), Z, N`

- 1 mm = 10 000 incrementos (`mm2incrementsFactor`).
- Máximo por secante: 1.638 s (límite documentado del PS35).
- Longitud de secante: `L = 2·R·sin(ángulo / (2·n))`.
- `anilloMov` usa `angleStart = 90°`, por eso el círculo arranca en `(cx, cy + R)`.

**Convención de ejes**: eje X del motor = columna de la imagen; eje Y = fila. 1 px = 1 µm por defecto.
