defmodule DogIRC.Commands do
  @moduledoc """
  Generates properly formatted IRC commands.
  """

  @doc """
  Command to change IRC nickname

  Example
  ------

     iex> DogIRC.Commands.nick("frodo")
     "NICK frodo\r\n"
  """
  def nick(nick) do
    "NICK #{nick}\r\n"
  end

  def user(username, realname, hostname \\ "foo", servername \\ "bar") do
    "USER #{username} #{hostname} #{servername} #{realname}\r\n"
  end

  def join(channel),
  do: "JOIN #{channel}\r\n"

  def privmsg(target, message),
  do: "PRIVMSG #{target} :#{message}\r\n"

  def quit(reason \\ ""),
  do: "QUIT #{reason}\r\n"
end
