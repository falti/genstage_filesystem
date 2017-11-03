defmodule GenstageFilesystem.Producer do
  use GenStage

  ##########
  # Client API
  ##########
  def start_link() do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end


  ##########
  # Server callbacks
  ##########

  def init(0) do
    {:producer, 0}
  end

  def handle_demand(demand, state) when demand > 0 do

    # Make a call to the server for the required number of events,
    # accounting for previously unsatisfied demand
    new_demand = demand + state

    {count, events} = take(new_demand)

    
    {:noreply, events, new_demand - count}
  end

  def take(demand) do
    GenstageFilesystem.Server.pull(demand)
  end

end