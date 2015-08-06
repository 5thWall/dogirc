defmodule DogIRC.Client do
  @moduledoc """
  IRC Client Module. Holds irc connection, and provides interface for sending
  IRC commands.
  """

  use GenServer
  alias DogIRC.Commands
  alias DogIRC.Connection

  @module __MODULE__
  @localhost "localhost"
  @port 6667
  @name "DogIRC"

  ##
  # External API

  @doc """
  Start client process and join configured server
  """
  def start_link,
  do: Application.get_env(:dogirc, :client) |> start_link

  @doc """
  Start client process and join given server.
  """
  def start_link(config) do
    config = Keyword.merge(Application.get_env(:dogirc, :client), config)
    GenServer.start_link(@module, config, name: @module)
  end

  def add_handler(handler, opts),
  do: GenServer.call(@module, {:add_handler, handler, opts})

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

  def init(config) do
    {:ok, manager} = GenEvent.start_link

    server = config |> Keyword.get(:server, @localhost)
    port   = config |> Keyword.get(:port, @port)
    {:ok, conn} = Connection.start_link(server: server, port: port, client: self)

    nick_cmd = config |> Keyword.get(:nick, @name) |> Commands.nick
    conn |> Connection.send_cmd(nick_cmd)

    user = config |> Keyword.get(:user, @name)
    real = config |> Keyword.get(:real, @name)
    Connection.send_cmd(conn, Commands.user(user, real))

    {:ok, %{conn: conn, event_manager: manager}}
  end

  def handle_call({:add_handler, handler, opts}, state) do
    resp = GenEvent.add_handler(state.manager, handler, opts)
    {:reply, resp, state}
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
    GenEvent.sync_notify(state.manager, cmd)
    {:noreply, state}
  end

  def handle_info(whatever, state) do
    IO.puts "Got: #{inspect whatever}"
    {:noreply, state}
  end
end
