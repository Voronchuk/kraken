defmodule Kraken.ApiTest do
  use ExUnit.Case

  setup do
    api_key = System.get_env("KRAKEN_API_KEY")
    private_key = System.get_env("KRAKEN_PRIVATE_KEY")
    {:ok, %{api_key: api_key, private_key: private_key}}
  end

  test "fetching balance for some account", %{api_key: api_key, private_key: private_key} do
    opts = [api_key: api_key, private_key: private_key]
    {:ok, balance} = Kraken.API.get_balance(opts)
    assert is_map(balance)
  end

  test "fetching trade balance for some account", %{api_key: api_key, private_key: private_key} do
    opts = [api_key: api_key, private_key: private_key]
    {:ok, balance} = Kraken.API.get_trade_balance(opts)
    assert match?(%{
      "c" => _,
      "e" => _,
      "eb" => _,
      "m" => _,
      "mf" => _,
      "n" => _,
      "tb" => _,
      "v" => _
    }, balance)
  end

  test "fetching open orders for some account", %{api_key: api_key, private_key: private_key} do
    opts = [api_key: api_key, private_key: private_key]
    {:ok, orders} = Kraken.API.get_open_orders(opts)
    assert match?(%{"open" => _}, orders)
  end

  test "fetching closed orders for some account", %{api_key: api_key, private_key: private_key} do
    opts = [api_key: api_key, private_key: private_key]
    {:ok, orders} = Kraken.API.get_closed_orders(opts)
    assert match?(%{"closed" => _}, orders)
  end

  test "post new limit order for some account", %{api_key: api_key, private_key: private_key} do
    opts = [
      api_key: api_key,
      private_key: private_key,
      pair: "XXBTZUSD",
      type: "buy",
      ordertype: "limit",
      price: 1,
      volume: 1,
      validate: "true",
      oflags: "post"
    ]
    {:ok, order} = Kraken.API.add_order opts
    assert match?(%{"descr" => _}, order)
  end
end
