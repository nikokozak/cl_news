defmodule Lector.DBInterface do
  require Postgrex

  @hostname "localhost"
  @username "lector_chile"
  @database "lector"

  def all do
    {:ok, pid} = Postgrex.start_link(hostname: @hostname, username: @username, database: @database)

    %{columns: columns,
      rows: rows } = Postgrex.query!(pid, "SELECT * FROM noticias", [])

    IO.inspect(columns)
    IO.inspect(rows)
  end
  
end
