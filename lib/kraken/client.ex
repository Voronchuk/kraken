defmodule Kraken.Client do
  @moduledoc """
  Main entry point for Kraken requests.

  All requests are splitted to partions based on their cost.
  """

  use GenStage

  defmodule RequestParams do
    @type t :: %__MODULE__{
      method: atom(),
      url: binary(),
      body: HTTPoison.body(),
      headers: HTTPoison.headers(),
      options: Keyword.t()
    }
    defstruct [method: nil, url: nil, body: "", headers: [], options: []]
  end

  @type event :: {:request, GenStage.from(), RequestParams.t}

  @spec start_link() :: GenServer.on_start()
  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Issues an HTTP request with the given method to the given url.
  This function is usually used indirectly by `get/3`, `post/4`, `put/4`, etc
  Args:
  * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`,
    `:delete`, etc.)
  * `url` - target url as a binary string or char list
  * `body` - request body. See more below
  * `headers` - HTTP headers as an orddict (e.g., `[{"Accept", "application/json"}]`)
  * `options` - Keyword list of options
  Body:
  * binary, char list or an iolist
  * `{:form, [{K, V}, ...]}` - send a form url encoded
  * `{:file, "/path/to/file"}` - send a file
  * `{:stream, enumerable}` - lazily send a stream of binaries/charlists
  Options:
  * `:result_timeout` - receive result timeout, in milliseconds. Default is 2 minutes
  * `:timeout` - timeout to establish a connection, in milliseconds. Default is 8000
  * `:recv_timeout` - timeout used when receiving a connection. Default is 5000
  * `:proxy` - a proxy to be used for the request; it can be a regular url
    or a `{Host, Port}` tuple
  * `:proxy_auth` - proxy authentication `{User, Password}` tuple
  * `:ssl` - SSL options supported by the `ssl` erlang module
  * `:follow_redirect` - a boolean that causes redirects to be followed
  * `:max_redirect` - an integer denoting the maximum number of redirects to follow
  * `:params` - an enumerable consisting of two-item tuples that will be appended to the url as query string parameters
  Timeouts can be an integer or `:infinity`
  This function returns `{:ok, response}` or `{:ok, async_response}` if the
  request is successful, `{:error, reason}` otherwise.
  ## Examples
    request(:post, "https://my.website.com", ~s({"foo": 3}), [{"Accept", "application/json"}])
  """
  @spec request(atom, binary, HTTPoison.body, HTTPoison.headers, Keyword.t) :: {:ok, HTTPoison.Response.t} | {:error, binary} | no_return
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    cost = Keyword.get(options, :cost, 1)
    
    result_timeout = options[:result_timeout] || :timer.seconds(60*60)
    request = %RequestParams{
      method: method,
      url: url,
      body: body,
      headers: headers,
      options: Keyword.delete(options, :cost)
    }
    GenStage.call(__MODULE__, {:request, cost, request}, result_timeout)
  end

  @doc """
  Starts a task with request that must be awaited on.
  """
  @spec request_async(atom, binary, HTTPoison.body, HTTPoison.headers, Keyword.t) :: Task.t
  def request_async(method, url, body \\ "", headers \\ [], options \\ []) do
    Task.async(Kraken.Client, :request, [method, url, body, headers, options])
  end


  ## Callbacks

  def init(:ok) do
    {:producer, :queue.new(), dispatcher: GenStage.DemandDispatcher}
  end

  @doc """
  Adds an event to the queue
  """
  def handle_call({:request, cost, request}, from, queue) do
    updated_queue  = :queue.in({:request, cost, from, request}, queue)
    {:noreply, [], updated_queue}
  end

  @doc """
  Gives events for the next stage to process when requested
  """
  def handle_demand(demand, queue) when demand > 0 do
    {events, updated_queue} = take_from_queue(queue, demand, [])
    {:noreply, Enum.reverse(events), updated_queue}
  end

  # take demand events from the queue
  defp take_from_queue(queue, 0, events), do: {events, queue}
  defp take_from_queue(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {kind, cost, from, event}}, queue} ->
        take_from_queue(queue, demand - cost, [{kind, cost, from, event} | events])
      {:empty, queue} ->
        take_from_queue(queue, 0, events)
    end
  end
end