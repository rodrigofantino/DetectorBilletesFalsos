# Guía para agregar billetes

Esta guía define el mínimo obligatorio para incorporar un país al catálogo de
billetes. No agregar un país ni una denominación incompleta.

## Cobertura mínima por país

Agregar exactamente **tres billetes vigentes** por país:

1. Identificar las denominaciones de curso legal que el banco central o la
   autoridad emisora mantenga vigentes.
2. Seleccionar las **tres denominaciones más altas** de ese conjunto.
3. Si el país emite menos de tres denominaciones vigentes, agregar todas las
   disponibles y documentar la excepción en el PR o changelog.
4. Para países de la Eurozona, usar billetes de euro y modelarlos como
   `Eurozone`; no crear fichas nacionales duplicadas sin una necesidad de
   contenido específica.

## Requisitos obligatorios para cada billete

Cada uno de los tres billetes debe incluir, sin excepciones:

- Identificador único y país/moneda correctos.
- Denominación y serie vigente.
- Resumen breve, claro y verificable.
- Lista de **medidas de seguridad** relevantes para el usuario.
- URL directa a la página oficial que describe ese billete o su serie.
- Imagen oficial tipo **specimen** del billete completo, preferentemente el
  anverso. La imagen debe mostrar el billete entero, sin recortes y conservar
  su proporción.

## Fuentes permitidas

La fuente primaria debe seguir siendo oficial siempre que exista:

- Banco central del país.
- Autoridad monetaria o emisor oficial.
- Programa oficial de moneda o efectivo.

Las fuentes secundarias globales que aparecen abajo solo se pueden usar como
respaldo cuando no haya una imagen oficial utilizable. Nunca sustituyen la
verificación del emisor sobre vigencia, serie, denominación o medidas de
seguridad.

### Fuentes secundarias globales (fallback)

Estas bases cubren billetes de muchos países y no están dedicadas a un único
emisor:

- [Banknote World / banknote.ws](https://www.banknote.ws/COLLECTION/countries/):
  catálogo mundial con fichas por país, denominación, año y variantes; útil
  para localizar anversos completos y comparar firmas o fechas.
- [Banknotes.com](https://www.banknotes.com/): galería mundial con índices por
  país y denominación; útil como referencia visual y para localizar Pick
  numbers, pero sus imágenes pueden tener restricciones de copyright.
- [Numista](https://en.numista.com/catalogue/index.php): catálogo mundial
  colaborativo con fechas, variantes y referencias cruzadas; usarlo para
  confirmar identidad y no como única prueba de curso legal.
- [Wikimedia Commons — banknotes](https://commons.wikimedia.org/wiki/Category:Banknotes):
  repositorio mundial de imágenes con licencia indicada archivo por archivo;
  comprobar siempre la licencia y conservar la atribución cuando corresponda.
- [Banknote Index](https://banknoteindex.com/): índice mundial por autoridad
  emisora y denominación; sirve para contrastar series y años, aunque la
  página enlazada no garantiza derechos de redistribución de cada imagen.

Reglas para cualquier fallback no oficial:

- Registrar en `source` que la imagen proviene de la fuente secundaria y
  conservar en `source_url` el enlace oficial del emisor cuando exista.
- Confirmar con una fuente oficial que la denominación y la serie siguen
  vigentes; una ficha de coleccionista o una fecha de catálogo no demuestra
  curso legal actual.
- Preferir ejemplares modernos y completos, sin recortes, marcas de agua del
  sitio ni retoques; no usar billetes históricos si el pedido exige muestras
  actuales.
- No descargar imágenes de tiendas, subastas, redes sociales, blogs o
  resultados de búsqueda como fuente primaria. No usar imágenes generadas.
- Revisar la licencia o los términos de reutilización antes de copiar el
  archivo al repositorio; si no está claro, dejar constancia del riesgo y
  buscar otra imagen.

## Esquema y contenido obligatorio

Cada registro debe seguir exactamente el esquema de los registros existentes
en `godot/data/currencyinfo.json`. Antes de escribir, inspeccionar registros
vigentes equivalentes y completar como mínimo:

- Mantener `schema_version: 2`, la colección `CurrencyInfo`, sus claves de
  nivel superior, estructura y tipos compatibles con el catálogo.
- `country`, `currency`, `denomination`, `note_id`, `series`, `image_path` y
  `source`/`source_url` correctos y consistentes.
- `note_id` único y determinista: la normalización de
  `<currency>_<denomination>` debe coincidir exactamente con el validador.
- Resumen, marca de agua y medidas de seguridad legacy, y sus equivalentes
  localizados para todos los locales activos de `AppState.SUPPORTED_LOCALES`.
- Las listas localizadas de medidas deben mantener el mismo conteo y orden que
  la lista de referencia en inglés, si técnicamente se necesita; no dejar
  traducciones, claves ni textos vacíos para ningún locale activo.
- Metadatos de reconocimiento compatibles con el servicio de reconocimiento:
  `recognition.front_reference` debe ser exactamente igual a `image_path` y
  `denomination_tokens` debe incluir la denominación. En release,
  `text_tokens` no puede estar vacío.
- Estado de revisión y pasos de revisión completos. Los campos de imagen o
  región de referencia son opcionales, pero si se incluyen deben ser válidos y
  corresponder al billete y paso indicados.

No inventar claves ni valores: si un campo no está claro, comparar con
registros existentes y con el validador de compatibilidad antes de continuar.

### Requisitos de release para reconocimiento y revisión

- `series` no puede estar vacío en release.
- `review.status` debe ser `ready` y debe haber al menos dos pasos de revisión
  con IDs estables y únicos.
- Los valores permitidos de método, lado y equipo deben seguir exactamente el
  validador. Debe existir al menos un paso con `equipment: "none"`.
- Un paso UV solo puede requerir `external_uv_lamp` y debe declarar
  `optional=true`.
- Cada paso de calidad de lanzamiento debe incluir texto no vacío para todos
  los locales activos de `AppState.SUPPORTED_LOCALES`; una imagen o región de
  referencia sigue siendo opcional, pero válida si está presente. El inglés
  solo puede ser referencia técnica de orden o fallback, nunca sustituto de un
  locale activo faltante.
- El modo compat puede aceptar `review` draft/vacío, `series` vacío u OCR
  vacío únicamente como estado legacy-compatible. Nunca usar esas excepciones
  para datos nuevos finales.

## Imágenes specimen

- Guardar la imagen en `godot/assets/bills_official/`.
- Usar un nombre estable: `<pais>_<denominacion>_front.<ext>`.
- Preferir PNG o JPG descargado de la fuente oficial.
- No redimensionar ni recomprimir el archivo fuente.
- Confirmar visualmente que la textura no quede recortada en `CurrencyInfo`.
- Si la fuente oficial prohíbe redistribución de la imagen, no incorporarla
  hasta definir una alternativa autorizada.

## Datos y validación

Antes de dar por terminado un país:

- Registrar la información en `godot/data/currencyinfo.json` usando las
  claves y formatos existentes.
- Completar `source_url` con la página oficial directa de cada denominación.
- Verificar que las medidas de seguridad correspondan a ese billete, no a una
  serie anterior ni a otro país.
- Probar selección de país, tarjeta de información, apertura del enlace
  oficial y visualización de la imagen completa en una pantalla angosta.
- Ejecutar `tools/validate_currencyinfo.ps1` y el parseo headless de Godot.

### Validación de compatibilidad y modo release

- Ejecutar el validador de compatibilidad antes y después de editar; registrar
  y actualizar de forma intencional la línea base esperada de conteo/hash si
  el cambio válido lo requiere.
- Nunca suprimir, desactivar ni modificar una comprobación para ocultar un
  fallo. Un cambio de baseline debe representar el contenido final revisado.
- En modo release, completar todos los campos de calidad de lanzamiento,
  ejecutar la validación release y reportar los fallos legacy existentes en
  lugar de evitarlos o degradar la validación.
- Ejecutar el parseo headless y verificar en UI el selector de país, tarjeta,
  imagen completa, enlace oficial y pasos de revisión en una pantalla angosta.

## Lista de control por país

### Prioridad de fuentes para imágenes

- La búsqueda de imágenes specimen debe comenzar siempre en fuentes oficiales:
  banco central, autoridad monetaria, organismo emisor o programa oficial de
  moneda.
- Intentar exhaustivamente todos los recursos oficiales disponibles antes de
  consultar una fuente no oficial. Revisar, como mínimo, la página de la
  denominación, la página de la serie, galerías, fichas técnicas, PDFs y
  repositorios de descarga del emisor.
- Solo si no queda ningún recurso oficial utilizable se puede recurrir a una
  fuente no oficial. La imagen debe seguir siendo verificable y corresponder
  exactamente al billete, denominación y serie.
- En el checklist final, avisar explícitamente cuando no se encontró una
  fuente oficial y registrar la fuente no oficial utilizada, incluyendo su
  URL y el motivo por el que fue necesaria.

- [ ] Tres denominaciones vigentes más altas seleccionadas.
- [ ] Tres imágenes specimen oficiales completas incorporadas.
- [ ] Tres enlaces oficiales directos incorporados.
- [ ] Medidas de seguridad verificadas para cada denominación.
- [ ] Datos, nombres de archivo y país correctos.
- [ ] schema_version: 2, colección CurrencyInfo y campos country/currency/denomination/note_id/series/image_path/source completos.
- [ ] note_id único coincide con la normalización de currency_denomination del validador.
- [ ] Legacy y localizaciones no vacías para todos los locales activos de AppState.SUPPORTED_LOCALES de resumen, marca de agua y medidas completos; conteo/orden de medidas coincide con la referencia técnica inglesa si corresponde.
- [ ] Metadatos de reconocimiento, estado y pasos de revisión de calidad de lanzamiento completos.
- [ ] recognition.front_reference coincide exactamente con image_path y denomination_tokens incluye la denominación.
- [ ] En release text_tokens y series no están vacíos; compat legacy no se usó para datos finales nuevos.
- [ ] review.status es ready, hay al menos dos pasos y sus IDs estables son únicos.
- [ ] Cada paso usa método/lado/equipo permitidos; existe uno con equipment: "none" y UV solo usa external_uv_lamp con optional=true.
- [ ] Cada paso incluye texto no vacío para todos los locales activos de AppState.SUPPORTED_LOCALES; región/imagen de referencia es opcional pero válida si se incluye.
- [ ] Si se agregó un idioma: AppState.SUPPORTED_LOCALES y $supportedLocales del validador se actualizaron atómicamente; también se completaron normalización/display de locale, textos UI/país/moneda/Acerca de y todos los mapas del catálogo.
- [ ] Validador de compatibilidad y baseline esperado de conteo/hash ejecutados y actualizados intencionalmente si corresponde.
- [ ] Validación release ejecutada; fallos legacy existentes reportados sin bypass.
- [ ] Flujo visual validado en Godot.
