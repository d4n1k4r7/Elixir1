defmodule Validacion do
  @moduledoc """
  Valida los lotes de producción del taller de confecciones
  antes de utilizarlos en los cálculos del programa.

  La validación se realiza mediante cinco reglas, en el orden
  establecido por el enunciado del proyecto:

  1. Verificar que el confeccionista exista.
  2. Verificar que la línea de producción exista.
  3. Verificar que el día sea un entero entre 1 y 6.
  4. Verificar que la cantidad de prendas sea un entero entre 1 y 180.
  5. Verificar que el porcentaje de defectos sea un número entre 0 y 100.

  La validación devuelve una tupla {:ok, lote} cuando el lote
  cumple todas las reglas, o {:error, motivo} cuando alguna
  regla no se cumple.

  Los lotes rechazados no participan en los cálculos posteriores
  del programa, pero son utilizados en el reporte R1.
  """

@doc """
  Valida un lote aplicando las cinco reglas de validación
  en el orden establecido.
  """
def validar_lote(lote, confeccionistas, lineas) do
  with {:ok, lote} <- validar_confeccionista(lote, confeccionistas),
       {:ok, lote} <- validar_linea(lote, lineas),
       {:ok, lote} <- validar_dia(lote),
       {:ok, lote} <- validar_prendas(lote),
       {:ok, lote} <- validar_defectos(lote) do
    {:ok, lote}
  else
    {:error, motivo} -> {:error, motivo}
  end


end



defp validar_confeccionista(lote, confeccionistas)do
  codigo=lote.confeccionista

 case Enum.find(confeccionistas,&(&1.codigo==codigo)) do nil ->

    {:error,:confeccionista_desconocido}
  _confeccionista ->
    {:ok,lote}

  end
end

defp validar_linea(lote, lineas) do
  id=lote.linea
  case Enum.find(lineas,&(&1.id==id)) do nil ->

    {:error,:linea_desconocida}

  _linea ->
    {:ok,lote}

   end

end

defp validar_dia(lote) do
 dia=lote.dia
 if is_integer(dia) and dia >= 1 and dia <=6 do
   {:ok,lote}
 else
   {:error,:dia_invalido}
 end
end

defp validar_prendas(lote) do
  prenda=lote.prendas
  if is_integer(prenda) and prenda >= 1 and prenda <= 180 do
    {:ok,lote}
  else
    {:error,:prendas_fuera_de_rango}
  end
end

defp validar_defectos(lote) do
  porcentaje=lote.defectos
  if is_number(porcentaje) and porcentaje >= 0 and porcentaje <= 100 do
    {:ok,lote}
  else
    {:error,:porcentaje_invalido}
  end
end

end
