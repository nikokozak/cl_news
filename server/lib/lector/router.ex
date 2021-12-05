defmodule Lector.Router do
  use Plug.Router
  alias Lector.Templates.Home
  alias Lector.Templates.Noticia

  plug :match
  plug :dispatch

  get "/test" do
    Lector.DB.get_all
    send_resp(conn, 200, "A test")
  end

  get "/noticia/:id" do
    with {:ok, id} <- Base.url_decode64(id),
         [noticia] <- Lector.DB.get_noticia(id)
    do
      Noticia.render(conn, "noticia.html.eex", noticia: noticia)
    else
      _err -> send_resp(conn, 404, "not found")
    end
  end

  get "/ultimo/:page" do
    page_int = String.to_integer(page)
    results = Lector.DB.get_all((page_int - 1) * 5, 5)
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: "Lo Último", seccion: "ultimo", page: page_int)
  end

  get "/:seccion/:page" do
    page_int = String.to_integer(page)
    results = Lector.DB.get_seccion(seccion, (page_int - 1) * 5, 5)
    seccion_fullname = Lector.Cache.get_seccion_fullname(seccion)
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: seccion_fullname, seccion: seccion, page: page_int)
  end

  get "/:seccion" do
    results = Lector.DB.get_seccion(seccion, 0, 5)
    seccion_fullname = Lector.Cache.get_seccion_fullname(seccion)
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: seccion_fullname, seccion: seccion, page: 1)
  end

  get "/" do
    results = Lector.DB.get_all(0, 5) 
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: "Lo Último", seccion: "ultimo", page: 1)
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
