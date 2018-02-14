defmodule Kraken do
  @moduledoc """
  Bootstrap Kraken application.
  """

  use Application

  def start(_type, _args) do
    Kraken.Supervisor.start_link()
  end
end
