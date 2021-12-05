defmodule Lector.Cache do
  use GenServer
  @doc """
  An in-memory reflection of our database.
  Uses ETS as an in-memory db.

  Keeps the latest 200 stories in the :noticias ETS table.
  Keeps a representation of the :secciones table in ETS.
  Keeps a representation of the :medios table in ETS.

  These last two are important, as they allow us to dynamically create
  sections, and translate from normalized to non-normalized terms easily.

  TODO: Currently this is a simple GenServer. We might want to transition into
  a Pool design if this becomes a bottleneck.
  """

  #############################################################
  ###################### PUBLIC API ###########################
  #############################################################

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: :lector_cache)
  end

  #############################################################
  ###################### CALLBACKS ############################
  #############################################################

  def init(_) do
    :ets.new(:noticias, [:named_table])
    :ets.new(:secciones, [:named_table])
    :ets.new(:medios, [:named_table])

    store_medios()
    store_secciones()

    {:ok, nil}
  end

  # These can access the tables seeing as the tables are public-read by default
  def get_medio_fullname(std_name), do: get_fullname(:medios, std_name)
  def get_seccion_fullname(std_name), do: get_fullname(:secciones, std_name)

  #############################################################
  ###################### PRIVATE ##############################
  #############################################################

  defp store_medios do
    Lector.DB.get_medios
    |> Enum.each(fn medio ->
      :ets.insert(:medios, {Map.get(medio, "std"), Map.get(medio, "nombre")})
    end)

    :ok
  end

  defp store_secciones do
    Lector.DB.get_secciones
    |> Enum.each(fn seccion ->
      :ets.insert(:secciones, {Map.get(seccion, "std"), Map.get(seccion, "nombre")})
    end)

    :ok
  end

  defp get_fullname(table, std_name) do
    try do
      [{_, full_name}] = :ets.lookup(table, std_name)
      full_name
    rescue 
      MatchError -> nil
    end
  end

end
