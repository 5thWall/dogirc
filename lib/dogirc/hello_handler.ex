defmodule Dogirc.HelloHandler do
  @moduledoc """
  Says hello when someone enters the room.
  """

  use GenEvent

  def handle_event(%Dogirc.Command{type: :join, from: user, target: target}, []) do
    message = "Hello #{user.nick}!"
    Dogirc.Client.notice(target, message)
    {:ok, []}
  end

  def handle_event(_, _), do: {:ok, []}
end
