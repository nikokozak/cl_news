defmodule Lector.Template do
  @moduledoc """
  Defines helper functions for rendering Templates.

  What this allows is a naive re-implementation of how Phoenix handles views/templates. 
  By 'using' `Lector.Template`, a render function gets injected into the target module. This render
  function (via Lector.Template functions) both compiles and evaluates a given template file, pulling
  in the target (view) Module's bindings (i.e., functions defined in the Module are accessible to the template
  without any more work on the user's side).

  The render function renders both the template and the base layout, passing in the rendered template as
  `:inner_content` in the `assigns` made available to the layout.

  The default layout can be adjusted by passing in a `layout: $layout` option to the `use` declaration,
  and specifying a filename to be pulled from the `lib/templates/layouts` directory.
  """

  require EEx
  @template_dir "lib/templates"
  @layout_dir "lib/templates/layouts"

  @doc """
  Injects the render function into our "views".
  """
  defmacro __using__(opts) do
    layout = Keyword.get(opts, :layout, "base.html.eex") |> (&(Path.join(@layout_dir, &1))).()
    quote do
      def render(conn, file, assigns \\ []), do: Lector.Template.render(__MODULE__, conn, file, assigns)

      def layout, do: unquote(layout)
    end
  end

  @doc """
  Renders a template file with the given assigns, sends a response with a 200 status and the rendered body.
  """
  def render(module, %{ status: status } = conn, file, assigns) do
    rendered_template = render_template(module, file, assigns)
    assigns = [assigns | [inner_content: rendered_template]]

    rendered_layout = render_layout(module, assigns)
    Plug.Conn.send_resp(conn, (status || 200), rendered_layout)
  end

  defp render_layout(module, assigns) do
    module.layout()
    |> render_file(assigns)
  end

  defp render_template(module, file, assigns) do
    Path.join(@template_dir, file) 
    |> render_file(assigns, functions: [{module, module.__info__(:functions)}])
  end

  defp render_file(file, assigns, eval_options \\ []) do
    quoted = EEx.compile_file(file)
    # Note that binding() will return, among others the "assigns" parameter, allowing us to use the @key EEx convenience in templates.
    {result, _binding} = Code.eval_quoted(quoted, binding(), eval_options)
    result
  end

end
