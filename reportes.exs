defmodule Reportes do

  @moduledoc """
  Genera los reportes del taller de confecciones
  y las investigaciones del proyecto.
  """

  @doc """
  Genera el reporte R1, que contiene los lotes rechazados,
  los motivos de rechazo y la cantidad de rechazos por motivo.
  """
  def reporte_1(resultados) do
    Enum.reduce(resultados, %{rechazados: [], cantidades: %{}}, fn {lote, resultado}, acumulador ->
      case resultado do
        {:ok, _lote} ->
          acumulador

        {:error, motivo} ->
          rechazados = [{lote, motivo} | acumulador.rechazados]

          cantidades =
            Map.update(acumulador.cantidades, motivo, 1, &(&1 + 1))

          %{
            rechazados: rechazados,
            cantidades: cantidades
          }
      end
    end)
  end

  @doc """
  Genera el reporte R2 con las prendas producidas por cada línea
  y la productividad semanal en prendas por puesto.

  Las líneas sin lotes válidos aparecen con cero prendas.
  El resultado se ordena de mayor a menor productividad.
  """
  def reporte_2(lotes_validos, lineas) do
    lineas
    |> Enum.map(fn linea ->
      prendas = prendas_por_linea(lotes_validos, linea.id)

      productividad = prendas / linea.puestos

      %{
        id: linea.id,
        nombre: linea.nombre,
        prendas: prendas,
        puestos: linea.puestos,
        productividad: productividad
      }
    end)
    |> Enum.sort_by(& &1.productividad, :desc)
  end

  defp prendas_por_linea(lotes_validos, id_linea) do
    lotes_validos
    |> Enum.filter(fn lote -> lote.linea == id_linea end)
    |> Enum.map(fn lote -> lote.prendas end)
    |> Enum.sum()
  end

  @doc """
  Genera el reporte R3 con las prendas producidas por el taller
  en cada uno de los seis días.

  Para cada día indica la cantidad de prendas producidas y si se
  alcanzó la meta de 600 prendas.

  Los días sin lotes válidos aparecen con cero prendas.
  """
  def reporte_3(lotes_validos) do
    resultado = calcular_r3(lotes_validos)
    %{ produccion_diaria: resultado.produccion_diaria, resumen: resultado.resumen }
  end
   @doc """
   Calcula los datos completos del reporte R3
   Además de los datos que se muestran en R3, conserva un mapa de producción diaria que será utilizado en la investigación C.2
   para combinar la producción con la de un taller aliado.
   """
   def calcular_r3(lotes_validos) do
     produccion_diaria = Enum.map(1..6, fn dia -> prendas =

       prendas_por_dia(lotes_validos, dia)
       %{ dia: dia, prendas: prendas, meta_alcanzada: prendas >= 600 }
      end)

        mapa_produccion = Map.new( produccion_diaria, fn resultado ->
           {resultado.dia, resultado.prendas}
          end )

         %{ produccion_diaria: produccion_diaria,
          mapa_produccion: mapa_produccion,
           resumen: %{ todos_los_dias: Enum.all?( produccion_diaria, & &1.meta_alcanzada ),
           al_menos_un_dia: Enum.any?( produccion_diaria, & &1.meta_alcanzada ) } }
 end



  defp prendas_por_dia(lotes_validos, dia) do
    lotes_validos
    |> Enum.filter(fn lote -> lote.dia == dia end)
    |> Enum.map(fn lote -> lote.prendas end)
    |> Enum.sum()
  end

  @doc """
  Genera el reporte R4.

  Lista todos los confeccionistas ordenados de mayor a menor
  según el pago neto.
  """
  def reporte_4(liquidaciones) do
    liquidaciones
    |> Enum.sort_by(& &1.neto, :desc)
    |> Enum.with_index(1)
    |> Enum.map(fn {liquidacion, posicion} ->
      Map.put(liquidacion, :posicion, posicion)
    end)
  end

  @doc """
  Genera el reporte R5.

  Obtiene el confeccionista que produjo más prendas cada día.
  Si existe empate, aparecen todos.
  """
  def reporte_5(lotes_validos, confeccionistas) do
    resultados =
      Enum.map(1..6, fn dia ->
        lotes_dia =
          Enum.filter(lotes_validos, fn lote ->
            lote.dia == dia
          end)

        if Enum.empty?(lotes_dia) do
          %{
            dia: dia,
            ganadores: [],
            prendas: 0
          }
        else
          produccion =
            Enum.reduce(lotes_dia, %{}, fn lote, acc ->
              Map.update(
                acc,
                lote.confeccionista,
                lote.prendas,
                &(&1 + lote.prendas)
              )
            end)

          maximo =
            produccion
            |> Map.values()
            |> Enum.max()

          ganadores =
            produccion
            |> Enum.filter(fn {_codigo, prendas} ->
              prendas == maximo
            end)
            |> Enum.map(fn {codigo, prendas} ->
              confeccionista =
                Enum.find(confeccionistas, fn c ->
                  c.codigo == codigo
                end)

              %{
                codigo: codigo,
                nombre: confeccionista.nombre,
                prendas: prendas
              }
            end)

          %{
            dia: dia,
            ganadores: ganadores,
            prendas: maximo
          }
        end
      end)

    conteo_primeros =
      Enum.reduce(resultados, %{}, fn resultado, acc ->
        Enum.reduce(resultado.ganadores, acc, fn ganador, acumulado ->
          Map.update(
            acumulado,
            ganador.codigo,
            1,
            &(&1 + 1)
          )
        end)
      end)

    lideres =
      if map_size(conteo_primeros) == 0 do
        []
      else
        maximo =
          conteo_primeros
          |> Map.values()
          |> Enum.max()

        Enum.filter(conteo_primeros, fn {_codigo, dias} ->
          dias == maximo
        end)
      end

    %{
      dias: resultados,
      lideres: lideres
    }
  end

  @doc """
  Genera el reporte R6 con el confeccionista que tiene el menor
  porcentaje de defectos ponderado por prendas.

  Solo participan los confeccionistas que tengan al menos
  tres lotes válidos.
  """
  def reporte_6(lotes_validos, confeccionistas) do
    candidatos =
      Enum.map(confeccionistas, fn confeccionista ->
        lotes_confeccionista =
          Enum.filter(lotes_validos, fn lote ->
            lote.confeccionista == confeccionista.codigo
          end)

        cantidad_lotes = Enum.count(lotes_confeccionista)

        if cantidad_lotes >= 3 do
          prendas_totales =
            lotes_confeccionista
            |> Enum.map(fn lote -> lote.prendas end)
            |> Enum.sum()

          defectos_ponderados =
            lotes_confeccionista
            |> Enum.map(fn lote -> lote.defectos * lote.prendas end)
            |> Enum.sum()

          porcentaje_ponderado = defectos_ponderados / prendas_totales

          %{
            codigo: confeccionista.codigo,
            nombre: confeccionista.nombre,
            lotes_validos: cantidad_lotes,
            prendas: prendas_totales,
            porcentaje_ponderado: porcentaje_ponderado
          }
        else
          nil
        end
      end)
      |> Enum.filter(fn candidato -> candidato != nil end)

    case candidatos do
      [] ->
        nil

      _ ->
        Enum.min_by(candidatos, fn candidato ->
          candidato.porcentaje_ponderado
        end)
    end
  end

  @doc """
  Genera el reporte R7.

  Calcula el total pagado, el total de prendas y el promedio
  pagado por prenda.
  """
  def reporte_7(liquidaciones) do
    total_pagado =
      liquidaciones
      |> Enum.map(& &1.neto)
      |> Enum.sum()

    total_prendas =
      liquidaciones
      |> Enum.map(& &1.prendas)
      |> Enum.sum()

    promedio =
      if total_prendas > 0 do
        total_pagado / total_prendas
      else
        nil
      end

    %{
      total_pagado: total_pagado,
      total_prendas: total_prendas,
      promedio_por_prenda: promedio
    }
  end

  @doc """
  Genera el reporte R8.

  Muestra los confeccionistas que tienen al menos
  un lote válido en todas las líneas.
  """
  def reporte_8(lotes_validos, confeccionistas, lineas) do
    total_lineas = Enum.count(lineas)

    confeccionistas
    |> Enum.filter(fn confeccionista ->
      lineas_trabajadas =
        lotes_validos
        |> Enum.filter(fn lote ->
          lote.confeccionista == confeccionista.codigo
        end)
        |> Enum.map(fn lote ->
          lote.linea
        end)
        |> Enum.uniq()
        |> Enum.count()

      lineas_trabajadas == total_lineas
    end)
    |> Enum.map(fn confeccionista ->
      %{
        codigo: confeccionista.codigo,
        nombre: confeccionista.nombre
      }
    end)
  end

  @doc """
  C.1: Ranking de confeccionistas según opciones pasadas
  en una Keyword List.

  Opciones:
  - campo: :neto (default) | :prendas | :bruto
  - orden: :desc (default) | :asc
  - limite: entero positivo | nil (default: todos)
  """
  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, nil)

    clave_selector =
      case campo do
        :neto -> & &1.neto
        :prendas -> & &1.prendas
        :bruto -> & &1.valor_lotes
        _ -> & &1.neto
      end

    ordenado =
      case orden do
        :asc -> Enum.sort_by(liquidaciones, clave_selector, :asc)
        _ -> Enum.sort_by(liquidaciones, clave_selector, :desc)
      end

    if is_integer(limite) and limite > 0 do
      Enum.take(ordenado, limite)
    else
      ordenado
    end
  end

  @doc """
  C.2: Combina la producción de dos talleres sumando las prendas
  de los días comunes mediante Map.merge/3.
  """
  def combinar_produccion(taller1, taller2) do
    Map.merge(taller1, taller2, fn _dia, prendas1, prendas2 ->
      prendas1 + prendas2
    end)
  end

  @doc """
  C.3 (Benchmark 1): Compara la búsqueda de códigos en una lista
  mediante Enum.find/2 contra un mapa indexado mediante Map.get/2.
  """
  def benchmark_busqueda do
    total_elementos = 100_000
    total_muestras = 1_000

    lista =
      Enum.map(1..total_elementos, fn i ->
        %{codigo: "C_#{i}", nombre: "Confeccionista #{i}"}
      end)

    mapa = Map.new(lista, fn confeccionista ->
      {confeccionista.codigo, confeccionista}
    end)

    codigos =
      Enum.map(1..total_muestras, fn _ ->
        "C_#{:rand.uniform(total_elementos)}"
      end)

    {t_lista, _} =
      :timer.tc(fn ->
        Enum.each(codigos, fn codigo ->
          Enum.find(lista, fn confeccionista ->
            confeccionista.codigo == codigo
          end)
        end)
      end)

    {t_mapa, _} =
      :timer.tc(fn ->
        Enum.each(codigos, fn codigo ->
          Map.get(mapa, codigo)
        end)
      end)

    %{
      lista_ms: t_lista / 1000.0,
      mapa_ms: t_mapa / 1000.0
    }
  end

  @doc """
  C.3 (Benchmark 2): Compara la construcción de una lista
  usando ++ contra [elemento | acumulador].
  """
  def benchmark_construccion_lista do
    n = 20_000

    {t_concatenar, _} =
      :timer.tc(fn ->
        Enum.reduce(1..n, [], fn x, acc ->
          acc ++ [x]
        end)
      end)

    {t_prepend, _} =
      :timer.tc(fn ->
        1..n
        |> Enum.reduce([], fn x, acc -> [x | acc] end)
        |> Enum.reverse()
      end)

    %{
      concatenar_ms: t_concatenar / 1000.0,
      prepend_ms: t_prepend / 1000.0
    }
  end

end
