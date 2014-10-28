defmodule DogIRC.Client do
  @moduledoc """
  IRC Client process, handles all interaction wih the IRC process. Can
  also be queried for current client state.
  """

  use GenServer
  alias DogIRC.Commands

  @name __MODULE__

  defstruct nick: "DogIRC",
            user: "DogIRC",
            real: "DogIRC",
            server: "localhost",
            port: 6667,
            sock: nil

  ##
  # External API

  @doc "Start client process and join specified server"
  def start_link(state \\ %DogIRC.Client{}),
  do: GenServer.start_link(@name, state, name: @name)

  @doc "Join a channel"
  def join(channel),
  do: GenServer.call(@name, {:join, channel})

  @doc "Message a channel or user"
  def privmsg(target, message),
  do: GenServer.call(@name, {:privmsg, target, message})

  @doc "Send an action to a channel"
  def me(target, action),
  do: GenServer.cast(@name, {:action, target, action})

  @doc "Send a notice to a channel or user"
  def notice(target, message),
  do: GenServer.cast(@name, {:notice, target, message})

  @doc """
  Send a raw IRC command, "\r\n" is appended automatically
  """
  def quote(command),
  do: GenServer.call(@name, {:quote, command})

  @doc "Tell the client to quit, optionally passing a part message"
  def quit,
  do: GenServer.call(@name, :quit)

  def quit(reason),
  do: GenServer.call(@name, {:quit, reason})

  ##
  # GenServer Implimentation

  def init(state) do
    sock = Socket.TCP.connect! state.server, state.port, packet: :line, mode: :active
    Socket.Stream.send!(sock, Commands.nick(state.nick))
    Socket.Stream.send!(sock, Commands.user(state.user, state.real))
    { :ok, %{state | sock: sock } }
  end

  def handle_call({:join, channel}, _from, state) do
    Socket.Stream.send!(state.sock, Commands.join(channel))
    { :reply, :ok, state }
  end

  def handle_call({:privmsg, target, message}, _from, state) do
    Socket.Stream.send!(state.sock, Commands.privmsg(target, message))
    { :reply, :ok, state }
  end

  def handle_cast({:action, target, action}, _, state) do
    Socket.Stream.send!(state.sock, Commands.action(target, action))
    { :noreply, state }
  end

  def handle_cast({:notice, target, message}, _, sate) do
    Socket.Stream.send!(state.sock, Commands.notice(target, action))
    { :noreply, state }
  end

  def handle_call({:quote, command}, _from, state) do
    Socket.Stream.send!(state.sock, "#{command}\r\n")
    { :reply, :ok, state }
  end

  def handle_call({:quit, reason}, _from, state) do
    Socket.Stream.send!(state.sock, Commands.quit(reason))
    Socket.Stream.shutdown! state.sock
    { :reply, :ok, state }
  end

  def handle_call(:quit, _from, state) do
    Socket.Stream.send!(state.sock, Commands.quit)
    Socket.Stream.shutdown! state.sock
    { :reply, :ok, state }
  end

  def handle_info({:tcp, _, "PING " <> target}, state) do
    Socket.Stream.send!(state.sock, "PONG #{target}\r\n")
    { :noreply, state }
  end

  def handle_info({:tcp_closed, _}, state) do
    { :noreply, %{ state | sock: nil } }
  end

  def handle_info({:tcp, _, data}, state) do
    IO.puts data
    {:noreply, state}
  end

  def handle_info(whatever, state) do
    IO.puts "Got: #{inspect whatever}"
    {:noreply, state}
  end
end
