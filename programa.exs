defmodule Programa do

  @moduledoc """
  Punto de entrada principal del sistema de liquidación
  y reportes del taller de confecciones.

  Coordina los módulos Datos, Validacion, Liquidacion,
  Reportes y Util.
  """

  @doc """
  Punto de entrada principal del programa.
  """
  def main do
    confeccionistas = Datos.confeccionistas()
    lineas = Datos.lineas()
    lotes = Datos.lotes()

    resultados = validar_lotes(lotes, confeccionistas, lineas)

    lotes_validos =
      resultados
      |> Enum.filter(fn {_lote, resultado} ->
        match?({:ok, _}, resultado)
      end)
      |> Enum.map(fn {_lote, {:ok, lote}} ->
        lote
      end)

    resultados =
      procesar_lote_adicional(
        resultados,
        lotes_validos,
        confeccionistas,
        lineas
      )

    lotes_validos =
      resultados
      |> Enum.filter(fn {_lote, resultado} ->
        match?({:ok, _}, resultado)
      end)
      |> Enum.map(fn {_lote, {:ok, lote}} ->
        lote
      end)

    liquidaciones =
      Liquidacion.liquidar_todos(
        confeccionistas,
        lotes_validos
      )

    ejecutar_reportes(
      resultados,
      lotes_validos,
      liquidaciones,
      confeccionistas,
      lineas
    )

    ejecutar_investigacion(
      liquidaciones,
      lotes_validos
    )

    ejecutar_comprobante(
      lotes_validos,
      confeccionistas,
      liquidaciones
    )
  end

  @doc """
  Valida todos los lotes y conserva tanto los válidos
  como los rechazados para generar posteriormente R1.
  """
  def validar_lotes(lotes, confeccionistas, lineas) do
    Enum.map(lotes, fn lote ->
      {
        lote,
        Validacion.validar_lote(
          lote,
          confeccionistas,
          lineas
        )
      }
    end)
  end

  @doc """
  Procesa el lote adicional solicitado al usuario.

  Si el usuario lo omite, conserva los datos originales.
  Si el formato es incorrecto, informa el error y continúa.
  Si el formato es correcto, aplica las cinco reglas de validación.
  """
  def procesar_lote_adicional(
        resultados,
        _lotes_validos,
        confeccionistas,
        lineas
      ) do

    case Util.leer_lote_adicional() do
      :omitido ->
        IO.puts("\nLote adicional omitido.")
        resultados

      {:error, :formato_invalido} ->
        IO.puts(
          "\nEl lote adicional tiene un formato inválido. No se agregó."
        )

        resultados

      {:ok, lote} ->
        resultado =
          Validacion.validar_lote(
            lote,
            confeccionistas,
            lineas
          )

        case resultado do
          {:ok, lote} ->
            IO.puts("\nLote adicional agregado correctamente.")

            resultados ++ [{lote, {:ok, lote}}]

          {:error, motivo} ->
            IO.puts(
              "\nEl lote adicional fue rechazado: #{inspect(motivo)}."
            )

            resultados ++ [{lote, {:error, motivo}}]
        end
    end
  end

  @doc """
  Ejecuta e imprime los ocho reportes principales del parcial.
  """
  def ejecutar_reportes(
        resultados,
        lotes_validos,
        liquidaciones,
        confeccionistas,
        lineas
      ) do

    # R1
    Util.mostrar_titulo("REPORTE R1: LOTES RECHAZADOS")

    r1 = Reportes.reporte_1(resultados)

    if Enum.empty?(r1.rechazados) do
      IO.puts("No hubo lotes rechazados.")
    else
      IO.puts("Lotes rechazados:")

      Enum.each(
        Enum.reverse(r1.rechazados),
        fn {lote, motivo} ->
          IO.puts(
            "  #{inspect(lote)} -> #{inspect(motivo)}"
          )
        end
      )
    end

    IO.puts("\nCantidad de rechazos por motivo:")

    Enum.each(
      r1.cantidades,
      fn {motivo, cantidad} ->
        IO.puts(
          "  #{inspect(motivo)}: #{cantidad}"
        )
      end
    )

    # R2
    Util.mostrar_titulo(
      "REPORTE R2: PRODUCCIÓN POR LÍNEA"
    )

    r2 = Reportes.reporte_2(lotes_validos, lineas)

    Enum.each(r2, fn linea ->
      IO.puts(
        "  #{linea.id} - #{linea.nombre}: " <>
          "#{linea.prendas} prendas, " <>
          "#{linea.puestos} puestos, " <>
          "#{Util.formato_decimal(linea.productividad)} prendas/puesto"
      )
    end)

    # R3
    Util.mostrar_titulo(
      "REPORTE R3: PRODUCCIÓN DIARIA"
    )

    r3 = Reportes.reporte_3(lotes_validos)

    Enum.each(
      r3.produccion_diaria,
      fn dia ->
        estado =
          if dia.meta_alcanzada do
            "META ALCANZADA"
          else
            "META NO ALCANZADA"
          end

        IO.puts(
          "  Día #{dia.dia}: #{dia.prendas} prendas - #{estado}"
        )
      end
    )

    IO.puts(
      "\n¿Meta alcanzada todos los días?: " <>
        "#{r3.resumen.todos_los_dias}"
    )

    IO.puts(
      "¿Meta alcanzada al menos un día?: " <>
        "#{r3.resumen.al_menos_un_dia}"
    )

    # R4
    Util.mostrar_titulo(
      "REPORTE R4: LIQUIDACIÓN DE CONFECCIONISTAS"
    )

    r4 = Reportes.reporte_4(liquidaciones)

    Enum.each(r4, fn liquidacion ->
      IO.puts(
        "\n  Posición #{liquidacion.posicion}: " <>
          "#{liquidacion.codigo} - #{liquidacion.nombre}"
      )

      IO.puts(
        "    Prendas: #{liquidacion.prendas}"
      )

      IO.puts(
        "    Valor de lotes: " <>
          "#{Util.formato_moneda(liquidacion.valor_lotes)}"
      )

      IO.puts(
        "    Bonificaciones: " <>
          "#{Util.formato_moneda(liquidacion.bonificaciones)}"
      )

      IO.puts(
        "    Alquiler: " <>
          "#{Util.formato_moneda(liquidacion.alquiler)}"
      )

      IO.puts(
        "    Neto: " <>
          "#{Util.formato_moneda(liquidacion.neto)}"
      )
    end)

    # R5
    Util.mostrar_titulo(
      "REPORTE R5: MAYOR PRODUCCIÓN DIARIA"
    )

    r5 =
      Reportes.reporte_5(
        lotes_validos,
        confeccionistas
      )

    Enum.each(r5.dias, fn dia ->
      if Enum.empty?(dia.ganadores) do
        IO.puts(
          "  Día #{dia.dia}: sin lotes válidos."
        )
      else
        IO.puts(
          "  Día #{dia.dia}: #{dia.prendas} prendas"
        )

        Enum.each(
          dia.ganadores,
          fn ganador ->
            IO.puts(
              "    - #{ganador.codigo} - " <>
                "#{ganador.nombre}"
            )
          end
        )
      end
    end)

    if Enum.empty?(r5.lideres) do
      IO.puts(
        "\nNo hubo confeccionistas con primeros lugares."
      )
    else
      IO.puts(
        "\nConfeccionistas que ocuparon el primer lugar " <>
          "más días:"
      )

      Enum.each(
        r5.lideres,
        fn {codigo, dias} ->
          IO.puts(
            "  #{codigo}: #{dias} días"
          )
        end
      )
    end

    # R6
    Util.mostrar_titulo(
      "REPORTE R6: MEJOR CALIDAD"
    )

    case Reportes.reporte_6(
           lotes_validos,
           confeccionistas
         ) do

      nil ->
        IO.puts(
          "No hay confeccionistas con al menos tres lotes válidos."
        )

      resultado ->
        IO.puts(
          "Confeccionista: #{resultado.codigo} - " <>
            "#{resultado.nombre}"
        )

        IO.puts(
          "Lotes válidos: #{resultado.lotes_validos}"
        )

        IO.puts(
          "Prendas: #{resultado.prendas}"
        )

        IO.puts(
          "Porcentaje ponderado: " <>
            "#{Util.formato_decimal(resultado.porcentaje_ponderado)}%"
        )
    end

    # R7
    Util.mostrar_titulo(
      "REPORTE R7: TOTAL PAGADO"
    )

    r7 = Reportes.reporte_7(liquidaciones)

    IO.puts(
      "Total pagado: " <>
        "#{Util.formato_moneda(r7.total_pagado)}"
    )

    IO.puts(
      "Total de prendas válidas: #{r7.total_prendas}"
    )

    if is_nil(r7.promedio_por_prenda) do
      IO.puts(
        "Promedio por prenda: no puede calcularse."
      )
    else
      IO.puts(
        "Promedio por prenda: " <>
          "#{Util.formato_moneda(r7.promedio_por_prenda)}"
      )
    end

    # R8
    Util.mostrar_titulo(
      "REPORTE R8: CONFECCIONISTAS EN TODAS LAS LÍNEAS"
    )

    r8 =
      Reportes.reporte_8(
        lotes_validos,
        confeccionistas,
        lineas
      )

    if Enum.empty?(r8) do
      IO.puts(
        "No hay confeccionistas que hayan trabajado " <>
          "en todas las líneas."
      )
    else
      Enum.each(r8, fn confeccionista ->
        IO.puts(
          "  #{confeccionista.codigo} - " <>
            "#{confeccionista.nombre}"
        )
      end)
    end
  end

  defp ejecutar_investigacion(liquidaciones, lotes_validos) do
    # C.1: Llamadas obligatorias del ranking
    IO.puts("\n========================================================")
    IO.puts("PARTE C.1: RANKING CON KEYWORD LISTS")
    IO.puts("========================================================")

    IO.puts("\nLlamada 1: Reportes.ranking(liquidaciones, [])")
    res1 = Reportes.ranking(liquidaciones, [])
    Enum.each(Enum.take(res1, 3), fn l -> IO.puts("  - #{l.codigo} (#{l.nombre}): #{Util.formato_moneda(l.neto)}") end)

    IO.puts("\nLlamada 2: Reportes.ranking(liquidaciones, campo: :prendas, limite: 3)")
    res2 = Reportes.ranking(liquidaciones, campo: :prendas, limite: 3)
    Enum.each(res2, fn l -> IO.puts("  - #{l.codigo} (#{l.nombre}): #{l.prendas} prendas") end)

    IO.puts("\nLlamada 3: Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto)")
    res3 = Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto)
    Enum.each(Enum.take(res3, 3), fn l -> IO.puts("  - #{l.codigo} (#{l.nombre}): #{Util.formato_moneda(l.valor_lotes)}") end)

    # C.2: Combinación con taller aliado
    IO.puts("\n========================================================")
    IO.puts("PARTE C.2: COMBINACIÓN DE PRODUCCIÓN CON TALLER ALIADO")
    IO.puts("========================================================")
    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}
    r3 = Reportes.calcular_r3(lotes_validos)
    taller_propio = r3.mapa_produccion

    combinado = Reportes.combinar_produccion(taller_propio, taller_aliado)

    IO.puts("Producción Taller Propio (R3) : #{inspect(taller_propio)}")
    IO.puts("Producción Taller Aliado      : #{inspect(taller_aliado)}")
    IO.puts("Producción Combinada          : #{inspect(combinado)}")

    # C.3: Medición de tiempos de ejecución
    IO.puts("\n========================================================")
    IO.puts("PARTE C.3: MEDICIONES CON :timer.tc/1 (3 REPETICIONES)")
    IO.puts("========================================================")

    IO.puts("\n1. Búsqueda de 1.000 códigos en 100.000 registros (Lista vs. Mapa):")
    Enum.each(1..3, fn corrida ->
      res = Reportes.benchmark_busqueda()
      IO.puts("  Corrida #{corrida}: Lista = #{:erlang.float_to_binary(res.lista_ms, decimals: 2)} ms | Mapa = #{:erlang.float_to_binary(res.mapa_ms, decimals: 3)} ms")
    end)

    IO.puts("\n2. Construcción de lista de 20.000 elementos (++ vs. [elem | acc]):")
    Enum.each(1..3, fn corrida ->
      res = Reportes.benchmark_construccion_lista()
      IO.puts("  Corrida #{corrida}: Final (++) = #{:erlang.float_to_binary(res.concatenar_ms, decimals: 2)} ms | Inicio ([x|acc]) = #{:erlang.float_to_binary(res.prepend_ms, decimals: 3)} ms")
    end)
  end

  @doc """
  Genera el comprobante individual solicitado al usuario.

  Muestra únicamente los días en los que el confeccionista
  tiene lotes válidos.
  """
  def ejecutar_comprobante(
        lotes_validos,
        confeccionistas,
        liquidaciones
      ) do

    codigo = Util.leer_codigo_confeccionista()

    case Enum.find(
           confeccionistas,
           fn confeccionista ->
             confeccionista.codigo == codigo
           end
         ) do

      nil ->
        IO.puts(
          "\nEl código #{codigo} no existe."
        )

      confeccionista ->
        liquidacion =
          Enum.find(
            liquidaciones,
            fn liquidacion ->
              liquidacion.codigo == codigo
            end
          )

        lotes_confeccionista =
          Enum.filter(
            lotes_validos,
            fn lote ->
              lote.confeccionista == codigo
            end
          )

        Util.mostrar_titulo(
          "COMPROBANTE INDIVIDUAL"
        )

        IO.puts(
          "Código: #{confeccionista.codigo}"
        )

        IO.puts(
          "Nombre: #{confeccionista.nombre}"
        )

        IO.puts("\nDetalle por día:")

        lotes_confeccionista
        |> Enum.group_by(& &1.dia)
        |> Enum.sort_by(fn {dia, _lotes} -> dia end)
        |> Enum.each(fn {dia, lotes} ->
          prendas =
            Enum.sum(
              Enum.map(
                lotes,
                fn lote ->
                  lote.prendas
                end
              )
            )

          valor_lotes =
            Enum.sum(
              Enum.map(
                lotes,
                fn lote ->
                  Liquidacion.valor_lote(lote)
                end
              )
            )

          bonificacion =
            Liquidacion.bonificacion_productividad(
              prendas
            )

          IO.puts("\n  Día #{dia}")
          IO.puts("    Prendas: #{prendas}")

          IO.puts(
            "    Valor de lotes: " <>
              "#{Util.formato_moneda(valor_lotes)}"
          )

          IO.puts(
            "    Bonificación: " <>
              "#{Util.formato_moneda(bonificacion)}"
          )
        end)

        IO.puts(
          "\nSuma de lotes: " <>
            "#{Util.formato_moneda(liquidacion.valor_lotes)}"
        )

        IO.puts(
          "Suma de bonificaciones: " <>
            "#{Util.formato_moneda(liquidacion.bonificaciones)}"
        )

        IO.puts(
          "Descuento por alquiler: " <>
            "#{Util.formato_moneda(liquidacion.alquiler)}"
        )

        IO.puts(
          "Neto: " <>
            "#{Util.formato_moneda(liquidacion.neto)}"
        )
    end
  end

end

Programa.main()
