defmodule Kraken.ApiError do
  @moduledoc """
  Raised in case non 200 response code from Kraken exchange.
  """
  defexception [:message]
end
