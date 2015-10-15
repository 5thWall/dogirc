defmodule Dogirc.Plugin.UserList.ChannelRegistry do
  @moduledoc """
  Maps channel names to NameBucket PIDs
  """

  @module __MODULE__

  use GenServer
  use Towel

  alias Dogirc.Plugin.UserList, as: UL

  ##
  # Client

  def start_link(buckets, opts \\ []) do
    GenServer.start_link(@module, buckets, opts)
  end

  def lookup(registry, chan) do
    GenServer.call(registry, {:lookup, chan})
  end

  def create(registry, chan, users) do
    GenServer.cast(registry, {:create, chan, users})
  end

  def remove(registry, chan) do
    GenServer.cast(registry, {:remove, chan})
  end

  ##
  # Server

  def init(buckets) do
    {:ok, %{chans: HashDict.new, buckets: buckets}}
  end

  def handle_call({:lookup, chan}, _from, state) do
    {:reply, HashDict.fetch(state.chans, chan), state}
  end

  def handle_cast({:create, chan, users}, state) do
    {:ok, names} = UL.NameBucket.Supervisor.start_bucket(state.buckets, users)
    chans = HashDict.put(state.chans, chan, names)
    {:noreply, %{state | chans: chans}}
  end

  def handle_cast({:remove, chan}, state) do
    state.chans
    |> HashDict.fetch(chan) |> Result.wrap
    |> fmap(&Process.exit(&1, :kill))

    chans = HashDict.delete(state.chans, chan)
    {:noreply, %{state | chans: chans}}
  end
end
