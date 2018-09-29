defmodule Kraken.API do
  @moduledoc """
  API requests client for Kraken exchange.
  """

  alias Kraken.{Client, ApiError}
  require Logger

  @api_url "https://api.kraken.com"
  @api_public_path "/0/public/"
  @api_private_path "/0/private/"

  @doc """
  Get info about tradable asset pairs

  Options:

  * __info__: info to retrieve (optional)
  ** info: all info (default)
  ** leverage: leverage info
  ** fees: fees schedule
  ** margin: margin info
  * __pair__: comma delimited list of asset pairs to get info on (optional.  default = all)
  """
  @spec get_asset_pairs(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_asset_pairs(opts \\ []) do
    params = Keyword.take(opts, [:info, :pair])
    public_get_request("AssetPairs", params)
  end

  @doc """
  Get info about tradable asset pairs

  Options:

  * __pair__: comma delimited list of asset pairs to get info on
  """
  @spec get_ticker(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_ticker(opts) do
    params = Keyword.take(opts, [:pair])
    public_get_request("Ticker", params)
  end

  @doc """
  Get info about tradable asset pairs

  Options:

  * __pair__: asset pair to get OHLC data for
  * __interval__: time frame interval in minutes (optional): 1 (default), 5, 15, 30, 60, 240, 1440, 10080, 21600
  * __since__: return committed OHLC data since given id (optional.  exclusive)
  """
  @spec get_ohlc(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_ohlc(opts) do
    params = Keyword.take(opts, [:pair, :interval, :since])
    public_get_request("OHLC", params, 2)
  end

  @doc """
  Get order book

  Options:

  * __pair__: asset pair to get market depth for
  * __count__: maximum number of asks/bids (optional)
  """
  @spec get_order_book(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_order_book(opts) do
    params = Keyword.take(opts, [:pair, :count])
    public_get_request("Depth", params, 2)
  end

  @doc """
  Get recent trades

  Options:

  * __pair__: asset pair to get trade data for
  * __since__: return trade data since given id (optional.  exclusive)
  """
  @spec get_recent_trades(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_recent_trades(opts) do
    params = Keyword.take(opts, [:pair, :since])
    public_get_request("Trades", params, 2)
  end

  @doc """
  Get recent spread data

  Options:

  * __pair__: asset pair to get spread data for
  * __since__: return spread data since given id (optional.  inclusive)
  """
  @spec get_spread(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_spread(opts) do
    params = Keyword.take(opts, [:pair, :since])
    public_get_request("Spread", params)
  end

  @doc """
  Get account balance

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  """
  @spec get_balance(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_balance(opts \\ []) do
    private_post_request("Balance", [], opts)
  end

  @doc """
  Get detailed account balance in some currency

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __aclass__: asset class (optional): currency (default)
  * __asset__: base asset used to determine balance (default = ZUSD)
  """
  @spec get_trade_balance(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_trade_balance(opts \\ []) do
    params = Keyword.take(opts, [:aclass, :asset])
    private_post_request("TradeBalance", params, opts)
  end

  @doc """
  Get detailed info about order

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __trades__: whether or not to include trades in output (optional.  default = false)
  * __userref__: restrict results to given user reference id (optional)
  * __txid__: comma delimited list of transaction ids to query info about (20 maximum)
  """
  @spec query_orders_info(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def query_orders_info(opts \\ []) do
    params = Keyword.take(opts, [:trades, :userref, :txid])
    private_post_request("QueryOrders", params, opts)
  end

  @doc """
  Get account's open orders

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __trades__: whether or not to include trades in output (optional.  default = false)
  * __userref__: restrict results to given user reference id (optional)
  """
  @spec get_open_orders(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_open_orders(opts \\ []) do
    params = Keyword.take(opts, [:trades, :userref])
    private_post_request("OpenOrders", params, opts)
  end

  @doc """
  Get account's closed orders

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __trades__: whether or not to include trades in output (optional.  default = false)
  * __userref__: restrict results to given user reference id (optional)
  * __start__: starting unix timestamp or order tx id of results (optional.  exclusive)
  * __end__: ending unix timestamp or order tx id of results (optional.  inclusive)
  * __ofs__: result offset
  * __closetime__: which time to use (optional): open, close, both (default)
  """
  @spec get_closed_orders(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def get_closed_orders(opts \\ []) do
    params = Keyword.take(opts, [:trades, :userref, :start, :end, :ofs, :closetime])
    private_post_request("ClosedOrders", params, opts)
  end

  @doc """
  Post order by account

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __pair__: asset pair
  * __type__: type of order (buy/sell)
  * __ordertype__: order type:
  ** market
  ** limit: (price = limit price)
  ** stop-loss: (price = stop loss price)
  ** take-profit: (price = take profit price)
  ** stop-loss-profit: (price = stop loss price, price2 = take profit price)
  ** stop-loss-profit-limit: (price = stop loss price, price2 = take profit price)
  ** stop-loss-limit: (price = stop loss trigger price, price2 = triggered limit price)
  ** take-profit-limit: (price = take profit trigger price, price2 = triggered limit price)
  ** trailing-stop: (price = trailing stop offset)
  ** trailing-stop-limit: (price = trailing stop offset, price2 = triggered limit offset)
  ** stop-loss-and-limit: (price = stop loss price, price2 = limit price)
  ** settle-position
  * __price__: price (optional. dependent upon ordertype)
  * __price2__: secondary price (optional.  dependent upon ordertype)
  * __volume__: order volume in lots
  * __leverage__: amount of leverage desired (optional.  default = none)
  * __oflags__: comma delimited list of order flags (optional):
  ** viqc: volume in quote currency (not available for leveraged orders)
  ** fcib: prefer fee in base currency
  ** fciq: prefer fee in quote currency
  ** nompp: no market price protection
  ** post: post only order (available when ordertype = limit)
  * __starttm__: scheduled start time (optional):
  ** 0: now (default)
  ** +<n>: schedule start time <n> seconds from now
  ** <n>: unix timestamp of start time
  * __expiretm__: expiration time (optional):
  ** 0: no expiration (default)
  ** +<n>: expire <n> seconds from now
  ** <n>: unix timestamp of expiration time
  * __userref__: user reference id.  32-bit signed number.  (optional)
  * __validate__: validate inputs only.  do not submit order (optional)

  Optional closing order to add to system when order gets filled:

  * __close[ordertype]__: order type
  * __close[price]__: price
  * __close[price2]__: secondary price
  """
  @spec add_order(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def add_order(opts) do
    params = Keyword.take(opts, [:pair, :type, :ordertype, :price, :price2, :volume,
      :leverage, :oflags, :starttm, :expiretm, :userref, :validate])
    private_post_request("AddOrder", params, opts)
  end

  @doc """
  Cancel existing unclosed order

  Options:

  * __otp__: 2 factor auth code (required if it's enabled)
  * __txid__: transaction id
  """
  @spec cancel_open_order(Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def cancel_open_order(opts) do
    params = Keyword.take(opts, [:txid])
    private_post_request("CancelOrder", params, opts)
  end


  @doc """
  Use this to execute public requests without API wrapper
  """
  @spec public_get_request(String.t, Keyword.t, integer()) :: {:ok, map()} | {:error, ApiError}
  def public_get_request(api_name, params, cost \\ 1) do
    with \
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} <-
        Client.request(:get, "#{@api_url}#{@api_public_path}#{api_name}?#{URI.encode_query(params)}", "", [], [cost: cost]),
      {:ok, %{"result" => result}} <-
        Jason.decode(response)
    do
      {:ok, result}
    else
      {:ok, %{"error" => error}} ->
        Logger.warn fn() -> "Kraken API result error: #{inspect(error)}" end
        {:error, ApiError}
      {:ok, %HTTPoison.Response{status_code: code}} ->
        Logger.warn fn() -> "Kraken API result error code: #{inspect(code)}" end
        {:error, ApiError}
      {:error, _} ->
        {:error, ApiError}
    end
  end

  @doc """
  Use this to execute private requests without API wrapper.
  OTP param is needed in case of 2 Factor Auth.
  """
  @spec private_post_request(String.t, Keyword.t, Keyword.t) :: {:ok, map()} | {:error, ApiError}
  def private_post_request(api_name, data, opts \\ []) do
    otp = Keyword.get(opts, :otp)
    cost = Keyword.get(opts, :cost, 1)
    api_key = Keyword.fetch!(opts, :api_key)
    private_key = Keyword.fetch!(opts, :private_key) |> Base.decode64!()
    uri = "#{@api_private_path}#{api_name}"
    url = "#{@api_url}#{uri}"
    nonce = :os.system_time(:micro_seconds)
    body = data
    |> Keyword.put(:nonce, nonce)
    |> (fn(data) -> if otp != nil, do: Keyword.put(data, :otp, otp), else: data end).()
    |> URI.encode_query

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"API-Key", api_key},
      {"API-Sign", sign_data(uri, body, nonce, private_key)}
    ]

    with \
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} <-
        Client.request(:post, url, body, headers, [cost: cost]),
      {:ok, %{"result" => result}} <-
        Jason.decode(response)
    do
      {:ok, result}
    else
      {:ok, %{"error" => error}} ->
        Logger.warn fn() -> "Kraken API result error: #{inspect(error)}" end
        {:error, ApiError}
      {:ok, %HTTPoison.Response{status_code: code}} ->
        Logger.warn fn() -> "Kraken API result error code: #{inspect(code)}" end
        {:error, ApiError}
      {:error, _} ->
        {:error, ApiError}
    end
  end

  defp sign_data(uri, data, nonce, private_key) do
    data = uri <> :crypto.hash(:sha256, to_string(nonce) <> data)
    :crypto.hmac(:sha512, private_key, data)
    |> Base.encode64
  end
end
