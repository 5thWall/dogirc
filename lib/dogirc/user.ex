defmodule DogIRC.User do
  @moduledoc """
  Module for parsing user information from IRC format and storing it in a
  strucured format.
  """

  @reg ~r/^([a-z]['a-z\d\[\]\{\}\\\^]+)(?:!([^\s]+?))?(?:@(.+))?$/i
  @module __MODULE__

  defstruct nick: "", username: "", host: ""

  def parse(user) when is_binary(user) do
    Regex.run(@reg, user) |> do_parse
  end

  def parse(user) do
    user |> to_string |> parse
  end

  defp do_parse([_user, nick, username, host]) do
    %@module{nick: nick, username: username, host: host}
  end

  defp do_parse([_user, nick, username]) do
    %@module{nick: nick, username: username}
  end

  defp do_parse([_user, nick]) do
    %@module{nick: nick}
  end
end
