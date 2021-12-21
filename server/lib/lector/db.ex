defmodule Lector.DB do
  use GenServer
  require Postgrex

  #############################################################
  ###################### PUBLIC API ###########################
  #############################################################
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :db)
  end

  @doc """
  Retrieves all entries from the 'noticias' table.
  Maps column names onto each row value, returning an array of
  Maps.
  """
  def get_all(offset \\ 0, limit \\ false) do
    GenServer.call(:db, {:get_all, [offset: offset, limit: limit]})
  end

  @doc """
  Retrieves all entries from the 'noticias' table matching a given 'seccion'.
  Maps column names onto each row value, returning an array of Maps.
  """
  def get_seccion(seccion, offset \\ 0, limit \\ false) do
    GenServer.call(:db, {:get_seccion, [seccion: seccion, offset: offset, limit: limit]})
  end

  def get_noticia(id) do
    GenServer.call(:db, {:get_noticia, id})
  end

  def get_medios do
    GenServer.call(:db, :get_medios)
  end

  def get_secciones do
    GenServer.call(:db, :get_secciones)
  end

  def get_updated_at do
    GenServer.call(:db, :get_updated_at)
  end

  #############################################################
  ###################### CALLBACKS ############################
  #############################################################

  def init(_) do
    {:ok, db_conn} = Postgrex.start_link(
      database: database(),
      username: username(),
      pool_size: 25 # In theory this allows us to use the DBConnection pool behavior.
    )

    IO.inspect(db_conn)

    {:ok, conn: db_conn}
  end

  def terminate(_, [conn: db_conn] = _state) do
    GenServer.stop(db_conn)
    :conn_closed
  end

  def handle_call({:get_all, [offset: offset, limit: limit]}, _from, [conn: db_conn] = state) do
    query = "SELECT m.nombre as medio, m.std as medio_std, s.nombre as seccion, s.std as seccion_std, noticia_id, titular, bajada, autor, imagen_url, cuerpo, fecha, to_char(fecha, 'DD-MM-YYYY') as fecha_short, count(*) over() as full_count
        FROM noticias 
        JOIN medios as m USING (medio_id) 
        JOIN secciones as s USING (seccion_id)
        ORDER BY fecha DESC
        OFFSET $1"

    query = if limit != false, do: query <> " LIMIT $2", else: query
    params = if limit != false, do: [offset, limit], else: [offset]

    %{columns: columns,
      rows: rows } = Postgrex.query!(db_conn, query, params)

    {:reply, format_rows(rows, columns), state}
  end

  def handle_call({:get_seccion, [seccion: seccion, offset: offset, limit: limit]}, _from, [conn: db_conn] = state) do
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
      rows: rows } = Postgrex.query!(db_conn, query, params)

    {:reply, format_rows(rows, columns), state}
  end

  def handle_call({:get_noticia, id}, _from, [conn: db_conn] = state) do
    query = "SELECT m.nombre as medio, m.std as medio_std, s.nombre as seccion, s.std as seccion_std, noticia_id, titular, bajada, autor, imagen_url, cuerpo, to_char(fecha, 'DD-MM-YYYY') as \"fecha\"
    FROM noticias
    JOIN medios as m USING (medio_id)
    JOIN secciones as s USING (seccion_id)
    WHERE noticia_id = $1"

    params = [id]

    try do
      %{columns: columns, rows: rows} = Postgrex.query!(db_conn, query, params)
      {:reply, format_rows(rows, columns), state}
    rescue
      # Will throw as encode error when binary is not right UUID length
      DBConnection.EncodeError -> {:reply, [], state}
    end
  end

  def handle_call(:get_medios, _from, [conn: db_conn] = state) do
    query = "SELECT medio_id, nombre, std 
    FROM medios
    ORDER BY medio_id ASC"

    %{columns: columns, rows: rows} = Postgrex.query!(db_conn, query, [])

    {:reply, format_rows(rows, columns), state}
  end

  def handle_call(:get_secciones, _from, [conn: db_conn] = state) do
    query = "SELECT seccion_id, nombre, std 
    FROM secciones
    ORDER BY seccion_id ASC"

    %{columns: columns, rows: rows} = Postgrex.query!(db_conn, query, [])

    {:reply, format_rows(rows, columns), state}
  end

  def handle_call(:get_updated_at, _from, [conn: db_conn] = state) do
    query = "SELECT MAX(dt) as dt 
    FROM updated_at"

    %{columns: columns, rows: rows} = Postgrex.query!(db_conn, query, [])

    result = format_rows(rows, columns) |> List.first

    {:reply, result, state}
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

  def username, do: Application.get_env(:lector, :db) |> Keyword.get(:username)
  def database, do: Application.get_env(:lector, :db) |> Keyword.get(:database)

end
