defmodule DogIRC.Connection do
  @moduledoc """
  Handles connection to IRC server.

  * Responds to `PING`s
  * Forwards messages to `DogIRC.Parser` then client
  """

  use GenServer
  import DogIRC.Commands, only: [quit: 0]
  alias DogIRC.Parser
  alias DogIRC.Command

  require Logger

  @module __MODULE__

  ##
  # External API

  def start_link(opts) do
    server = Keyword.get(opts, :server, "localhost")
    port   = Keyword.get(opts, :port, 6667)
    client = Keyword.fetch!(opts, :client)
    GenServer.start_link(@module, server: server, port: port, client: client)
  end

  def send_cmd(conn, command),
  do: GenServer.cast(conn, {:command, command})

  def quit(conn),
  do: GenServer.cast(conn, :quit)

  ##
  # GenServer Implementation

  def init(server: server, port: port, client: client) do
    socket = Socket.TCP.connect!(server, port, packet: :line, mode: :active)
    {:ok, %{socket: socket, client: client}}
  end

  def handle_cast({:command, command}, state) do
    Socket.Stream.send!(state.socket, "#{command}\r\n")
    {:noreply, state}
  end

  def handle_cast(:quit, state) do
    Socket.Stream.send!(state.socket, quit)
    Socket.Stream.shutdown!(state.socket)
    {:noreply, %{state | socket: nil}}
  end

  def handle_info({:tcp, _, "PING " <> target}, state) do
    Socket.Stream.send!(state.socket, "PONG #{target}\r\n")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    {:noreply, %{state | socket: nil}}
  end

  def handle_info({:tcp, _, data}, state) do
    Logger.info "RAW: #{data}"
    forward_cmd = fn ->
      cmd = data |>
      Parser.parse |>
      Command.to_command

      send state.client, {:command, cmd}
    end

    Task.start(forward_cmd)
    {:noreply, state}
  end

  def handle_info(whatever, state) do
    Logger.debug "Unknown message: #{inspect whatever}"
    {:noreply, state}
  end
end
