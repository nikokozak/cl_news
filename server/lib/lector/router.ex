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

  get "/:seccion" do
    results = Lector.DBInterface.get_seccion(seccion)
    render(conn, "home.eex", [noticias: results, seccion: seccion])
  end

  get "/ultimo/:page" do
    results = Lector.DBInterface.get_all((String.to_integer(page) - 1) * 5, 5)
    render(conn, "home.eex", [noticias: results, seccion: "Lo Último", page: page])
  end

  get "/" do
    results = Lector.DBInterface.get_all(0, 5) 
    render(conn, "home.eex", [noticias: results, seccion: "Lo Último", page: 0])
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
