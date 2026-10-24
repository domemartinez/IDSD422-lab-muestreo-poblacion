# muestreo.R — Parte B: población vs. muestra (RetailAndina).
#
# La población es la base completa de fidelización: data/clientes_400.csv (N = 400).
# La pregunta de negocio: ¿cuál es el ingreso mensual promedio de los clientes?
# Se estima con tres diseños de muestreo y se compara cada estimación con el
# parámetro real, que aquí sí se conoce porque la población es pequeña y visible.
#
# Uso (desde la raíz del repositorio):  Rscript scripts/muestreo.R

poblacion <- read.csv("data/clientes_400.csv")
suppressPackageStartupMessages(library(dplyr))

reporte <- function(nombre, muestra, parametro) {
  # Imprime n, media estimada y composición por ciudad de una muestra.
  # La composición por ciudad es la pista que delata un sesgo de selección.
  if (is.null(muestra)) {
    cat(sprintf("[%s] pendiente de completar (TODO)\n", nombre))
    return(invisible(NULL))
  }
  media <- mean(muestra$ingresos_mensuales)
  
  # Convertir la tabla de frecuencias de ciudad a un formato limpio estilo diccionario para R
  tab_ciudad <- table(muestra$ciudad)
  ciudades_str <- paste0("'", names(tab_ciudad), "': ", tab_ciudad, collapse = ", ")
  
  cat(sprintf("[%s] n=%d  media=%.2f USD  (parámetro %.2f, diferencia %+.2f)\n",
              nombre, nrow(muestra), media, parametro, media - parametro))
  cat(sprintf("    composición por ciudad: {%s}\n", ciudades_str))
}

# ---------------------------------------------------------------------------
# 1. La población y su parámetro (N = 400)
# ---------------------------------------------------------------------------
# La base de fidelización completa es la población: 400 clientes. El parámetro
# es el ingreso mensual promedio real (solo calculable porque la población es
# pequeña y accesible: sirve de espejo para juzgar las muestras).
cat(sprintf("Población: %d clientes × %d columnas\n", nrow(poblacion), ncol(poblacion)))
parametro <- mean(poblacion$ingresos_mensuales)
cat(sprintf("Parámetro poblacional — ingreso medio: %.2f USD\n", parametro))

tab_pob <- table(poblacion$ciudad)
pob_str <- paste0("'", names(tab_pob), "': ", tab_pob, collapse = ", ")
cat(sprintf("Ciudades en la población: {%s}\n\n", pob_str))

# ---------------------------------------------------------------------------
# 2. Muestra por conveniencia: "los primeros que llegaron"
# ---------------------------------------------------------------------------
# TODO 1: toma como muestra las primeras 20 filas de la población.
#         Pista: head(poblacion, 20) — igual que la demo de clase.
#         Después de correrlo, mira la composición por ciudad que imprime el
#         reporte: ¿es un corte al azar? ¿alguna ciudad falta por completo?
cat("TODO 1: Muestra por conveniencia: los primeros que llegaron\n")
muestra_conv <- head(poblacion, 20)
reporte("Conveniencia", muestra_conv, parametro)
cat("\n")

# ---------------------------------------------------------------------------
# 3. Muestra aleatoria simple: el sorteo de 20
# ---------------------------------------------------------------------------
# TODO 2: sortea 20 clientes con la misma probabilidad para todos (20/400 = 5 %).
#         Pista: poblacion[sample(nrow(poblacion), 20), ] con set.seed(1)
#         delante para que sea reproducible (sin set.seed cambia cada vez).
# TODO 3: repite el sorteo con las semillas 2 a 5 y anota las 5 medias en el
#         informe: la variabilidad de la estimación es parte de la lección.
#         Pista: for (semilla in 1:5) { set.seed(semilla); ... }
cat("TODO 2 y 3: Muestra aleatoria simple: el sorteo de 20\n")
set.seed(1)
muestra_aas <- poblacion[sample(nrow(poblacion), 20), ]

cat("Repetición de semillas\n")
for (semilla in 1:5) {
  set.seed(semilla)
  m_temp <- poblacion[sample(nrow(poblacion), 20), ]
  cat(sprintf("Semilla %d: media estimada = %.2f USD\n", semilla, mean(m_temp$ingresos_mensuales)))
}
cat("\n")

# ---------------------------------------------------------------------------
# 4. Muestra estratificada: 5 % dentro de cada ciudad
# ---------------------------------------------------------------------------
# TODO 4: muestrea dentro de cada ciudad (el estrato), con afijación
#         proporcional: 5 % de cada una → 10 de Quito, 6 de Guayaquil y 4 de
#         Cuenca (20 en total).
#         Pista: library(dplyr); poblacion |> group_by(ciudad) |> slice_sample(prop = 0.05)
#         ¿Qué garantiza este diseño que el sorteo simple no garantiza?
cat("TODO 4: Muestra estratificada: 5 % dentro de cada ciudad\n")
set.seed(1)
muestra_est <- poblacion |> group_by(ciudad) |> slice_sample(prop = 0.05)
# |> operador de concatenación, lo que tenga a la izquierda actúa como parámetro a la función de la derecha

# ---------------------------------------------------------------------------
# 5. Comparación final
# ---------------------------------------------------------------------------
cat("\nComparación Final:\n\n")
reporte("Conveniencia", muestra_conv, parametro)
reporte("Aleatorio simple", muestra_aas, parametro)
reporte("Estratificado", as.data.frame(muestra_est), parametro)
cat("\n")

if (!is.null(muestra_conv) && !is.null(muestra_aas) && !is.null(muestra_est)) {
  resumen <- data.frame(
    diseno = c("Conveniencia (head)", "Aleatorio simple (sample)", "Estratificado (slice_sample)"),
    n = c(nrow(muestra_conv), nrow(muestra_aas), nrow(as.data.frame(muestra_est))),
    media_estimada = round(c(mean(muestra_conv$ingresos_mensuales),
                             mean(muestra_aas$ingresos_mensuales),
                             mean(as.data.frame(muestra_est)$ingresos_mensuales)), 2)
  )
  cat(sprintf("Parámetro poblacional: %.2f USD\n", parametro))
  print(resumen, row.names = FALSE)
  cat("\n")
} else {
  cat("Completa los TODO 1 a 4 para ver la tabla comparativa.\n")
}
