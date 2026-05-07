# PRIVACY_POLICY_REVIEW

## Resumen técnico de revisión (branch actual)

> Nota: en el repositorio local, la rama activa detectada fue `work`.  
> **REQUIERE CONFIRMACIÓN**: si en tu entorno de publicación la rama objetivo es `new version`, validar que su contenido coincida.

## 1) Identidad de app detectada

- **package name (manifest):** `com.appsimple.detectorbilletesfalsos`
- **versionName (manifest):** `1.6`
- **versionCode (manifest):** `23`
- **nombre visible en recursos (default):** `Counterfeit Money Detector`
- El contexto del proyecto y documentación usan nombre funcional en español: **Detector de Billetes Falsos**.

## 2) Permisos detectados en AndroidManifest.xml

- `android.permission.WAKE_LOCK`
- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.INTERNET`
- `android.permission.ACCESS_WIFI_STATE`
- `android.permission.READ_PHONE_STATE`
- `android.permission.SYSTEM_ALERT_WINDOW`
- `android.permission.GET_TASKS`

### Sensibles / observaciones

- `READ_PHONE_STATE`: permiso sensible en políticas modernas; revisar necesidad real en el build publicado.
- `SYSTEM_ALERT_WINDOW` y `GET_TASKS`: permisos heredados/antiguos; revisar si siguen presentes o son requeridos en la versión que se sube a Google Play.

## 3) Uso de cámara, micrófono, ubicación, contactos, almacenamiento

- **Cámara:** no se encontró permiso de cámara en manifest ni uso explícito de API de cámara.
- **Micrófono:** no detectado.
- **Ubicación:** no detectado.
- **Contactos:** no detectado.
- **Almacenamiento (READ/WRITE_EXTERNAL_STORAGE):** no detectado.

## 4) SDKs y librerías de terceros detectadas

- **Google Mobile Ads / AdMob**
  - Uso de `com.google.android.gms.ads.AdView` y `AdRequest` en múltiples Activities y layouts.
  - Actividad declarada: `com.google.android.gms.ads.AdActivity`.
- **Google Play Services**
  - Meta-data `com.google.android.gms.version`.
  - Referencia de librería en `project.properties`.
- **StartApp**
  - Activity declarada en manifest: `com.startapp.android.publish.AppWallActivity` (referencia heredada).
  - **REQUIERE CONFIRMACIÓN**: validar si el SDK StartApp está realmente empaquetado en el build Android actual o solo quedó referencia legacy.
- **Google+ PlusShare (legacy)**
  - Clase `GplusService` usa `com.google.android.gms.plus.PlusShare`.
  - **REQUIERE CONFIRMACIÓN**: verificar si esa ruta sigue activa en runtime y si compila con toolchain actual.

## 5) Red, APIs, WebView, subida de imágenes, procesamiento local

- No se detectaron clientes HTTP explícitos tipo OkHttp/Retrofit/Volley/HttpURLConnection en el código revisado.
- No se detectó `WebView`.
- Se detectaron intents para abrir URLs de Google Play.
- No se detectó lógica de subida de imágenes de usuario.
- El uso funcional de imágenes (billetes/recursos) parece local al proyecto.

## 6) Publicidad / analytics / crash reporting / cuentas de usuario

- **Publicidad:** sí (AdMob; y referencia StartApp heredada).
- **Analytics:** no se detectó integración explícita de Firebase Analytics.
- **Crash reporting:** no se detectó Crashlytics.
- **Login/cuentas/formularios:** no se detectaron.

## 7) Posibles datos recopilados (a declarar con cautela)

Por el código propio:
- No se observan formularios de PII ni cuentas.

Por SDKs publicitarios (potencialmente):
- Identificadores del dispositivo/publicidad.
- Datos técnicos de red/dispositivo y señales de uso para entrega de anuncios.

**REQUIERE CONFIRMACIÓN**:
- El detalle exacto de datos tratados depende de la versión final de SDKs incluidos en el AAB/APK publicado y su configuración en tiempo de ejecución.

## 8) Posibles datos compartidos con terceros

- Potencial compartición con proveedores de publicidad/servicios (Google Ads y, si aplica en build final, StartApp), para operación de anuncios.
- No se detecta backend propio del desarrollador que reciba datos personales.

## 9) Qué declarar en Google Play Console (orientativo)

- En **Política de Privacidad**:
  - URL pública que apunte directamente a una página de política (no EULA).
- En **Seguridad de los datos**:
  - Revisar y declarar tratamiento vinculado a SDKs publicitarios efectivamente incluidos.
  - Confirmar si se recopilan identificadores del dispositivo/anuncios y con qué fines.
  - Confirmar si hay compartición de datos con terceros para publicidad.

## 10) Dudas / puntos de validación manual

- **REQUIERE CONFIRMACIÓN**: rama exacta de release (`new version`) vs rama local analizada (`work`).
- **REQUIERE CONFIRMACIÓN**: si StartApp sigue en dependencias reales del build final.
- **REQUIERE CONFIRMACIÓN**: necesidad actual de permisos heredados (`READ_PHONE_STATE`, `SYSTEM_ALERT_WINDOW`, `GET_TASKS`) frente a políticas vigentes.
- Email de contacto actualizado en la política: `rodrigofantino@gmail.com`.
