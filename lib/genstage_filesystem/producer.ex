defmodule GenstageFilesystem.Producer do
  use GenStage

  ##########
  # Client API
  ##########
  def start_link(dir) do
    GenStage.start_link(__MODULE__, {0, dir, []}, name: __MODULE__)
  end


  ##########
  # Server callbacks
  ##########

  def init({0, dir, []}) do
    {:producer, {0, dir, []}}
  end

  def handle_demand(demand, {state_demand, dir, files}) when demand > 0 do

    # Make a call to the server for the required number of events,
    # accounting for previously unsatisfied demand
    new_demand = demand + state_demand

    {count, events} = take(new_demand, dir)

    # Events will always be returned from this server,
    # but if `events` was empty, state will be updated to the new demand level
    {:noreply, events, {new_demand - count, dir, files}}
  end

  defp take(demand, dir) do
    
    {:ok, files} = File.ls(dir)

    {Enum.count(files), files}
  end

end