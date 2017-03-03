defmodule MyBlog.Counter do
  use GenServer

  import Logger
  import Ecto.Query

  alias MyBlog.Repo
  alias MyBlog.Blog
  
  ## Client Callbacks

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :sup_counter])
  end

  def increment(id, by) do
    GenServer.call(:sup_counter, {:increment, id, by})
  end

  def save_all do
    GenServer.cast(:sup_counter, {:save_all})
  end

  ## Server Callbacks

  def init(:ok) do
    query = from(b in Blog)
    result = Repo.all(query)
    counter_state = for(r <- result, into: %{}, do: {Integer.to_string(r.id), r.counter})
    log(:debug, "#{inspect counter_state}")
    {:ok, counter_state}
  end

  # request, _from pid, state
  def handle_call({:increment, id, by}, _from, counter_state) do
    log(:debug, "call: increment, state: #{inspect counter_state}")
    id_counter = Map.get(counter_state, id, 0)
    newCounter = id_counter + by
    newCounterState = Map.merge(counter_state, %{id => newCounter})

    {:reply, newCounter, newCounterState}
  end

  # request, state
  def handle_cast({:save_all}, counter_state) do
    log(:debug, "cast: save_all, state: #{inspect counter_state}")
    ids = for({key, _} <- counter_state, do: elem(Integer.parse(key), 0), into: [])
    vals = for({key, val} <- counter_state, do: {key, %{:counter => val}}, into: %{})
    query = from(b in Blog,
                where: b.id in ^ids)
    multi = 
      query
      |> Repo.all
      |> Enum.reduce(Ecto.Multi.new, fn(struct, multi) -> 
        Ecto.Multi.update(multi, struct.id, Blog.changeset(struct, vals[Integer.to_string(struct.id)])) end)
    {:ok, _} = Repo.transaction(multi)

    {:noreply, counter_state}
  end
end