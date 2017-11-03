defmodule GenstageFilesystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger


  def start(_type, _args) do
    directory = Application.get_env(:genstage_filesystem, :directory)
    {:ok, pid } = start_app(directory)    
  end



  defp start_app(nil) do
    Logger.warn("Config value :genstage_filesystem, :directory is nil - Application not started")
    {:ok, self()}
  end

  defp start_app(directory) do
    start_app(directory, directory_valid?(directory))
  end

  defp start_app(directory, false) do
    Logger.warn("Config value :genstage_filesystem, :directory is '#{directory}' - invalid directory")
    {:ok, self()}
  end

  defp start_app(directory, true) do

    import Supervisor.Spec

    children = [
      worker(GenstageFilesystem.Server,[directory]),
      worker(GenstageFilesystem.Producer, [])
    ]

    opts = [strategy: :one_for_one, name: GenstageFilesystem.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defp directory_valid?(directory) do
    File.exists?(directory) && File.dir?(directory)
  end

end
