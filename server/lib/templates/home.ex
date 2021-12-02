defmodule Lector.Templates.Home do
  require EEx
  import Lector.Templates.Component, only: [pagination: 3, navigation: 0]

  @template_dir "lib/templates"

  EEx.function_from_file(:def, :render_template, Path.join(@template_dir, 'home.html.eex'), [:assigns])

  def render(%{status: status} = conn, assigns \\ []) do
    result = render_template(assigns)
    Plug.Conn.send_resp(conn, (status || 200), result)
 end

end
