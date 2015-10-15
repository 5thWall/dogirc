defmodule Dogirc.Plugin.UserList.Supervisor do
  @moduledoc """
  Supervises event handler and supervisor for user registry
  """

  use Supervisor

  def start_link(client) do
    result = {:ok, sup} = Supervisor.start_link(@module, [client])
    start_workers(sup, client)
    result
  end

  def start_workers(sup, client) do
    # {:ok, handler} = Supervisor.start_child(sup, worker(UserList.Handler, [client]))
    # Supervisor.start_child(sup, supervisor(
  end
end
