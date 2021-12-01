defmodule Lector.Templates.Noticia do

  @template_dir "lib/templates"

  def render(%{status: status} = conn, template, assigns \\ []) do
    quoted = 
      @template_dir
      |> Path.join(template)
      |> EEx.compile_file

    {result, _bindings} = Code.eval_quoted(quoted, assigns)

    Plug.Conn.send_resp(conn, (status || 200), result)
  end

end
