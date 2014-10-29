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
  do: GenServer.cast(@name, {:join, channel})

  @doc "Message a channel or user"
  def privmsg(target, message),
  do: GenServer.cast(@name, {:privmsg, target, message})

  @doc "Send an action to a channel"
  def me(target, action),
  do: GenServer.cast(@name, {:action, target, action})

  @doc "Send a notice to a channel or user"
  def notice(target, message),
  do: GenServer.cast(@name, {:notice, target, message})

  @doc """
  Send a raw IRC command, "\r\n" is appended automaticasty
  """
  def quote(command),
  do: GenServer.cast(@name, {:quote, command})

  @doc "Tell the client to quit, optionally passing a part message"
  def quit,
  do: GenServer.cast(@name, :quit)

  def quit(reason),
  do: GenServer.cast(@name, {:quit, reason})

  ##
  # GenServer Implimentation

  def init(state) do
    sock = Socket.TCP.connect! state.server, state.port, packet: :line, mode: :active
    Socket.Stream.send!(sock, Commands.nick(state.nick))
    Socket.Stream.send!(sock, Commands.user(state.user, state.real))
    { :ok, %{state | sock: sock } }
  end

  def handle_cast({:join, channel}, state) do
    Socket.Stream.send!(state.sock, Commands.join(channel))
    { :noreply, state }
  end

  def handle_cast({:privmsg, target, message}, state) do
    Socket.Stream.send!(state.sock, Commands.privmsg(target, message))
    { :noreply, state }
  end

  def handle_cast({:action, target, action}, state) do
    Socket.Stream.send!(state.sock, Commands.action(target, action))
    { :noreply, state }
  end

  def handle_cast({:notice, target, message}, state) do
    Socket.Stream.send!(state.sock, Commands.notice(target, message))
    { :noreply, state }
  end

  def handle_cast({:quote, command}, state) do
    Socket.Stream.send!(state.sock, "#{command}\r\n")
    { :noreply, state }
  end

  def handle_cast({:quit, reason}, state) do
    do_quit(state.socket)
    { :noreply, state }
  end

  def handle_cast(:quit, state) do
    do_quit(state.socket)
    { :noreply, state }
  end

  def handle_info({:tcp, _, "PING " <> target}, state) do
    Socket.Stream.send!(state.sock, "PONG #{target}\r\n")
    { :noreply, state }
  end

  def handle_info({:tcp_closed, _}, state) do
    { :noreply, %{ state | sock: nil } }
  end

  def handle_info({:tcp, _, data}, state) do
    data |> DogIRC.Parser.parse |> inspect |> IO.puts
    {:noreply, state}
  end

  def handle_info(whatever, state) do
    IO.puts "Got: #{inspect whatever}"
    {:noreply, state}
  end

  defp do_quit(socket) do
    Socket.Stream.send!(socket, Commands.quit)
    Socket.Stream.shutdown! socket
  end
end
