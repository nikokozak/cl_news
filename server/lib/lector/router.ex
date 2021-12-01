defmodule Lector.Router do
  use Plug.Router
  alias Lector.Templates.Home
  alias Lector.Templates.Noticia

  plug :match
  plug :dispatch

  get "/test" do
    Lector.DBInterface.get_all
    send_resp(conn, 200, "A test")
  end

  get "/noticia/:id" do
    {:ok, id} = Base.url_decode64(id)
    [noticia] = Lector.DBInterface.get_noticia(id)
    Noticia.render(conn, "noticia.html.eex", noticia: noticia)
  end

  get "/ultimo/:page" do
    page_int = String.to_integer(page)
    results = Lector.DBInterface.get_all((page_int - 1) * 5, 5)
    Home.render(conn, noticias: results, seccion: "Lo Último", page: page_int)
  end

  get "/:seccion/:page" do
    page_int = String.to_integer(page)
    results = Lector.DBInterface.get_seccion(seccion, (page_int - 1) * 5, 5)
    #render(conn, "home.html.eex", [noticias: results, seccion: seccion])
    Home.render(conn, noticias: results, seccion: seccion, page: page_int)
  end

  get "/:seccion" do
    results = Lector.DBInterface.get_seccion(seccion, 0, 5)
    #render(conn, "home.html.eex", [noticias: results, seccion: seccion])
    Home.render(conn, noticias: results, seccion: seccion, page: 1)
  end

  get "/" do
    results = Lector.DBInterface.get_all(0, 5) 
    Home.render(conn, noticias: results, seccion: "Lo Último", page: 1)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

# Old render function, keeping around for reference (not compiled!)
# defp render(%{status: status} = conn, template, assigns \\ []) do
#   body = 
#     @template_dir
#     |> Path.join(template)
#     |> EEx.eval_file(assigns)
#
#   send_resp(conn, (status || 200), body)
# end
end
