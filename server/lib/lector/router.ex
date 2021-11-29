defmodule Lector.Router do
  require EEx
  use Plug.Router

  plug :match
  plug :dispatch

  get "/test" do
    send_resp(conn, 200, "A test")
  end

  get "/" do
    compiled = EEx.compile_file('lib/templates/home.eex')
    {home, _bindings} = Code.eval_quoted(compiled, a: "One", b: "Two")
    conn
    |> Plug.Conn.put_resp_header("content-type", "text/html")
    |> send_resp(200, home)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
