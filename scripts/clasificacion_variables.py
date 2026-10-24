# clasificacion_variables.py — Parte A: clasificación de las variables de clientes.csv.
#
# Uso (desde la raíz del repositorio):  python scripts/clasificacion_variables.py

import pandas as pd

# Cargar dataset desde la carpeta de datos
clientes = pd.read_csv("data/clientes.csv")

# ---------------------------------------------------------------------------
# 1. Estructura del archivo
# ---------------------------------------------------------------------------

print("PASO 1: Estructura del archivo")
print()
print(f"Dimensiones: {clientes.shape[0]} filas × {clientes.shape[1]} columna")
print()
print("Primeras filas:")
print(clientes.to_string(index=False))
print()

# ---------------------------------------------------------------------------
# 2. Tipos inferidos (dtype) — La pista que da el lenguaje
# ---------------------------------------------------------------------------

print("PASO 2: Tipos inferidos (dtype)")
print()
print(clientes.dtypes)
print()

print("Se puede ver que la columnas detectadas como texto son: cliente_id, genero, nivel_educacion, ciudad.")
print("Mientras que las detectadas como entero son: edad, numero_hijos, ingresos_mensuales, satisfaccion.")
print()

# ---------------------------------------------------------------------------
# 3. Valores únicos — ¿Cuántas categorías hay y cuáles son?
# ---------------------------------------------------------------------------

print("PASO 3: Valores únicos por columna")
print()
for columna in clientes.columns:
    unicos = clientes[columna].unique()
    print(f"Columna {columna:20s}:{len(unicos)} valores únicos {unicos}")
print()
print(f"La variable 'genero' tiene {len(clientes['genero'].unique())} categorías únicas: {list(clientes['genero'].unique())}\n")

# ---------------------------------------------------------------------------
# 4. Declarar el orden de las variables ordinales
# ---------------------------------------------------------------------------

print("PASO 4: Declaración y verificación de variables ordinales")
print()

# Convertir nivel_educacion a categórica ordenada
clientes["nivel_educacion"] = clientes["nivel_educacion"].astype(
    pd.CategoricalDtype(
        categories=["Primaria", "Secundaria", "Universidad", "Posgrado"],
        ordered=True
    )
)

print("Comprobación nivel_educacion min:", clientes["nivel_educacion"].min())

# Convertir satisfaccion a categórica ordenada (TODO 4)
clientes["satisfaccion"] = clientes["satisfaccion"].astype(
    pd.CategoricalDtype(
        categories=[1, 2, 3, 4, 5],
        ordered=True
    )
)
print("Comprobación satisfaccion min:", clientes["satisfission"].min()if hasattr(clientes, "satisfission") else clientes["satisfaccion"].min())
print()

print("DEMOSTRACIÓN EXTRA:")
prueba_typo = pd.Series(["Posgrado", "Primaria"]).astype(
    pd.CategoricalDtype(categories=["Postgrado", "Primaria"], ordered=True)
)
print("Si definimos las categorías con 'Postgrado', los datos que decían 'Posgrado'")
print(f"no coinciden y se vuelven nulos. Cantidad de valores nulos generados: {prueba_typo.isna().sum()}\n")

# ---------------------------------------------------------------------------
# 5. Resumen de la clasificación (para el informe)
# ---------------------------------------------------------------------------

print("PASO 5: Resumen de la clasificación ")

clasificacion = {
    "cliente_id": "Cualitativa nominal (Identificador)",
    "edad": "Cuantitativa discreta",
    "numero_hijos": "Cuantitativa discreta",
    "genero": "Cualitativa nominal",
    "nivel_educacion": "Cualitativa ordinal",
    "ciudad": "Cualitativa nominal",
    "ingresos_mensuales": "Cuantitativa continua",
    "satisfaccion": "Cualitativa ordinal",
}

for variable, tipo in clasificacion.items():
    print(f"  {variable:20s} {tipo}")
