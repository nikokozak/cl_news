defmodule Lector.Cache do
  use GenServer
  require Logger
  @doc """
  An in-memory reflection of our database.
  Uses ETS as an in-memory db.
  Is refreshed every 5 minutes.

  Keeps the latest 200 stories in the :noticias ETS table. <- TODO
  Keeps the latest :updated_at value in genserver state.
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
    :ets.new(:secciones, [:named_table, :ordered_set])
    :ets.new(:medios, [:named_table, :ordered_set])

    store_medios()
    store_secciones()
    %{"dt" => updated_at} = Lector.DB.get_updated_at

    schedule_refresh()
    {:ok, %{ updated_at: updated_at }}
  end

  # These can access the tables seeing as the tables are public-read by default
  def get_medio_fullname(std_name), do: get_fullname(:medios, std_name)
  def get_seccion_fullname(std_name), do: get_fullname(:secciones, std_name)
  def get_medios, do: :ets.tab2list(:medios)
  def get_secciones, do: :ets.tab2list(:secciones)
  def get_updated_at, do: GenServer.call(:lector_cache, :get_updated_at)

  def handle_info(:refresh, state) do
    store_medios()
    store_secciones()
    %{ "dt" => updated_at } = Lector.DB.get_updated_at

    Logger.debug("Cache updated")

    schedule_refresh()
    {:noreply, %{ state | updated_at: updated_at }}
  end

  def handle_call(:get_updated_at, _from, state) do
    {:reply, Map.get(state, :updated_at), state}
  end

  #############################################################
  ###################### PRIVATE ##############################
  #############################################################

  defp store_medios do
    Lector.DB.get_medios
    |> Enum.each(fn medio ->
      :ets.insert(:medios, {Map.get(medio, "medio_id"), Map.get(medio, "std"), Map.get(medio, "nombre")})
    end)

    :ok
  end

  defp store_secciones do
    Lector.DB.get_secciones
    |> Enum.each(fn seccion ->
      :ets.insert(:secciones, {Map.get(seccion, "seccion_id"), Map.get(seccion, "std"), Map.get(seccion, "nombre")})
    end)

    :ok
  end

  defp get_fullname(table, std_name) do
    try do
      [{_, _, full_name}] = :ets.match_object(table, {:_, std_name, :_})
      full_name
    rescue 
      MatchError -> nil
    end
  end

  defp schedule_refresh, do: Process.send_after(self(), :refresh, 5 * 60 * 1000)

end
