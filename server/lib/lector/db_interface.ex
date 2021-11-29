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
    {:ok, pid} = Postgrex.start_link(hostname: @hostname, username: @username, database: @database)

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, "SELECT * FROM noticias", [])

    Enum.map(rows, fn row -> row_reducer(row, columns) end)
  end

  defp row_reducer(row, cols) do
    row
    |> Enum.with_index
    |> Enum.reduce(%{}, fn({el, index}, acc) -> 
      Map.put(acc, Enum.at(cols, index), el)
    end)
  end
  
end
