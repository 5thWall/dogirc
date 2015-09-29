defmodule DogIRC do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(DogIRC.Client, [])
    ]

    opts = [strategy: :one_for_one, name: DogIRC.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
