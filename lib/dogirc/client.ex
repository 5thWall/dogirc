defmodule DogIRC.Client do
  use GenServer

  @name __MODULE__

  defstruct nick: "DogIRC",
            user: "DogIRC",
            real: "DogIRC",
            server: "localhost",
            port: 6667,
            sock: nil

  ##
  # External API

  def start_link(state \\ %DogIRC.Client{}) do
    GenServer.start_link(@name, state, name: @name)
  end

  def join(channel),
  do: GenServer.call(@name, {:join, channel})

  def privmsg(target, message),
  do: GenServer.call(@name, {:privmsg, target, message})

  def quote(command),
  do: GenServer.call(@name, {:quote, command})

  def quit(reason \\ ""),
  do: GenServer.call(@name, {:quit, reason})

  ##
  # GenServer Implimentation

  def init(state) do
    sock = Socket.TCP.connect! state.server, state.port, packet: :line, mode: :active
    sock |> Socket.Stream.send!(DogIRC.Commands.nick(state.nick))
    sock |> Socket.Stream.send!(DogIRC.Commands.user(state.user, state.real))
    { :ok, %{state | sock: sock } }
  end

  def handle_call({:join, channel}, _from, state = %DogIRC.Client{sock: sock}) do
    sock |> Socket.Stream.send!(DogIRC.Commands.join(channel))
    { :reply, :ok, state }
  end

  def handle_call({:privmsg, target, message}, _from, state = %DogIRC.Client{sock: sock}) do
    sock |> Socket.Stream.send!(DogIRC.Commands.privmsg(target, message))
    { :reply, :ok, state }
  end

  def handle_call({:quote, command}, _from, state = %DogIRC.Client{sock: sock}) do
    sock |> Socket.Stream.send!("#{command}\r\n")
    sock |> Sock.TCP.close
    { :reply, :ok, %{state | sock: nil } }
  end

  def handle_call({:quit, reason}, _from, state = %DogIRC.Client{sock: sock}) do
    sock |> Socket.Stream.send!(DogIRC.Commands.quit(reason))
    { :reply, :ok, state }
  end

  def handle_info({:tcp, _, "PING" <> _target}, state) do
    state.sock |> Socket.Stream.send!("PONG\r\n")
    { :noreply, state }
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
