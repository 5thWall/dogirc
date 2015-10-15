defmodule Dogirc.Plugin.UserList do
  @moduledoc """
  Plugin to track users in a channel.
  """

  alias Dogirc.Plugin.UserList

  def init(client) do
    UserList.Supervisor.start_link(client)
  end
end
