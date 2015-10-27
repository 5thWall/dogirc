defmodule Dogirc.Plugin.UserList.RegistrySupervisor do
  @moduledoc """
  Supervisor for registry and name buckets
  """

  use Supervisor

  @module __MODULE__

  alias Dogirc.Plugin.UserList.NameSupervisor
  alias Dogirc.Plugin.UserList.ChannelRegistry

  def start_link do
    Supervisor.start_link(@module, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(NameSupervisor, [[name: NameSupervisor]]),
      worker(ChannelRegisry, [NameSupervisor, [name: ChannelRegistry]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
