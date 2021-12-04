defmodule Lector.Template do
  require EEx
  @template_dir "lib/templates"

  @doc """
  Injects the render function into our "views".
  """
  defmacro __using__(_opts) do
    quote do
      def render(conn, file, assigns \\ []), do: Lector.Template.render(__MODULE__, conn, file, assigns)

      @overridable
      def layout, do: "lib/templates/layouts/base.html.eex"
    end

    defoverridable layout: 0
  end

  @doc """
  Renders a template file with the given assigns, sends a response with a 200 status and the rendered body.
  """
  def render(module, %{ status: status } = conn, file, assigns) do
    result = render_template(module, file, assigns)
    Plug.Conn.send_resp(conn, (status || 200), result)
  end

  # Core of the above render function, compiles a template file, and then evaluates it with the given assigns and the module's functions as context.
  defp render_template(module, file, assigns) do
    quoted = EEx.compile_file(Path.join(@template_dir, file))
    {result, _binding} = Code.eval_quoted(quoted, binding(), functions: [{module, module.__info__(:functions)}])
    result
  end

end
