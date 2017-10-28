defmodule GenstageFilesystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  require Tap

  def start(_type, _args) do
    setup_taps()

    import Supervisor.Spec


    

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GenstageFilesystem.Worker.start_link(arg)
      worker(GenstageFilesystem.Producer, ["."])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GenstageFilesystem.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defp setup_taps do
    require GenstageFilesystem.Producer
    Tap.call(GenstageFilesystem.Producer.init(_), max: 2)
  end
end
