defmodule GenstageFilesystem.Server do
  use GenServer

  ##########
  # Client API
  ##########
  def start_link(directory) do
    {:ok, pid} = GenServer.start_link(__MODULE__, directory , name: __MODULE__)
  end

  def pull(count) do
    GenServer.call(GenstageFilesystem.Server, {:pull, count})
  end

  ##########
  # Server callbacks
  ##########
  def init(directory) do
    {:ok, directory}
  end

  def handle_call({:pull, count}, _from, dir) do
    #IO.puts "Pulling #{count} events from server"
    events = get_files(dir)
    taken_events = events |> Enum.take(count)

    taken_events |> Enum.each(fn(f) ->
      :ok  = File.rename("#{dir}/#{f}", "#{dir}/#{f}.done")
    end)

    {:reply, {Enum.count(taken_events), taken_events}, dir}
  end

  defp get_files(dir) do
    
    {:ok, files} = File.ls(dir)
    files |> new_files() |> Enum.sort()
  end

  defp new_files(files) do
    files |> Enum.filter(fn(f) -> !String.ends_with?(f, ".done") end)
  end

end