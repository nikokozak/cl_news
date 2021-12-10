defmodule Lector.Router do
  require Logger
  use Plug.Router
  alias Lector.Templates.{Home, Noticia, Error}
  require Lector.Templates.Home

  plug :match
  plug :dispatch
  plug :log_metadata_plug

  @results_per_page 20

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
      _err -> send_error(conn)
    end
  end

  get "/ultimo/:page" do
    page_int = String.to_integer(page)
    results = Lector.DB.get_all((page_int - 1) * @results_per_page, @results_per_page)
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: "Lo Último", seccion: "ultimo", page: page_int)
  end

  get "/:seccion/:page" do
    with false <- is_nil(Lector.Cache.get_seccion_fullname(seccion))
    do
      page_int = String.to_integer(page)
      results = Lector.DB.get_seccion(seccion, (page_int - 1) * @results_per_page, @results_per_page)
      seccion_fullname = Lector.Cache.get_seccion_fullname(seccion)
      Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: seccion_fullname, seccion: seccion, page: page_int)
    else
      _err -> send_error(conn)
    end
  end

  get "/:seccion" do
    with false <- is_nil(Lector.Cache.get_seccion_fullname(seccion))
    do
      results = Lector.DB.get_seccion(seccion, 0, @results_per_page)
      seccion_fullname = Lector.Cache.get_seccion_fullname(seccion)
      Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: seccion_fullname, seccion: seccion, page: 1)
    else
      _err -> send_error(conn)
    end
  end

  get "/" do
    results = Lector.DB.get_all(0, @results_per_page) 
    Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: "Lo Último", seccion: "ultimo", page: 1)
    #Home.render(conn, "home.html.eex", noticias: results, seccion_fullname: "Lo Último", seccion: "ultimo", page: 1)
  end

  match _ do
    send_error(conn)
  end

  def log_metadata_plug(conn, _opts) do
    %{ 
      method: method,
      request_path: req_path,
      remote_ip: ip_tup,
      req_headers: headers,
      state: state,
      status: status,
    } = conn

    {_, user_agent} = Enum.find(headers, fn {h, _v} -> h == "user-agent" end)
    ip = Enum.join(Tuple.to_list(ip_tup), ".")

    Logger.debug("#{method} #{req_path} #{ip} :: #{user_agent} :: #{state} - #{status}")
    Logger.info("#{method} #{req_path} #{ip} :: #{state} - #{status}")
    conn
  end

  def send_error(conn) do
    conn
    |> Plug.Conn.put_status(404)
    |> Error.render("error.html.eex")
  end

end
