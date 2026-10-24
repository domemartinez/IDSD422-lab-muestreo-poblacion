# Informe — Clasificación de variables y población vs. muestra

**Para:** Gerencia de RetailAndina S.A. · **De:** Equipo de Business Intelligence/ Doménica Micaela Martínez Guerrero
**Fecha:** 23/10/2026 · **Asunto:** Base de fidelización: tipos de variables y estimación por muestreo

---

## Resumen ejecutivo

RetailAndina S.A. requería estructurar su base de fidelización para comprender la naturaleza de sus variables, además de estimar el ingreso mensual promedio de los clientes utilizando una muestra de tamaño $n=20$ frente al parámetro real de la población ($N=400$). Como analista, verifiqué los tipos y órdenes estadísticos mediante código y evalué tres diseños de muestreo (convenida, aleatorio simple y estratificado), demostrando que la calidad de la estimación depende fundamentalmente del diseño metodológico y no meramente del volumen de datos.

## Parte A — Clasificación de las variables

*Completa la tabla usando el **criterio** (¿tiene sentido la mitad del valor? ¿hay orden entre las categorías?), no el ejemplo. En «verificación» anota qué mostró el código: dtype, número de valores únicos y, si declaraste el orden, cómo lo comprobaste.*

| Variable | Tipo | Justificación (criterio) | Verificación en código |
|---|---|---|---|
| `cliente_id` |Cualitativa Nominal  |Código único para identificar clientes, no acepta operaciones aritméticas |`object`, 12 valores únicos (C001 a C012) |
| `edad` |Cuantitativa discreta|Mide los años reales cumplidos en números enteros| `int64`, rango de 22 a 48 años. |
| `numero_hijos` |Cuantitativa discreta |Conteo numérico exacto de personas, no acepta decimales |`int64`, 5 valores únicos (0 a 4) |
| `genero` |Cualitativa Nominal  |Categorías de identidad sin relación de orden entre ellas. |`object`, 3 categorías (Femenino, Masculino, Otro) |
| `nivel_educacion` |Cualitativa ordinal |Categorías de formación académica tiene una jerarquía natural evidente |Llega como `object` pero fue convertida a `CategoricalDtype` (min Primaria, max Posgrado)|
| `ciudad` |Cualitativa Nominal  |Categorías de ubicación geográfica sin orden jerárquico |`object`, 3 categorías (Quito, Guayaquil, Cuenca) |
| `ingresos_mensuales` |Cuantitativa continua |Variable monetaria que admite valores decimales e intervalos medibles |`int64` valores de 760 a 2450 USD. |
| `satisfaccion` |Cualitativa ordinal |Escala de valoración (1 al 5) con orden explícito |Llega como `int64` pero fue convertida a `CategoricalDtype` ordenada (min 2, max 5) |

**P1.** ¿Qué te dijo el dtype de `satisfaccion` y por qué no basta para clasificarla? ¿Qué pasa si una ordinal queda como texto sin declarar el orden?

 El dtype asignó 'int64'. No basta porque le asigna una naturaleza de número entero, pero en la práctica representa una escala ordinal. No podemos afirmar quen cliente con nivel 4 tenga 'el doble de satisfacción' que uno con nivel 2.

Se procesará con orden alfabético por defecto, haciendo que Posgrado vaya antes que Primaria, lo que distorsionaría cualquier análisis, ordenamiento de tablas o gráfico descriptivo.


## Parte B — Población vs. muestra

### La población y su parámetro

| Concepto | Valor |
|---|---|
| Población (N) |400 clientes |
| Variable de interés |`ingresos_mensuales` |
| Parámetro poblacional (media) |1330.73 USD |

**¿Por qué se muestrea si aquí el parámetro existe y se calculó?**

Se muestrea porque en escenarios reales del negocio el acceso a toda la población (censos completos) suele ser costoso, lento o inviable. Este ejercicio con $N=400$ sirve únicamente como un entorno de laboratorio controlado para medir el error y evaluar qué tan bien se comportan las muestras frente a un parámetro real ya conocido

### Los tres diseños

*Corre tu script y registra las salidas. La composición por ciudad es la que delata el sesgo: anótala tal como salió.*

| Diseño | n | Media estimada | Composición por ciudad | Diferencia vs. parámetro |
|---|---|---|---|---|
| Conveniencia (`head`) |20 |1348.50 USD |`{'Quito': 20}` |+17.77 USD |
| Aleatorio simple (`sample`) |20 |1336.00 USD |`{'Cuenca': 8, 'Quito': 8, 'Guayaquil': 4}` |+5.27 USD |
| Estratificado (`groupby` + 5 %) |20 |1287.50 USD | `{'Quito': 10, 'Guayaquil': 6, 'Cuenca': 4}`|-43.23 USD |

*Anota también las medias de 5 sorteos distintos del aleatorio simple (semillas 1 a 5):*

| Semilla | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Media | 1336.00 USD | 1405.00 USD | 1235.00 USD | 1491.50 USD | 1288.00 USD |

**P2.** ¿Cuánto vale el parámetro poblacional y cuánto estimó cada diseño? ¿Cuál quedó más cerca y por qué eso **no** alcanza para declarar un ganador?

El parámetro poblacional real es de 1330.73 USD. La muestra por conveniencia estimó 1348.50 USD, el aleatorio simple 1336.00 USD, y el estratificado 1287.50 USD. Aunque el aleatorio simple quedó numéricamente más cerca en esta ejecución específica, un solo número no basta para declarar un ganador porque la estimación aleatoria cambia con cada sorteo (como se comprobó con las distintas semillas), lo que demuestra que el resultado puntual depende de la suerte del muestreo y no de una superioridad metodológica constante.

**P3.** La muestra por conveniencia también tiene 20 filas. ¿Qué defecto tiene y cómo lo delatas en la composición por ciudad? ¿Se corrige tomando más filas?

El gran defecto de la conveniencia es el sesgo de selección. Al tomar las primeras 20 filas, la composición por ciudad arrojó 100% de registros pertenecientes a Quito, omitiendo por completo a Guayaquil y Cuenca. Este defecto no se corrige tomando más filas, ya que el problema radica en que el mecanismo de selección no es aleatorio ni representativo de la estructura poblacional.

**P4.** El sorteo aleatorio dio un número distinto en cada semilla. ¿Qué implica esa variabilidad para una empresa que va a decidir con un solo estudio?

Implica que existe un error de muestreo o variabilidad inherente al azar. Para una empresa como RetailAndina, tomar una decisión gerencial basada en un único estudio aleatorio es riesgoso porque la media estimada osciló ampliamente desde 1235.00 USD en la semilla 3 hasta 1491.50 USD en la semilla 4. Esto demuestra la necesidad de conocer los márgenes de error, los intervalos de confianza o utilizar diseños que controlen la variabilidad, como el muestreo estratificado.

**P5.** ¿Cuándo usarías cada diseño en la práctica? Relaciona cada uno con un uso real (piloto, subgrupos que deben aparecer, conclusión sobre toda la población).

* **Muestreo por conveniencia:** Lo usaría exclusivamente en fases exploratorias
rápidas o pruebas piloto de bajo costo donde no se busca generalizar hacia toda la población.

* **Muestreo aleatorio simple:** Lo usaría cuando la población es homogénea y se requiere una inferencia estadística imparcial sobre el total sin necesidad de asegurar cuotas por subgrupos.

* **Muestreo estratificado:** Lo usaría cuando la población está dividida en subgrupos o estratos definidos, como las ciudades de Quito, Guayaquil y Cuenca. Es estrictamente necesario garantizar que todos los subgrupos estén representados proporcionalmente en la muestra para evitar sesgos estructurales.

## Conclusiones

1. **La naturaleza estadística de los datos:** Se comprobó que el tipado automático proporcionado por los lenguajes de programación es solo una referencia técnica inicial, siendo indispensable aplicar criterios conceptuales para clasificar correctamente variables ordinales, como `satisfaccion` y evitar distorsiones en los análisis.
2. **El impacto crítico del diseño de muestreo:** A través de la experimentación con los tres enfoques, se confirmó la lección central del laboratorio: *el diseño decide, no el tamaño*. Un diseño sesgado como el de conveniencia falla por completo en representar la población independientemente del volumen de datos, mientras que la estratificación y la aleatorización controlan de mejor manera la representatividad y el error

## Recomendaciones

Se recomienda a la gerencia de RetailAndina S.A. descartar el uso de muestras por conveniencia para decisiones estratégicas y optar por un diseño de muestreo estratificado por ciudad. Esto garantizará una representatividad proporcional de los clientes de Quito con un 50%, Guayaquil con el 30% y Cuenca con 20%, reduciendo el riesgo de tomar decisiones basadas en sesgos geográficos o en oscilaciones muestrales del azar.
