defmodule Lector.Router do
  use Plug.Router

  @template_dir "lib/templates"

  plug :match
  plug :dispatch

  get "/test" do
    Lector.DBInterface.get_all
    send_resp(conn, 200, "A test")
  end

  get "/noticia/:id" do
    {:ok, id} = Base.url_decode64(id)
    [noticia] = Lector.DBInterface.get_noticia(id)
    render(conn, "noticia.eex", [noticia: noticia])
  end

  get "/" do
    results = Lector.DBInterface.get_all
    render(conn, "home.eex", [noticias: results])
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body = 
      @template_dir
      |> Path.join(template)
      |> EEx.eval_file(assigns)

    send_resp(conn, (status || 200), body)
  end
end
