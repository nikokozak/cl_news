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
  def get_all(offset \\ 0, limit \\ false) do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, m.std as medio_std, s.nombre as seccion, s.std as seccion_std, noticia_id, titular, bajada, autor, imagen_url, cuerpo, fecha, to_char(fecha, 'DD-MM-YYYY') as fecha_short, count(*) over() as full_count
        FROM noticias 
        JOIN medios as m USING (medio_id) 
        JOIN secciones as s USING (seccion_id)
        ORDER BY fecha DESC
        OFFSET $1"

    query = if limit != false, do: query <> " LIMIT $2", else: query
    params = if limit != false, do: [offset, limit], else: [offset]

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, query, params)

    disconnect(pid)

    format_rows(rows, columns)
  end

  @doc """
  Retrieves all entries from the 'noticias' table matching a given 'seccion'.
  Maps column names onto each row value, returning an array of Maps.
  """
  def get_seccion(seccion, offset \\ 0, limit \\ false) do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, m.std as medio_std, s.nombre as seccion, s.std as seccion_std, noticia_id, titular, bajada, autor, imagen_url, cuerpo, fecha, to_char(fecha, 'DD-MM-YYYY') as fecha_short, count(*) over() as full_count 
        FROM noticias
        JOIN medios as m USING (medio_id)
        JOIN secciones as s USING (seccion_id)
        WHERE s.std = $1
        ORDER BY fecha DESC
        OFFSET $2"

    query = if limit != false, do: query <> " LIMIT $3", else: query
    params = if limit != false, do: [seccion, offset, limit], else: [seccion, offset]

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, query, params)

    disconnect(pid)

    format_rows(rows, columns)
  end

  def get_noticia(id) do
    {:ok, pid} = connect()

    query = "SELECT m.nombre as medio, m.std as medio_std, s.nombre as seccion, s.std as seccion_std, noticia_id, titular, bajada, autor, imagen_url, cuerpo, to_char(fecha, 'DD-MM-YYYY') as \"fecha\"
    FROM noticias
    JOIN medios as m USING (medio_id)
    JOIN secciones as s USING (seccion_id)
    WHERE noticia_id = $1"

    params = [id]

    %{columns: columns,
      rows: rows} = Postgrex.query!(pid, query, params)

    disconnect(pid)

    format_rows(rows, columns)
  end

  defp connect do
    Postgrex.start_link(hostname: @hostname, username: @username, database: @database)
  end

  def disconnect(pid) do
    GenServer.stop(pid)
  end

  defp format_rows(rows, columns, inspect \\ false) do
    Enum.map(rows, fn row -> row_reducer(row, columns) end)
    |> inspect_format(inspect)
  end

  defp inspect_format(mapped_rows, false), do: mapped_rows
  defp inspect_format(mapped_rows, _), do: IO.inspect(mapped_rows)

  defp row_reducer(row, cols) do
    row
    |> Enum.with_index
    |> Enum.reduce(%{}, fn({el, index}, acc) -> 
      Map.put(acc, Enum.at(cols, index), el)
    end)
  end
  
end
