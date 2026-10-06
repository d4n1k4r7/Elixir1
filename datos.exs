defmodule Datos do
  @moduledoc """
  Proporciona las colecciones iniciales de confeccionistas, líneas y lotes
  para el sistema de liquidación y reportes del taller de confecciones.
  """

  @doc """
  Retorna la lista de confeccionistas registrados en el taller.
  Contiene 10 confeccionistas (5 de ellos con alquiler de máquina activo).
  """
  def confeccionistas do
    [
      %{codigo: "C01", nombre: "Maria Elena Rios", alquiler: true},
      %{codigo: "C02", nombre: "Andres Salazar", alquiler: false},
      %{codigo: "C03", nombre: "Beatriz Gomez", alquiler: true},
      %{codigo: "C04", nombre: "Carlos Restrepo", alquiler: false},
      %{codigo: "C05", nombre: "Diana Morales", alquiler: true},
      %{codigo: "C06", nombre: "Eduardo Lopez", alquiler: false},
      %{codigo: "C07", nombre: "Gloria Jaramillo", alquiler: true},
      %{codigo: "C08", nombre: "Hernan Ortiz", alquiler: false},
      %{codigo: "C09", nombre: "Isabel Quintero", alquiler: true},
      %{codigo: "C10", nombre: "Jorge Valencia", alquiler: false}
    ]
  end

  @doc """
  Retorna la lista de líneas de producción del taller con sus puestos de trabajo.
  """
  def lineas do
    [
      %{id: "L1", nombre: "Linea Norte", puestos: 6},
      %{id: "L2", nombre: "Linea Central", puestos: 4},
      %{id: "L3", nombre: "Linea Sur", puestos: 5},
      %{id: "L4", nombre: "Linea Oriental", puestos: 3}
    ]
  end

  @doc """
  Retorna los lotes de producción entregados durante la semana.
  Incluye 80 lotes válidos (incluyendo los de calibración de C01) y
  10 lotes inválidos (exactamente 2 por cada motivo de rechazo).
  """
  def lotes do
    # --- 80 LOTES VÁLIDOS ---
    [
      # Lotes de verificación para C01 (María Elena Ríos - Ejemplo oficial del taller)
      %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7.0},
      %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12.0},

      # Lotes adicionales válidos para C01 (permiten que C01 trabaje en L3 y L4 para R8)
      %{confeccionista: "C01", linea: "L3", dia: 3, prendas: 60, defectos: 2.0},
      %{confeccionista: "C01", linea: "L4", dia: 4, prendas: 80, defectos: 4.5},

      # C02 (Andrés Salazar - trabaja en todas las líneas L1, L2, L3, L4 para R8)
      %{confeccionista: "C02", linea: "L1", dia: 1, prendas: 95, defectos: 1.0},
      %{confeccionista: "C02", linea: "L2", dia: 1, prendas: 40, defectos: 3.0},
      %{confeccionista: "C02", linea: "L3", dia: 2, prendas: 110, defectos: 2.0},
      %{confeccionista: "C02", linea: "L4", dia: 3, prendas: 130, defectos: 0.8},
      %{confeccionista: "C02", linea: "L1", dia: 4, prendas: 100, defectos: 1.5},
      %{confeccionista: "C02", linea: "L2", dia: 5, prendas: 140, defectos: 1.2},
      %{confeccionista: "C02", linea: "L3", dia: 6, prendas: 125, defectos: 1.8},

      # C03 (Beatriz Gómez)
      %{confeccionista: "C03", linea: "L2", dia: 1, prendas: 80, defectos: 4.0},
      %{confeccionista: "C03", linea: "L2", dia: 2, prendas: 85, defectos: 5.5},
      %{confeccionista: "C03", linea: "L3", dia: 3, prendas: 125, defectos: 3.2},
      %{confeccionista: "C03", linea: "L3", dia: 4, prendas: 70, defectos: 6.0},
      %{confeccionista: "C03", linea: "L1", dia: 5, prendas: 90, defectos: 8.0},
      %{confeccionista: "C03", linea: "L2", dia: 6, prendas: 130, defectos: 2.5},

      # C04 (Carlos Restrepo)
      %{confeccionista: "C04", linea: "L1", dia: 1, prendas: 60, defectos: 1.5},
      %{confeccionista: "C04", linea: "L3", dia: 1, prendas: 65, defectos: 2.0},
      %{confeccionista: "C04", linea: "L1", dia: 2, prendas: 110, defectos: 4.0},
      %{confeccionista: "C04", linea: "L2", dia: 3, prendas: 75, defectos: 3.0},
      %{confeccionista: "C04", linea: "L4", dia: 4, prendas: 120, defectos: 1.0},
      %{confeccionista: "C04", linea: "L1", dia: 5, prendas: 115, defectos: 2.2},
      %{confeccionista: "C04", linea: "L4", dia: 6, prendas: 105, defectos: 3.5},

      # C05 (Diana Morales)
      %{confeccionista: "C05", linea: "L3", dia: 1, prendas: 70, defectos: 11.0},
      %{confeccionista: "C05", linea: "L4", dia: 2, prendas: 85, defectos: 9.0},
      %{confeccionista: "C05", linea: "L2", dia: 3, prendas: 90, defectos: 15.0},
      %{confeccionista: "C05", linea: "L1", dia: 4, prendas: 60, defectos: 6.0},
      %{confeccionista: "C05", linea: "L3", dia: 5, prendas: 95, defectos: 8.5},
      %{confeccionista: "C05", linea: "L4", dia: 6, prendas: 50, defectos: 14.0},

      # C06 (Eduardo López)
      %{confeccionista: "C06", linea: "L4", dia: 1, prendas: 120, defectos: 0.5},
      %{confeccionista: "C06", linea: "L1", dia: 2, prendas: 130, defectos: 1.0},
      %{confeccionista: "C06", linea: "L2", dia: 3, prendas: 70, defectos: 2.0},
      %{confeccionista: "C06", linea: "L4", dia: 3, prendas: 60, defectos: 1.8},
      %{confeccionista: "C06", linea: "L3", dia: 4, prendas: 140, defectos: 0.9},
      %{confeccionista: "C06", linea: "L2", dia: 5, prendas: 135, defectos: 1.1},
      %{confeccionista: "C06", linea: "L1", dia: 6, prendas: 150, defectos: 0.7},

      # C07 (Gloria Jaramillo)
      %{confeccionista: "C07", linea: "L1", dia: 1, prendas: 75, defectos: 6.5},
      %{confeccionista: "C07", linea: "L2", dia: 2, prendas: 80, defectos: 7.0},
      %{confeccionista: "C07", linea: "L3", dia: 3, prendas: 85, defectos: 5.5},
      %{confeccionista: "C07", linea: "L1", dia: 4, prendas: 90, defectos: 6.8},
      %{confeccionista: "C07", linea: "L2", dia: 5, prendas: 70, defectos: 7.5},
      %{confeccionista: "C07", linea: "L4", dia: 6, prendas: 80, defectos: 8.0},

      # C08 (Hernán Ortiz)
      %{confeccionista: "C08", linea: "L2", dia: 1, prendas: 65, defectos: 3.5},
      %{confeccionista: "C08", linea: "L3", dia: 2, prendas: 70, defectos: 4.0},
      %{confeccionista: "C08", linea: "L4", dia: 2, prendas: 60, defectos: 2.8},
      %{confeccionista: "C08", linea: "L1", dia: 3, prendas: 110, defectos: 3.0},
      %{confeccionista: "C08", linea: "L2", dia: 4, prendas: 85, defectos: 4.5},
      %{confeccionista: "C08", linea: "L3", dia: 5, prendas: 90, defectos: 3.8},
      %{confeccionista: "C08", linea: "L4", dia: 6, prendas: 75, defectos: 4.2},

      # C09 (Isabel Quintero)
      %{confeccionista: "C09", linea: "L3", dia: 1, prendas: 90, defectos: 1.2},
      %{confeccionista: "C09", linea: "L4", dia: 1, prendas: 40, defectos: 2.0},
      %{confeccionista: "C09", linea: "L1", dia: 2, prendas: 125, defectos: 1.5},
      %{confeccionista: "C09", linea: "L2", dia: 3, prendas: 80, defectos: 2.2},
      %{confeccionista: "C09", linea: "L3", dia: 4, prendas: 85, defectos: 1.9},
      %{confeccionista: "C09", linea: "L4", dia: 5, prendas: 130, defectos: 0.9},
      %{confeccionista: "C09", linea: "L1", dia: 6, prendas: 140, defectos: 1.1},

      # C10 (Jorge Valencia)
      %{confeccionista: "C10", linea: "L4", dia: 1, prendas: 80, defectos: 5.0},
      %{confeccionista: "C10", linea: "L1", dia: 2, prendas: 85, defectos: 4.8},
      %{confeccionista: "C10", linea: "L2", dia: 3, prendas: 90, defectos: 5.2},
      %{confeccionista: "C10", linea: "L3", dia: 4, prendas: 95, defectos: 4.0},
      %{confeccionista: "C10", linea: "L4", dia: 5, prendas: 100, defectos: 3.5},
      %{confeccionista: "C10", linea: "L2", dia: 6, prendas: 105, defectos: 4.2},

      # Lotes complementarios para asegurar volumen en los 6 días y superar metas
      %{confeccionista: "C02", linea: "L2", dia: 2, prendas: 50, defectos: 2.0},
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 45, defectos: 3.0},
      %{confeccionista: "C04", linea: "L4", dia: 2, prendas: 55, defectos: 2.5},
      %{confeccionista: "C05", linea: "L1", dia: 2, prendas: 40, defectos: 10.0},
      %{confeccionista: "C06", linea: "L3", dia: 2, prendas: 50, defectos: 1.5},
      %{confeccionista: "C07", linea: "L4", dia: 3, prendas: 45, defectos: 6.0},
      %{confeccionista: "C08", linea: "L1", dia: 4, prendas: 50, defectos: 3.0},
      %{confeccionista: "C09", linea: "L2", dia: 4, prendas: 45, defectos: 1.8},
      %{confeccionista: "C10", linea: "L3", dia: 5, prendas: 50, defectos: 4.0},
      %{confeccionista: "C02", linea: "L4", dia: 5, prendas: 40, defectos: 1.5},
      %{confeccionista: "C03", linea: "L3", dia: 5, prendas: 45, defectos: 3.0},
      %{confeccionista: "C04", linea: "L2", dia: 5, prendas: 50, defectos: 2.0},
      %{confeccionista: "C05", linea: "L2", dia: 6, prendas: 55, defectos: 12.0},
      %{confeccionista: "C07", linea: "L3", dia: 6, prendas: 60, defectos: 7.0},
      %{confeccionista: "C08", linea: "L2", dia: 6, prendas: 50, defectos: 3.5},
      %{confeccionista: "C09", linea: "L3", dia: 6, prendas: 45, defectos: 1.0},
      %{confeccionista: "C10", linea: "L1", dia: 6, prendas: 65, defectos: 4.0},

      # --- 10 LOTES INVÁLIDOS (2 por cada motivo de rechazo en orden) ---

      # 1. :confeccionista_desconocido (2 casos)
      %{confeccionista: "C99", linea: "L1", dia: 1, prendas: 50, defectos: 2.0},
      %{confeccionista: "C88", linea: "L2", dia: 3, prendas: 70, defectos: 1.5},

      # 2. :linea_desconocida (2 casos)
      %{confeccionista: "C01", linea: "L9", dia: 2, prendas: 60, defectos: 3.0},
      %{confeccionista: "C02", linea: "LX", dia: 4, prendas: 80, defectos: 2.5},

      # 3. :dia_invalido (2 casos: día 0 y día 7)
      %{confeccionista: "C03", linea: "L1", dia: 0, prendas: 75, defectos: 1.0},
      %{confeccionista: "C04", linea: "L2", dia: 7, prendas: 65, defectos: 4.0},

      # 4. :prendas_fuera_de_rango (2 casos: 0 prendas y 185 prendas)
      %{confeccionista: "C05", linea: "L3", dia: 2, prendas: 0, defectos: 2.0},
      %{confeccionista: "C06", linea: "L4", dia: 5, prendas: 185, defectos: 1.0},

      # 5. :porcentaje_invalido (2 casos: porcentaje negativo y mayor a 100)
      %{confeccionista: "C07", linea: "L1", dia: 3, prendas: 50, defectos: -1.5},
      %{confeccionista: "C08", linea: "L2", dia: 4, prendas: 70, defectos: 105.0}
    ]
  end
end
