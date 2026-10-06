# Parcial 1: Liquidación de Producción de un Taller de Confecciones

**Asignatura:** Programación III  
**Programa:** Ingeniería de Sistemas y Computación  
**Institución:** Universidad del Quindío  
**Docente:** Robinson Arias Muñoz  

---

## 👥 Integrantes del Grupo

- **Juan Camilo Agudelo Sanchez**
- **Jeronimo Delgado Estrada**
- **Jose Daniel Carmona Garcia**

---

## ⚙️ Restricciones Técnicas Cumplidas
El proyecto se diseñó y construyó respetando estrictamente el alcance permitido del curso:
* **Sin recursividad:** Todo el procesamiento y transformación de colecciones se realizó con `Enum` y comprensiones `for`.
* **Sin structs:** Se usaron mapas (`Map`), listas (`List`), tuplas (`Tuple`) y listas de palabras clave (`Keyword list`).
* **Sin módulos de archivos:** No se utilizó el módulo `File`.
* **Sin concurrencia ni proyectos Mix:** No se usaron procesos (`spawn`, `Task`, `Agent`, `GenServer`) ni gestor de dependencias `mix`.
* **Manejo de errores:** Lógica de negocio controlada mediante tuplas `{:ok, valor}` y `{:error, motivo}` encadenadas con `with`.


## 📋 Descripción del Proyecto

Este proyecto implementa una solución funcional en **Elixir** para gestionar y liquidar la producción semanal de confeccionistas de un taller de uniformes escolares.

El sistema procesa los datos de producción proporcionados en `datos.exs`, valida cada lote según las reglas establecidas en el enunciado, calcula las liquidaciones correspondientes y genera los ocho reportes solicitados.

Además, el programa implementa las actividades de investigación de la Parte C:

- **C.1:** Ranking mediante Keyword Lists.
- **C.2:** Combinación de producción mediante `Map.merge/3`.
- **C.3:** Comparación de tiempos de ejecución mediante `:timer.tc/1`.

El programa también permite realizar consultas individuales por código de confeccionista y registrar un lote adicional durante la ejecución.

---

## 🗂️ Organización del Proyecto

El proyecto está organizado en los siguientes módulos:

| Archivo | Responsabilidad |
|---|---|
| `datos.exs` | Contiene los confeccionistas, líneas de producción y lotes de la semana. |
| `validacion.exs` | Valida los lotes según las cinco reglas establecidas. |
| `liquidacion.exs` | Calcula valores de lotes, bonificaciones, alquileres y liquidaciones. |
| `reportes.exs` | Genera los reportes R1 a R8 y las funciones de investigación de la Parte C. |
| `util.exs` | Contiene funciones auxiliares para entrada de datos y presentación. |
| `programa.exs` | Contiene el módulo `Programa`, el `main` y la ejecución general del sistema. |
| `README.md` | Documentación, requisitos y comandos de compilación y ejecución. |

---

## 🧩 Módulos del Sistema

### Datos

El módulo `Datos` proporciona las colecciones iniciales utilizadas por el programa:

- Confeccionistas.
- Líneas de producción.
- Lotes de producción.

Los datos se mantienen separados de la lógica del programa para facilitar su reemplazo durante la sustentación.

### Validacion

El módulo `Validacion` verifica los lotes mediante las cinco reglas establecidas por el enunciado:

1. El confeccionista debe existir.
2. La línea de producción debe existir.
3. El día debe ser un entero entre 1 y 6.
4. La cantidad de prendas debe ser un entero entre 1 y 180.
5. El porcentaje de defectos debe estar entre 0 y 100.

Las validaciones se ejecutan en el orden indicado utilizando `with`.

### Liquidacion

El módulo `Liquidacion` contiene los cálculos relacionados con la liquidación de los confeccionistas:

- Valor económico de cada lote.
- Bonificación diaria por productividad.
- Descuento por alquiler de máquina.
- Días trabajados.
- Total de bonificaciones.
- Liquidación individual.
- Liquidación de todos los confeccionistas.

### Reportes

El módulo `Reportes` genera los ocho reportes solicitados:

- R1: Lotes rechazados.
- R2: Producción por línea.
- R3: Producción diaria.
- R4: Liquidación de confeccionistas.
- R5: Mayor producción diaria.
- R6: Mejor calidad.
- R7: Total pagado y promedio por prenda.
- R8: Confeccionistas presentes en todas las líneas.

También contiene las funciones correspondientes a la investigación de la Parte C.

### Util

El módulo `Util` concentra funciones auxiliares relacionadas con:

- Lectura de lotes adicionales.
- Lectura del código del confeccionista.
- Conversión de datos ingresados por consola.
- Formateo de valores monetarios.
- Formateo de valores decimales.
- Presentación de mensajes y títulos.

### Programa

El módulo `Programa` coordina la ejecución completa del sistema mediante la función:
Programa.main()

## 🖥️ Entrada de datos
- Al iniciar el programa se solicita opcionalmente un lote adicional el formato esperado es:confeccionista;linea;dia;prendas;defectos
Ejemplo:C01;L1;2;100;2.5
- Si se presiona enter sin escribir informacion, el lote adicional se omite
- Si el formato es incorrecto, el sistema informa que el formato no es válido.
- Posteriormente el lote pasa por las mismas validaciones utilizadas para los lotes iniciales

## 🔍 Consulta individual
- Al finalizar los reportes, el programa permite consultar el comprobante individual de un confeccionista mediante su código
- Se puede ingresar el código utilizando mayúsculas o minúsculas. 
- Ejemplo un codigo como C06 puede ser ingresado como c06

##  🛠️ Compilación
1. Ubicarse en la carpeta del Proyecto
2. Compilar los modulos: elixirc datos.exs validacion.exs liquidacion.exs reportes.exs 
util.exs
- Esto genera los archivos .beam correspondientes a los módulos compilados.
- El archivo programa.exs funciona como programa ejecutable y no necesita ser compilado previamente mediante elixirc.
3. Ejecutar el programa: elixir programa.exs
- El programa iniciará el flujo completo y mostrará los reportes y las investigaciones en la consola.