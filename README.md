# Kraken
REST API wrapper to communicate with the Kraken exchange.

The main difference from the other libs is the ability to pass authorization keys as optional params to requests,
which is useful then you have multiple access users. 

We also use **GenStage** to honour Kraken request limitations.

[Hex docs](https://hexdocs.pm/kraken/Kraken.API.html)

## Installation
Add `kraken` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kraken, "~> 0.1.2"}
  ]
end
```

## Usage
Refer [Kraken API documentation](https://www.kraken.com/help/api) for params, options and responses.

Sample public operations:

* `Kraken.API.get_asset_pairs(info: "info", pair: "XXBTZUSD")`
* `Kraken.API.get_order_book(pair: "XXBTZUSD")`
* `Kraken.API.get_recent_trades(pair: "XXBTZUSD")`
* `Kraken.API.get_spread(pair: "XXBTZUSD")`

Sample private operations:

* `Kraken.API.get_balance(api_key: "API_KEY", private_key: "PRIVATE_KEY")`
* `Kraken.API.get_trade_balance(api_key: "API_KEY", private_key: "PRIVATE_KEY")`
* `Kraken.API.get_open_orders(api_key: "API_KEY", private_key: "PRIVATE_KEY")`
* `Kraken.API.get_closed_orders(api_key: "API_KEY", private_key: "PRIVATE_KEY")`
* `Kraken.API.add_order(api_key: "API_KEY", private_key: "PRIVATE_KEY", pair: "XXBTZUSD", type: "buy", ordertype: "limit", price: 1, volume: 1, validate: "true", oflags: "post")`


## Tests
Use `KRAKEN_API_KEY` and `KRAKEN_PRIVATE_KEY` environment variables to set your test keys on exchange.
*No actual orders are executed during the tests, orders are executed in validation mode*

Run `mix test` as usual.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2018 Vyacheslav Voronchuk

## Restrictions
* __This library is in it's early beta, use on your own risk. Pull requests / reports / feedback are welcome.__
