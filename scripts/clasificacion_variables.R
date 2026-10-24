# clasificacion_variables.R — Parte A: clasificación de las variables de clientes.csv.
#
# El archivo data/clientes.csv tiene 12 clientes y 7 variables (más el id).
# El objetivo: clasificar cada variable (numérica continua/discreta, categórica
# binaria/ordinal/nominal) y verificar la clasificación en código.
#
# Regla del capítulo 3: el tipo que infiere el lenguaje es una pista, no la
# clasificación — el criterio (¿tiene sentido la mitad del valor? ¿hay orden
# entre las categorías?) decide.
#
# Uso (desde la raíz del repositorio):  Rscript scripts/clasificacion_variables.R

clientes <- read.csv("data/clientes.csv", stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# 1. Estructura del archivo
# ---------------------------------------------------------------------------
cat("PASO 1: Estructura del archivo\n\n")
cat(sprintf("Dimensiones: %d filas × %d columna\n\n", nrow(clientes), ncol(clientes)))
cat("Primeras filas:\n")
print(clientes)
cat("\n")

# ---------------------------------------------------------------------------
# 2. Tipos inferidos (str) — La pista que da el lenguaje
# ---------------------------------------------------------------------------
cat("PASO 2: Tipos inferidos (str)\n\n")
str(clientes)
cat("\n")

cat("Se puede ver que la columnas detectadas como texto son: cliente_id, genero, nivel_educacion, ciudad.\n")
cat("Mientras que las detectadas como entero son: edad, numero_hijos, ingresos_mensuales, satisfaccion.\n\n")

# ---------------------------------------------------------------------------
# 3. Valores únicos — ¿Cuántas categorías hay y cuáles son?
# ---------------------------------------------------------------------------
cat("PASO 3: Valores únicos por columna\n\n")
for (columna in names(clientes)) {
  unicos <- unique(clientes[[columna]])
  cat(sprintf("Columna %-20s:%d valores únicos %s\n", columna, length(unicos), paste(deparse(unicos), collapse="")))
}
cat("\n")
cat(sprintf("La variable 'genero' tiene %d categorías únicas: %s\n\n", 
            length(unique(clientes$genero)), 
            paste(deparse(unique(clientes$genero)), collapse="")))

# ---------------------------------------------------------------------------
# 4. Declarar el orden de las variables ordinales
# ---------------------------------------------------------------------------
# Una ordinal se guarda como texto y su orden natural se pierde: alfabéticamente
# "Posgrado" iría antes que "Primaria", que no tiene sentido. En R, eso se
# declara con el factor ordenado.
cat("PASO 4: Declaración y verificación de variables ordinales\n\n")

# Convertir nivel_educacion a factor ordenado
clientes$nivel_educacion <- factor(
  clientes$nivel_educacion,
  levels = c("Primaria", "Secundaria", "Universidad", "Posgrado"),
  ordered = TRUE
)

cat(sprintf("Comprobación nivel_educacion min: %s\n", min(clientes$nivel_educacion)))

# Convertir satisfaccion a factor ordenado
clientes$satisfaccion <- factor(
  clientes$satisfaccion,
  levels = c(1, 2, 3, 4, 5),
  ordered = TRUE
)

cat(sprintf("Comprobación satisfaccion min: %s\n\n", min(clientes$satisfaccion)))

cat("DEMOSTRACIÓN EXTRA:\n")
prueba_typo <- factor(
  c("Posgrado", "Primaria"),
  levels = c("Postgrado", "Primaria"),
  ordered = TRUE
)
cat("Si definimos las categorías con 'Postgrado', los datos que decían 'Posgrado'\n")
cat(sprintf("no coinciden y se vuelven nulos. Cantidad de valores nulos generados: %d\n\n", sum(is.na(prueba_typo))))

# ---------------------------------------------------------------------------
# 5. Resumen de la clasificación (para el informe)
# ---------------------------------------------------------------------------
cat("PASO 5: Resumen de la clasificación\n\n")

clasificacion <- c(
  cliente_id         = "Cualitativa nominal (Identificador)",
  edad               = "Cuantitativa discreta",
  numero_hijos       = "Cuantitativa discreta",
  genero             = "Cualitativa nominal",
  nivel_educacion    = "Cualitativa ordinal",
  ciudad             = "Cualitativa nominal",
  ingresos_mensuales = "Cuantitativa continua",
  satisfaccion       = "Cualitativa ordinal"
)

for (variable in names(clasificacion)) {
  cat(sprintf("  %-20s %s\n", variable, clasificacion[[variable]]))
}
