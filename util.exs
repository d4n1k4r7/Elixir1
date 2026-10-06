defmodule Util do

  @moduledoc """
  Contiene funciones auxiliares reutilizables para la interacción
  con el usuario y la presentación de resultados del programa.
  """

  @doc """
  Formatea un valor monetario con dos decimales.

  Evita la notación científica y agrega el símbolo de pesos.
  """
  def formato_moneda(valor) do
    "$#{:erlang.float_to_binary(valor / 1, decimals: 2)}"
  end

  @doc """
  Formatea un número decimal con dos decimales.
  """
  def formato_decimal(valor) do
    :erlang.float_to_binary(valor / 1, decimals: 2)
  end

  @doc """
  Solicita al usuario un lote adicional.

  El lote debe tener el formato:

  confeccionista;linea;dia;prendas;defectos

  Si el usuario presiona Enter, se devuelve :omitido.

  Si el formato no es válido, devuelve:
  {:error, :formato_invalido}

  Si el formato es correcto, devuelve:
  {:ok, lote}
  """
  def leer_lote_adicional do
    IO.gets(
      "Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos)\no Enter para omitir: "
    )
    |> String.trim()
    |> procesar_lote_adicional()
  end

  @doc """
  Solicita el código de un confeccionista para generar
  el comprobante individual.
  """
  def leer_codigo_confeccionista do
    IO.gets(
      "\nIngrese el código del confeccionista para el comprobante individual: "
    )
    |> String.trim()
    |> String.upcase()
  end

  @doc """
  Convierte una cadena con los datos del lote adicional
  en un mapa cuando todos los campos tienen el formato correcto.
  """
  def procesar_lote_adicional("") do
    :omitido
  end

  def procesar_lote_adicional(cadena) do
    campos = String.split(cadena, ";")

    if length(campos) != 5 do
      {:error, :formato_invalido}
    else
      convertir_lote(campos)
    end
  end

  defp convertir_lote([
         confeccionista,
         linea,
         dia,
         prendas,
         defectos
       ]) do
    with {:ok, dia} <- convertir_entero(dia),
         {:ok, prendas} <- convertir_entero(prendas),
         {:ok, defectos} <- convertir_numero(defectos) do

      {:ok,
       %{
         confeccionista: String.trim(confeccionista),
         linea: String.trim(linea),
         dia: dia,
         prendas: prendas,
         defectos: defectos
       }}
    else
      :error ->
        {:error, :formato_invalido}
    end
  end

  defp convertir_entero(valor) do
    valor = String.trim(valor)

    case Integer.parse(valor) do
      {entero, ""} ->
        {:ok, entero}

      _ ->
        :error
    end
  end

  defp convertir_numero(valor) do
    valor = String.trim(valor)

    case Float.parse(valor) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Integer.parse(valor) do
          {numero, ""} ->
            {:ok, numero}

          _ ->
            :error
        end
    end
  end

  @doc """
  Muestra un título de sección en la consola.
  """
  def mostrar_titulo(titulo) do
    IO.puts("\n========================================================")
    IO.puts(titulo)
    IO.puts("========================================================")
  end

  @doc """
  Muestra un mensaje sencillo en la consola.
  """
  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

end
