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
  @default_layout "base.html.eex"

  @doc """
  Injects the render function into our "views".
  """
  defmacro __using__(opts) do
    %{ module: calling_module } = __CALLER__

    # layout optionally defined by passing a `layout: <new_file>` option to `use`
    layout = get_layout_path(opts)

    # for now, we only retrieve template files that have the same name as the module `using` this macro
    tmplt_base_name = normalize_module_name(calling_module)
    tmplt_filename = tmplt_base_name <> ".html.eex"

    # the precompiled function to render is has the same name as the normalized module name.
    # again, in future iterations we could have multiple pages with multiple names, where rendering gets
    # dispatched according to the "filename" passed in
    fn_name = tmplt_base_name |> String.to_atom
    quoted_template = EEx.compile_file(Path.join(@template_dir, tmplt_filename))
    quoted_layout = EEx.compile_file(layout)

    quote do
      def render(conn, file, assigns \\ []), do: Lector.Template.render(__MODULE__, conn, file, assigns)

      # will inject eg. 'def home(assigns) do'
      unquote( # double quoting necessary in order to preserve the `assigns` variable
        quote do
          def unquote(fn_name)(var!(assigns)) do
            _ = var!(assigns)
            unquote(quoted_template)
          end
        end
      )

      #def layout, do: unquote(layout)
      unquote(
        quote do
          def layout(var!(assigns)) do
            _ = var!(assigns)
            unquote(quoted_layout)
          end
        end
      )
    end
  end

  @doc """
  Renders a template file with the given assigns, sends a response with a 200 status and the rendered body.
  """
  def render(module, %{ status: status } = conn, file, assigns) do
    template_render_fn_name = get_fn_name_from_filename(file)
    rendered_template = apply(module, template_render_fn_name, [assigns])
    #rendered_template = render_template(module, file, assigns)
    assigns = [assigns | [inner_content: rendered_template]]

    #rendered_layout = render_layout(module, assigns)
    rendered_layout = apply(module, :layout, [assigns])
    Plug.Conn.send_resp(conn, (status || 200), rendered_layout)
  end

  defp render_template(module, file, assigns) do
    Application.app_dir(:lector, [@template_dir, file])
    |> render_file(assigns, functions: [{module, module.__info__(:functions)}])
  end

  defp render_layout(module, assigns) do
    module.layout()
    |> render_file(assigns)
  end

  defp render_file(file, assigns, eval_options \\ []) do
    quoted = EEx.compile_file(file)
    # Note that binding() will return, among others the "assigns" parameter, allowing us to use the @key EEx convenience in templates.
    {result, _binding} = Code.eval_quoted(quoted, binding(), eval_options)
    result
  end

  defp normalize_module_name(module) do
    module
    |> Module.split
    |> List.last
    |> Macro.underscore
  end

  defp get_layout_path(opts) do
    Keyword.get(opts, :layout, @default_layout) 
    |> (&(Path.join(@layout_dir, &1))).()
  end

  defp get_fn_name_from_filename(filename) do
    filename
    |> String.split(".")
    |> List.first
    |> String.to_atom
  end

end
