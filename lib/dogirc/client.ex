defmodule DogIRC.Client do
  @moduledoc """
  IRC Client Module. Holds irc connection, and provides interface for sending
  IRC commands.
  """

  use GenServer
  alias DogIRC.Commands
  alias DogIRC.Connection

  @module __MODULE__

  ##
  # External API

  def start_link do
    server = Application.get_env(:dogirc, :server)
    port   = Application.get_env(:dogirc, :port, 6667)
    start_link(server, port)
  end

  @doc "Start client process and join specified server"
  def start_link(server, port \\ 6667),
  do: GenServer.start_link(@module, [server: server, port: port], name: @module)

  @doc "Join a channel"
  def join(channel),
  do: GenServer.cast(@module, {:join, channel})

  @doc "Message a channel or user"
  def privmsg(target, message),
  do: GenServer.cast(@module, {:privmsg, target, message})

  @doc "Send an action to a channel"
  def me(target, action),
  do: GenServer.cast(@module, {:action, target, action})

  @doc "Send a notice to a channel or user"
  def notice(target, message),
  do: GenServer.cast(@module, {:notice, target, message})

  @doc """
  Send a raw IRC command, "\r\n" is appended automaticasty
  """
  def quote(command),
  do: GenServer.cast(@module, {:quote, command})

  @doc "Tell the client to quit, optionally passing a part message"
  def quit,
  do: GenServer.cast(@module, :quit)

  def quit(reason),
  do: GenServer.cast(@module, {:quit, reason})

  ##
  # GenServer Implimentation

  def init([server: server, port: port]) do
    {:ok, conn} = Connection.start_link(server: server, port: port, client: self)
    Connection.send_cmd(conn, Commands.nick("DogIRC"))
    Connection.send_cmd(conn, Commands.user("DogIRC", "DogIRC"))
    {:ok, %{conn: conn}}
  end

  def handle_cast({:join, channel}, state) do
    Connection.send_cmd(state.conn, Commands.join(channel))
    {:noreply, state}
  end

  def handle_cast({:privmsg, target, message}, state) do
    Connection.send_cmd(state.conn, Commands.privmsg(target, message))
    {:noreply, state}
  end

  def handle_cast({:action, target, action}, state) do
    Connection.send_cmd(state.conn, Commands.action(target, action))
    {:noreply, state}
  end

  def handle_cast({:notice, target, message}, state) do
    Connection.send_cmd(state.conn, Commands.notice(target, message))
    {:noreply, state}
  end

  def handle_cast({:quote, command}, state) do
    Connection.send_cmd(state.conn, command)
    {:noreply, state}
  end

  def handle_cast({:quit, reason}, state) do
    Connection.quit(state.conn)
    {:noreply, state}
  end

  def handle_cast(:quit, state) do
    Connection.quit(state.conn)
    {:noreply, state}
  end

  def handle_info({:command, cmd}, state) do
    cmd |> inspect |> IO.puts
    {:noreply, state}
  end

  def handle_info(whatever, state) do
    IO.puts "Got: #{inspect whatever}"
    {:noreply, state}
  end
end
