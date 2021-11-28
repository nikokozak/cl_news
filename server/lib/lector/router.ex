defmodule Lector.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/test" do
    send_resp(conn, 200, "A test")
  end

  get "/" do
    send_resp(conn, 200, "Home")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
