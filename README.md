# Clasificación de Enfermedad de Alzheimer y Demencia Frontotemporal mediante Aprendizaje Automático y Análisis de Señales EEG

**Trabajo Fin de Grado — Ingeniería Biomédica**  
**Autora:** Laura Martín García  
**Directora:** Dra. Estefanía Estevez Priego  
**Universidad Europea de Madrid — Junio 2026**

---

## Descripción

Este repositorio contiene el código desarrollado para la clasificación automática multiclase de señales EEG en reposo, con el objetivo de discriminar entre tres grupos diagnósticos:

- Enfermedad de Alzheimer (EA)
- Demencia Frontotemporal (DFT)
- Sujetos sanos (Control)

El sistema integra características espectrales de señales EEG con variables clínicas y demográficas, aplicando clasificadores SVM y Random Forest a nivel de canal individual y por regiones cerebrales.

---

## Requisitos

- **MATLAB R2022a** o superior
- **Statistics and Machine Learning Toolbox** (incluida en MATLAB)

---

## Base de datos

La base de datos utilizada es **OpenNeuro ds004504**, disponible públicamente en:

> https://openneuro.org/datasets/ds004504

Esta base de datos contiene registros EEG en estado de reposo (ojos cerrados) de 88 sujetos: 36 con Enfermedad de Alzheimer, 23 con Demencia Frontotemporal y 29 controles sanos, adquiridos en el Hospital General AHEPA (Tesalónica, Grecia).

### Estructura esperada de la base de datos

Una vez descargada, la carpeta de la BBDD debe contener la siguiente estructura:

```
BBDD/
├── AD/            ← archivos .mat de sujetos con Alzheimer
├── FTD/           ← archivos .mat de sujetos con Demencia Frontotemporal
├── Control/       ← archivos .mat de sujetos sanos
├── AD.xlsx        ← variables clínicas del grupo Alzheimer
├── FTD.xlsx       ← variables clínicas del grupo Demencia Frontotemporal
└── C.xlsx         ← variables clínicas del grupo Control
```

---

## Estructura del repositorio

```
repositorio/
├── EEG_DementiaClassifier.m        ← Script principal (punto de entrada)
├── cv_clasificar.m                 ← Validación cruzada agrupada por sujeto
├── calcular_potencias.m            ← Potencia espectral por canal
├── calcular_potencias_regiones.m   ← Potencia espectral por región cerebral
├── unir_clinicos.m                 ← Integración de variables clínicas
├── run_SVM_canales.m               ← Clasificador SVM por canal
├── run_SVM_regiones.m              ← Clasificador SVM por región
├── run_RF_canales.m                ← Clasificador Random Forest por canal
└── run_RF_regiones.m               ← Clasificador Random Forest por región
```

---

## Instrucciones de uso

1. Descargar la base de datos desde el enlace indicado arriba.
2. Abrir MATLAB y ejecutar el script principal:

```matlab
EEG_DementiaClassifier.m
```

3. El script solicitará mediante una ventana de diálogo:
   - La carpeta raíz de la base de datos (que contiene las carpetas AD/, FTD/ y Control/).
   - La carpeta donde se guardarán los resultados (archivos `.xlsx`).

4. Los resultados se exportan automáticamente con la nomenclatura:  
   `res_<clasificador>_<granularidad>_<modalidad>_rng1.xlsx`  
   Por ejemplo: `res_SVM_canales_multimodal_rng1.xlsx`

---

## Parámetros principales

| Parámetro | Valor |
|---|---|
| Frecuencia de muestreo | 500 Hz |
| Número de electrodos | 19 (sistema 10-20) |
| Bandas de frecuencia | Delta, Theta, Alpha, Beta, Gamma |
| Validación cruzada | 5-fold agrupada por sujeto |
| Semilla aleatoria | rng(1) |

---

## Resultados

El modelo con mejor rendimiento global fue el **Random Forest multimodal a nivel de canal**, con una *accuracy* de **0,733**.

---

## Referencia

Si se utiliza este código, se ruega citar el trabajo original:

> Martín García, L. (2026). *Clasificación de enfermedad de Alzheimer y demencia frontotemporal mediante modelos de aprendizaje automático y análisis multiescala de señales EEG*. Trabajo Fin de Grado, Universidad Europea de Madrid.

La base de datos empleada está descrita en:

> Miltiadous et al. (2023). A Dataset of Scalp EEG Recordings of Alzheimer's Disease, Frontotemporal Dementia and Healthy Subjects from Routine EEG. *Data*, 8(6), 95. https://doi.org/10.3390/data8060095
