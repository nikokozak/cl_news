defmodule Lector.DBInterface do
  require Postgrex

  @hostname "localhost"
  @username "lector_chile"
  @database "lector"

  @doc """
  Retrieves all entries from the 'noticias' table.
  Maps column names onto each row value, returning an array of
  Maps.
  """
  def get_all do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, s.seccion, noticia_id, titular, bajada, autor, imagen_url, cuerpo, to_char(fecha, 'DD-MM-YYYY') as \"fecha\"
        FROM noticias 
        JOIN medios as m USING (medio_id) 
        JOIN secciones as s USING (seccion_id)
        ORDER BY fecha DESC"

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, query, [])

    IO.inspect(Enum.map(rows, fn row -> row_reducer(row, columns) end))
  end

  @doc """
  Retrieves all entries from the 'noticias' table matching a given 'seccion'.
  Maps column names onto each row value, returning an array of Maps.
  """
  def get_seccion(seccion) do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, s.seccion, noticia_id, titular, bajada, autor, imagen_url, cuerpo, to_char(fecha, 'DD-MM-YYYY') as \"fecha\"
        FROM noticias
        JOIN medios as m USING (medio_id)
        JOIN secciones as s USING (seccion_id)
        WHERE s.seccion = $1
        ORDER BY fecha DESC"

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, query, [seccion])

    IO.inspect(Enum.map(rows, fn row -> row_reducer(row, columns) end))
  end

  def get_noticia(id) do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, s.seccion, noticia_id, titular, bajada, autor, imagen_url, cuerpo, to_char(fecha, 'DD-MM-YYYY') as \"fecha\"
    FROM noticias
    JOIN medios as m USING (medio_id)
    JOIN secciones as s USING (seccion_id)
    WHERE noticia_id = $1"

    %{columns: columns,
      rows: rows} = Postgrex.query!(pid, query, [id])

    IO.inspect(Enum.map(rows, fn row -> row_reducer(row, columns) end))
  end

  defp connect do
    Postgrex.start_link(hostname: @hostname, username: @username, database: @database)
  end

  defp row_reducer(row, cols) do
    row
    |> Enum.with_index
    |> Enum.reduce(%{}, fn({el, index}, acc) -> 
      Map.put(acc, Enum.at(cols, index), el)
    end)
  end
  
end
