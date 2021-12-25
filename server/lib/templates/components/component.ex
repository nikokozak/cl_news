defmodule Lector.Templates.Component do
  require EEx

  @component_dir 'lib/templates/components'

  # Compiled function for pagination
  EEx.function_from_file(:def, :pagination, Path.join(@component_dir, "pagination.html.eex"), [:conn, :items, :count_key, :page])

  # Compiled function for navigation
  EEx.function_from_file(:def, :navigation, Path.join(@component_dir, "navigation.html.eex"), [])
 
end
