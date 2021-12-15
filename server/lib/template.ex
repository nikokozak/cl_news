defmodule Lector.Template do
  @moduledoc """
  Defines helper functions for rendering Templates.

  What this allows is a naive re-implementation of how Phoenix handles views/templates. 

  When 'using' `Lector.Template`, files sharing the same module name as the view being used get pre-compiled
  into named render functions. In other words, `Lector.Templates.Home` will pre-compile a `home.html.eex` file
  in the same folder into a function of the same name (`Lector.Templates.Home.home(assigns)`), which renders 
  the template.

  NOTE: As a next step, it makes sense to divvy up the templates into folders named after the parent view module,
  as it's done in Phoenix. This means that instead of only pre-compiling one file, we can pre-compile many into the
  same view module, and they will all share the context and layout declared in said file.

  'Using' `Lector.Template` will also inject a `render(conn, file, assigns \\ [])` function. While at the moment
  I haven't built in support for multiple template files per view, the <file> parameter will match the given file
  to a named function for rendering. If, for example, we pass in `home.html.eex`, the `home` function will get called
  for rendering. 

  The render function renders both the template and the base layout, passing in the rendered template as
  `:inner_content` in the `assigns` made available to the layout.

  The default layout can be adjusted by passing in a `layout: $layout` option to the `use` declaration,
  and specifying a filename to be pulled from the `lib/templates/layouts` directory.
  """

  require EEx
  @template_dir Application.compile_env!(:lector, :template_dir)
  @layout_dir Application.compile_env!(:lector, :layout_dir)
  @default_layout Application.compile_env!(:lector, :default_layout)

  @doc """
  Injects the render, and template-render functions into our "views".
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
    tmplt_fn_name = tmplt_base_name |> String.to_atom
    quoted_template = EEx.compile_file(Path.join(@template_dir, tmplt_filename))
    quoted_layout = EEx.compile_file(layout)

    quoted_template_render_fn = craft_render_fn(tmplt_fn_name, quoted_template)
    quoted_layout_render_fn = craft_render_fn(:layout, quoted_layout)

    quote do
      def render(conn, file, assigns \\ []), do: Lector.Template.render(__MODULE__, conn, file, assigns)

      # injects `def home(assigns) do`
      unquote(quoted_template_render_fn)
      # injects `def layout(assigns) do`
      unquote(quoted_layout_render_fn)
      
    end

  end

  @doc """
  Renders a template file with the given assigns, sends a response with a 200 status and the rendered body.
  """
  def render(module, %{ status: status } = conn, file, assigns) do
    template_render_fn_name = get_fn_name_from_filename(file)
    rendered_template = apply(module, template_render_fn_name, [assigns])
    assigns = [assigns | [inner_content: rendered_template]]

    rendered_layout = apply(module, :layout, [assigns])

    conn = Plug.Conn.assign(conn, :timing_end, System.monotonic_time(:millisecond))

    conn
    |> Plug.Conn.assign(:time_taken, conn.assigns[:timing_end] - conn.assigns[:timing_init])
    |> Plug.Conn.send_resp((status || 200), rendered_layout)
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

  defp craft_render_fn(fn_name, quoted_content) do
    quote do
      def unquote(fn_name)(var!(assigns)) do
        _ = var!(assigns)
        unquote(quoted_content)
      end
    end
  end

end
