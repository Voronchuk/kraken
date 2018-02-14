defmodule Kraken.Supervisor do
  @moduledoc """
  Supervisor to keep track of initialized Client, Limiter and Request processes.
  """

  use Supervisor
  alias Kraken.{Client, Limiter, Request}

  @config Application.get_all_env(:kraken)

  @spec start_link() :: {:ok, pid}
  def start_link do
    Supervisor.start_link(__MODULE__, [],  name: __MODULE__)
  end

  @spec init([]) :: {:ok, {:supervisor.sup_flags(), [Supervisor.Spec.spec()]}} | :ignore
  def init([]) do
    limiter_args = Keyword.take(@config, [:max_demand, :interval, :max_interval])

    children = [
      worker(Client, []),
      worker(Limiter, [
        limiter_args
        |> Keyword.put(:clients, [Client])
      ])
    ]

    max_demand = Keyword.fetch!(@config, :max_demand)

    request_workers =
      for num <- 1..Keyword.get(@config, :request_workers, max_demand), {limiter, name} <- [{Limiter, Request}] do
        name = :"#{name}#{num}"
        worker(
          Request,
          [[name: name, limiters: [{limiter, max_demand: max_demand}]]],
          id: name
        )
      end

    supervise(children ++ request_workers, strategy: :one_for_one)
  end

  def config, do: @config
end
