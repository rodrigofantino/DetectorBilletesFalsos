# Países sin billetes en el catálogo

## Criterio

Esta lista compara el universo de 195 Estados (193 miembros de la ONU más
Palestina y Ciudad del Vaticano) con el catálogo canónico activo:
`godot/data/currencyinfo.json`.

- Se considera cubierto un país con una ficha propia en `CurrencyInfo`.
- Los países que usan el euro se consideran cubiertos por la ficha común
  `Eurozone`; no se duplican billetes idénticos por país.
- Los países de la Unión Monetaria del Caribe Oriental se consideran cubiertos
  por las fichas regionales XCD de la ECCB; no se duplican billetes compartidos
  por cada Estado miembro.
- Los países de la UEMOA se consideran cubiertos por las fichas regionales XOF
  de la BCEAO; no se duplican billetes compartidos por cada Estado miembro.
- Los países de la CEMAC se consideran cubiertos por las fichas regionales XAF
  de la BEAC; no se duplican billetes compartidos por cada Estado miembro.
- Liechtenstein se considera cubierto por las fichas CHF de Suiza: conforme al
  Tratado Monetario, usa los billetes emitidos por el Banco Nacional Suizo.
- Hong Kong y Taiwán ya aparecen en el catálogo, pero no se cuentan dentro del
  universo de 195 Estados.
- La lista no agrega billetes ni reemplaza la verificación oficial exigida por
  `add_banknote.md`.

Resultado de la comparación: **59 países pendientes**; 52 tienen billetes o
emisión para relevar y 7 no emiten billetes nacionales independientes.

## Pendientes: países con billetes o emisión para relevar

- [ ] Macedonia del Norte
  - **Bloqueado (2026-09-06):** faltan specimens completos reutilizables para
    MKD 1000 y 500. El NBRSM confirma su circulación mediante las decisiones
    oficiales de [1000](https://www.nbrm.mk/content/%D0%A2%D1%80%D0%B5%D0%B7%D0%BE%D1%80/DECISION%20on%20putting%20into%20circulation%20of%20banknotes%20in%20denomination%20of%201000%20denars.pdf)
    y [500](https://www.nbrm.mk/content/%D0%A2%D1%80%D0%B5%D0%B7%D0%BE%D1%80/DECISION%20ON%20PUTTING%20INTO%20CIRCULATION%20OF%20BANKNOTES%20IN%20DENOMINATION%20OF%20500%20DENARS%20WITH%20MODIFIED%20FEATURES.pdf),
    y la guía oficial cubre 2000, pero los endpoints de asset responden 403 y
    no exponen las imágenes actuales. Wikimedia Commons no ofrece archivos
    pertinentes con licencia explícita; se rechazaron catálogos, tiendas y
    subastas. Reintentar si el NBRSM restaura los assets o aparece un fallback
    mundial claramente licenciado; no retirar de la cola ni usar sustitutos.
- [ ] Madagascar
  - **Bloqueado (2026-09-06):** el Banky Foiben’i Madagasikara confirma la
    serie NG17 de 20.000, 10.000 y 5.000 ariary en
    <https://nouveauxbillets.bfm.mg/>, pero sólo publica pósteres combinados,
    no specimens individuales completos. No se pueden recortar ni recomprimir.
    Existen además actualizaciones de 2025 para 20.000 y 10.000 que requieren
    confirmación y arte oficial individual. Reintentar con assets BFM o un
    fallback mundial claramente licenciado; no retirar de la cola ni usar
    pósteres recortados.
- [ ] Malaui
  - **Bloqueado (2026-09-07):** el Reserve Bank of Malawi confirma la
    circulación de MWK 5000, 2000 y 1000 en sus informes oficiales, pero no se
    localizaron specimens individuales completos reutilizables en los assets
    públicos del emisor. Se agotaron los intentos con RBM y se rechazaron las
    fichas secundarias de IACA, Keesing, Secura y BizMalawi por no ser assets
    oficiales/licenciados. Reintentar cuando RBM publique imágenes completas;
    no incorporar recortes ni sustitutos.
- [ ] Mauritania
  - **Bloqueado (2026-09-07):** el decreto oficial de la nueva unidad
    monetaria confirma las denominaciones actuales de 1000, 500 y 200 MRU
    ([Journal Officiel](https://msgg.gov.mr/sites/default/files/2020-11/JO%201402%20BIS%20FR%2027%2012%202017.pdf));
    la BCM es el emisor, pero su sitio oficial no expone specimens individuales
    reutilizables. Se intentaron BCM y la documentación oficial/estatal de AMI,
    y no se encontraron archivos pertinentes con licencia explícita en
    Wikimedia Commons. No incorporar imágenes de catálogos o subastas sin una
    licencia verificable; reintentar cuando BCM publique assets completos.
- [ ] Mozambique
  - **Bloqueado (2026-09-07):** el Banco de Moçambique confirma la serie
    2024 y las denominaciones MZN 1000, 500 y 200 en sus [anuncios oficiales](https://www.bancomoc.mz/en/media/highlights/banco-de-mocambique-releases-metical-app/)
    y en el [aviso de emisión](https://www.bancomoc.mz/media/v41le3wr/aviso-n-%C2%BA-8-gbm-2024-estabelece-a-emiss%C3%A3o-de-notas-e-moedas-do-metical-da-s%C3%A9rie-2024-e-define-as-respectivas-caracter%C3%ADsticas.pdf),
    pero los assets públicos encontrados son pósteres o PDFs anotados y no
    specimens individuales completos reutilizables. Se revisaron la [galería
    oficial de billetes](https://www.bancomoc.mz/en/educational/currency/banknotes/)
    (póster compuesto), el [PDF técnico MZN 1000](https://www.bancomoc.mz/media/xbip3c25/one-thousand-1000-meticais.pdf)
    (frente anotado, no specimen limpio), el [anuncio de la app Metical](https://www.bancomoc.mz/en/media/highlights/banco-de-mocambique-releases-metical-app/)
    (confirma 1000/500/200 pero no entrega fronts individuales), el [aviso de
    emisión 2024](https://www.bancomoc.mz/media/v41le3wr/aviso-n-%C2%BA-8-gbm-2024-estabelece-a-emiss%C3%A3o-de-notas-e-moedas-do-metical-da-s%C3%A9rie-2024-e-define-as-respectivas-caracter%C3%ADsticas.pdf)
    (características, sin assets limpios) y las búsquedas de [Wikimedia Commons para
    1000](https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=Mozambique%201000%20meticais%20banknote&gsrnamespace=6&format=json),
    [500](https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=Mozambique%20500%20meticais%20banknote&gsrnamespace=6&format=json)
    y [200](https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=Mozambique%20200%20meticais%20banknote&gsrnamespace=6&format=json)
    (sin resultados licenciados pertinentes). No recortar ni usar imágenes de
    catálogos; reintentar cuando el emisor publique fronts completos.
- [ ] Myanmar
- [ ] Namibia
- [ ] Nauru
- [ ] Nepal
- [ ] Nicaragua
- [ ] Noruega
- [ ] Omán
- [ ] Papúa Nueva Guinea
- [ ] Paraguay
- [ ] Polonia
- [ ] República Centroafricana
- [ ] República Checa
- [ ] Ruanda
- [ ] Rumania
- [ ] Samoa
- [ ] San Cristóbal y Nieves
- [ ] San Vicente y las Granadinas
- [ ] Santa Lucía
- [ ] Santo Tomé y Príncipe
- [ ] Senegal
- [ ] Seychelles
- [ ] Sierra Leona
- [ ] Singapur
- [ ] Somalia
- [ ] Sri Lanka
- [ ] Sudán
- [ ] Sudán del Sur
- [ ] Suecia
- [ ] Suiza
- [ ] Surinam
- [ ] Tanzania
- [ ] Tayikistán
- [ ] Togo
- [ ] Tonga
- [ ] Trinidad y Tobago
- [ ] Túnez
- [ ] Turkmenistán
- [ ] Tuvalu
- [ ] Uganda
- [ ] Uzbekistán
- [ ] Vanuatu
- [ ] Vietnam
- [ ] Yemen
- [ ] Yibuti
- [ ] Zambia
- [ ] Zimbabue

## Cubiertos por emisión regional compartida

- [x] Malí — usa los billetes XOF de la BCEAO; la BCEAO identifica a Mali
  como Estado miembro de la UMOA y describe la gama común de billetes FCFA en
  su [catálogo oficial](https://www.bceao.int/fr/content/billets-et-pieces).
- [x] Níger — usa los billetes XOF de la BCEAO; la BCEAO identifica a Niger
  como Estado miembro de la UMOA y describe la gama común de billetes FCFA en
  su [catálogo oficial](https://www.bceao.int/fr/content/billets-et-pieces).

## Sin emisión de billetes nacionales independientes

Estos países también están ausentes del catálogo, pero no corresponde buscar
una serie propia de billetes nacionales mientras mantengan el uso de moneda
extranjera o de billetes emitidos por otra autoridad:

- [x] Liechtenstein — franco suizo; los billetes son emitidos por el Banco
  Nacional Suizo conforme al Tratado Monetario con Suiza.
- [x] Montenegro — el euro es su medio oficial de pago desde 2002 y la
  autoridad nacional sólo gestiona la circulación de billetes euro; no emite
  una serie nacional propia. Véase la [información oficial de la CBCG](https://www.cbcg.me/en/currency/money-in-circulation).
- [ ] Ecuador — dólar estadounidense
- [ ] El Salvador — dólar estadounidense
- [ ] Estados Federados de Micronesia — dólar estadounidense
- [ ] Islas Marshall — dólar estadounidense
- [ ] Palaos — dólar estadounidense
- [ ] Panamá — dólar estadounidense; el balboa circula principalmente en monedas
- [ ] Palestina — usa principalmente el nuevo séquel israelí, el dinar jordano y el dólar estadounidense
- [ ] Timor-Leste — dólar estadounidense
